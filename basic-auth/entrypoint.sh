#!/bin/bash -eux

# Ensure necessary directories exist and set proper permissions
mkdir -p /var/squid/cache /var/squid/logs
chown proxy -R /var/squid

# Check for required environment variables and configure authentication
if [[ "${PROXY_PASSWORD:-none}" != "none" && "${PROXY_USERNAME:-none}" != "none" ]]; then
	htpasswd -mbc /etc/squid/passwd "${PROXY_USERNAME}" "${PROXY_PASSWORD}"
else
	echo "Need to provide the environment variable PROXY_PASSWORD AND PROXY_USERNAME"
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