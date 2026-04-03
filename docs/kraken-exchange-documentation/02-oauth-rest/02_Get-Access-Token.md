# Get Access Token

## Endpoint

```
POST /oauth/token
```

## Description

Retrieve the access token by exchanging an authorization code or refreshing an existing token.

## Authentication

HTTP Basic Authentication with client credentials:

```
Authorization: Basic <base64(client_id:client_secret)>
```

## Request Parameters

### Request Body (application/x-www-form-urlencoded)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `grant_type` | string | Yes | The grant type. Use `authorization_code` for initial token exchange, or `refresh_token` for refreshing. |
| `code` | string | Conditional | The authorization code received from the authorize endpoint. Required when `grant_type` is `authorization_code`. |
| `redirect_uri` | string | Conditional | Must match the `redirect_uri` used in the authorization request. Required when `grant_type` is `authorization_code`. |
| `refresh_token` | string | Conditional | The refresh token. Required when `grant_type` is `refresh_token`. |

## Response

### Success

- **200 OK** -- Returns the access token, refresh token, and token metadata.

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `access_token` | string | The access token for API requests. |
| `token_type` | string | The token type (typically `Bearer`). |
| `expires_in` | integer | Token lifetime in seconds. |
| `refresh_token` | string | The refresh token for obtaining new access tokens. |
| `scope` | string | The granted scopes. |

## Example Request

```http
POST /oauth/token HTTP/1.1
Host: api.kraken.com
Content-Type: application/x-www-form-urlencoded
Authorization: Basic <base64(client_id:client_secret)>

grant_type=authorization_code&code=AUTHORIZATION_CODE&redirect_uri=https://example.com/callback
```

## Example Response

```
HTTP/1.1 200 OK
Content-Type: application/json
```

## Notes

- Use `grant_type=authorization_code` for the initial token exchange after the user authorizes.
- Use `grant_type=refresh_token` to obtain a new access token when the current one expires.
- Access token lifetime: 24 hours (confidential clients) or 4 hours (public clients).
- Refresh token lifetime: 30 days.
- The `redirect_uri` must exactly match the one used in the original authorization request.

---

*Source: [Kraken API Documentation -- Get Access Token](https://docs.kraken.com/api/docs/oauth/get-o-auth-token)*
