#!/bin/bash -eux

# Ensure necessary directories exist and set proper permissions
mkdir -p /var/squid/cache /var/squid/logs
chown proxy -R /var/squid

# LDAP variables
# LDAP_SERVER
# LDAP_DN_USER
# LDAP_DN_PASSWORD
# LDAP_USERS_GROUPS

pass_file="/etc/squid/ldap_password"
# Check for required environment variables and configure authentication
if [[ "${LDAP_SERVER:-none}" != "none" && "${LDAP_DN_PASSWORD:-none}" != "none" ]]; then
	touch "$pass_file"
	echo "${LDAP_DN_PASSWORD}" > "$pass_file"
	chown root "$pass_file"
	chmod 600 "$pass_file"

	echo "auth_param basic program /usr/lib/squid/basic_ldap_auth -b \"${LDAP_USERS_GROUPS}\" -D \"${LDAP_DN_USER}\" -W $pass_file -f \"userid=%s\" -H ldap://${LDAP_SERVER}" | sed -i '/# LDAP_AUTH/ r /dev/stdin' /etc/squid/squid.conf
else
	echo "Need to provide the environment variables for LDAP Auth."
	exit 1
fi

# Handle domain whitelisting
result=""
if [[ "${PROXY_ALLOWED_DSTDOMAINS:-x}" != "x" ]]; then
	arr=$(echo $PROXY_ALLOWED_DSTDOMAINS | tr ",;" "\n\n")
	for dstdomain in $arr; do
		result=$(echo -e "$result acl whitelist dstdomain $dstdomain\n")
	done
else
	echo "You may provide PROXY_ALLOWED_DSTDOMAINS environment variable to limit which domains are accessible"
fi

# Handle regex-based domain whitelisting
if [[ "${PROXY_ALLOWED_DSTDOMAINS_REGEX:-x}" != "x" ]]; then
	result=$(echo -e "$result acl whitelist dstdom_regex $PROXY_ALLOWED_DSTDOMAINS_REGEX\n")
else
	echo "You may provide PROXY_ALLOWED_DSTDOMAINS_REGEX environment variable to limit which domains are accessible"
fi

# Update squid configuration if any rules are defined
if [[ -n "$result" ]]; then
    echo "$result"
    # Insert ACL rules into squid.conf
    echo "$result" | sed -i '/# WHITELIST_ACL/ r /dev/stdin' /etc/squid/squid.conf
	echo "http_access allow authenticated whitelist" | sed -i '/# WHITELIST_ACCESS/ r /dev/stdin' /etc/squid/squid.conf
else
    echo "http_access allow authenticated" | sed -i '/# WHITELIST_ACCESS/ r /dev/stdin' /etc/squid/squid.conf
fi

# cat /etc/squid/squid.conf

# Initialize and start Squid
/usr/sbin/squid -z
rm -f /var/run/squid.pid

# Start Squid with or without debug mode based on environment variable
if [[ "${PROXY_DEBUG:-}" == "1" ]]; then
    echo "Starting Squid in debug mode..."
    /usr/sbin/squid -N -d 1
else
    echo "Starting Squid..."
    /usr/sbin/squid -N
fi