# Spot REST Authentication

> Source: https://docs.kraken.com/api/docs/guides/spot-rest-auth

## Authentication Parameters

The Kraken REST API requires four authentication parameters for private endpoints:

- **API-Key**: Your public API key in the HTTP header
- **API-Sign**: An encrypted signature in the HTTP header
- **nonce**: An always-increasing 64-bit integer in the payload
- **otp**: One-time password (only if 2FA is enabled)

## API-Key Header

The `API-Key` header contains your **public** API key. You must obtain an API key-pair from your account settings. The **public** key is sent in the `API-Key` header parameter, while the **private** key is **never** sent.

## API-Sign Header

The signature is generated using:

```
HMAC-SHA512 of (URI path + SHA256(nonce + POST data)) and base64 decoded secret API key
```

The URI path should be the portion starting with "/0/private" from your API endpoint.

### Example Signature Generation

For a limit order request with these parameters:

| Field | Value |
|-------|-------|
| Private Key | `kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==` |
| Nonce | `1616492376594` |
| URI Path | `/0/private/AddOrder` |
| **API-Sign** | **`4/dpxb3iT4tp/ZCVEwSnEsLxx0bqyhLpdfOpc6fn7OR8+UClSV5n9E6aSS8MPtnRfp32bAb0nmbRn6H8ndwLUQ==`** |

Code examples in Python, Go, and Node.js are provided in the original documentation.

## Nonce Parameter

The nonce must be an always increasing, unsigned 64-bit integer for each request. Common approaches include UNIX timestamps in milliseconds or higher-resolution values for parallel requests. Too many requests with invalid nonces (`EAPI:Invalid nonce`) can result in temporary bans.

For shared API keys across processes, coordinate nonces through a centralized store to avoid collisions.

## OTP Parameter

The optional `otp` parameter is your one-time password, only required if two-factor authentication (2FA) is enabled for the API key and action in question.
