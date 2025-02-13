# Squid On Docker

This is a minimal Docker image with [Squid](http://www.squid-cache.org/) configured to proxy only authenticated requests and, optionally, restrict access to specific domains.

## Usage

### Building the Docker Image

```bash
docker build -t baoduy2412/squid-basic-auth:latest -f Dockerfile.basic .
```

### Creating and Running the Container

Start the container using the bellow command:

```bash
docker run -d -e PROXY_USERNAME=baoduy2412 -e PROXY_PASSWORD=password -p 3128:3128 baoduy2412/squid-basic-auth:latest
```

### Accessing the Proxy

When accessing the proxy, use the `PROXY_USERNAME` and `PROXY_PASSWORD` set in the environment variables:

```bash
curl --proxy-basic --proxy-user baoduy2412:password --proxy http://localhost:3128 https://drunkcoding.net -v
```

## Environment Variables

The Docker image supports several environment variables for customization:

1. **`PROXY_PASSWORD`**:
   - **Purpose**: Sets the password for Squid proxy authentication.
   - **Requirement**: Must be provided along with `PROXY_USERNAME`. If not provided, the script exits with an error.

2. **`PROXY_USERNAME`**:
   - **Purpose**: Sets the username for Squid proxy authentication.
   - **Requirement**: Must be provided along with `PROXY_PASSWORD`. If not provided, the script exits with an error.

3. **`PROXY_ALLOWED_DSTDOMAINS`**:
   - **Purpose**: Specifies a list of destination domains allowed through the proxy.
   - **Format**: Comma or semicolon-separated string of domains.
   - **Effect**: Converts this list into ACL rules in the Squid configuration to permit access to these domains.

4. **`PROXY_ALLOWED_DSTDOMAINS_REGEX`**:
   - **Purpose**: Specifies regex patterns for allowed destination domains.
   - **Effect**: Adds regex-based ACL rules to the Squid configuration for domain filtering.

5. **`PROXY_DEBUG`**:
   - **Purpose**: Controls the debug output level of the Squid server.
   - **Options**:
     - If set (`PROXY_DEBUG=1`), Squid runs in non-daemon mode with debug output.
     - If not set, Squid runs in non-daemon mode without debug output.

## Licenses

This project is licensed under the MIT License.

