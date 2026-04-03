# Futures REST

> Source: https://docs.kraken.com/api/docs/guides/futures-rest

## Authentication

### Required Headers

The Kraken Futures API requires three HTTP headers for authenticated calls:

| Header | Value | Required |
|--------|-------|----------|
| APIKey | Public API key | Yes |
| Authent | Authentication string | Yes |
| Nonce | Unique incrementing nonce | No |

### Authentication Components

**PostData:** Parameters formatted as `&` concatenated strings (e.g., `symbol=fi_xbtusd_180615`)

**Nonce:** A continuously incrementing integer, typically system time in milliseconds. "Our system tolerates nonces that are out of order for a brief period of time."

**Endpoint Path:** The URL extension of the endpoint (e.g., `/api/v3/orderbook`)

**API Secret:** Obtained during API key generation

### Computing Authent

The authentication string requires five steps:

1. Concatenate postData + Nonce + endpointPath
2. Hash with SHA-256 algorithm
3. Base64-decode the API secret
4. Use decoded secret to HMAC-SHA-512 hash the SHA-256 result
5. Base64-encode the final result

### Recent Changes

As of February 20, 2024, the API updated authentication to hash full URL-encoded parameters rather than decoded query strings. For the time being, this change is backward compatible, but the older method will be deprecated October 1st, 2025.

## Calls and Returns

**Request Methods:**

- GET for read-only operations (parameters in URL)
- POST/PUT for state-changing operations (parameters in request body)

**Response Format:** JSON responses include a `result` field. When `result` equals `"success"`, the request was received successfully, though the desired operation may not have completed. Check status fields for operation details.
