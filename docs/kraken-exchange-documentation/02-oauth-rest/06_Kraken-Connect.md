# Kraken Connect (OAuth 2.0)

## Overview

Kraken Connect is an OAuth 2.0 implementation for third-party integrations, enabling applications to authenticate users and access Kraken API resources on their behalf.

## Key URLs

| Purpose | URL |
|---------|-----|
| Authorization | `https://id.kraken.com/oauth/authorize` |
| Token | `https://api.kraken.com/oauth/token` |

## Client Types

### Public Client

- Runs on user devices (mobile apps, SPAs) without secure backend storage.
- No RSA keys required.
- Access token lifetime: 4 hours.

### Confidential Client

- Server-based application with secure backend storage.
- Requires RSA key generation (2048+ bits, PEM format).
- Access token lifetime: 24 hours.

## Authorization Code Flow

### Step 1: Redirect to Authorization Endpoint

Direct the user's browser to the authorization endpoint with the following parameters:

| Parameter | Required | Description |
|-----------|----------|-------------|
| `response_type` | Yes | Must be `code`. |
| `client_id` | Yes | Your application's client ID. |
| `redirect_uri` | Yes | The callback URL where users are redirected after authorization. |
| `scope` | No | Space-separated list of requested permissions. |
| `state` | No | An opaque value used for CSRF protection; echoed back in the callback. |

### Step 2: User Authenticates and Approves

The user authenticates with Kraken and approves the requested permissions. Upon approval, the user is redirected to the `redirect_uri` with an authorization code.

### Step 3: Exchange Code for Access Token

Exchange the authorization code for an access token using Basic Auth:

```
Authorization: Basic <base64(client_id:client_secret)>
```

## Token Lifetimes

| Token Type | Lifetime |
|------------|----------|
| Access Token (confidential client) | 24 hours |
| Access Token (public client) | 4 hours |
| Refresh Token | 30 days |

## Authentication Method

Token requests use HTTP Basic Authentication:

```
Authorization: Basic <base64(client_id:client_secret)>
```

## Related Endpoints

- [Get Authorization Code](get-authorization-code.md) -- Start the OAuth flow
- [Get Authorization Code with Language](get-authorization-code-with-language.md) -- Start the OAuth flow with language preference
- [Get Access Token](get-access-token.md) -- Exchange authorization code for tokens
- [Get User Info](get-user-info.md) -- Retrieve user information
- [Create Fast API Key](create-fast-api-key.md) -- Create a Fast API key

## Notes

- Public clients do not require RSA keys but have shorter token lifetimes.
- Confidential clients must generate RSA keys (minimum 2048 bits, PEM format).
- Refresh tokens can be used to obtain new access tokens without re-authorization.
- Always use the `state` parameter for CSRF protection.

---

*Source: [Kraken API Documentation -- Kraken Connect](https://docs.kraken.com/api/docs/oauth/kraken-connect)*
