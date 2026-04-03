# Get Authorization Code

## Endpoint

```
GET /oauth/authorize
```

## Description

Redirect users to this URL in their browser to start the OAuth flow. This initiates the authorization process where the user authenticates with Kraken and approves the requested permissions.

## Authentication

No API authentication required. This is a browser-based redirect endpoint.

## Request Parameters

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `response_type` | string | Yes | Must be `code`. |
| `client_id` | string | Yes | Your application's client ID. |
| `redirect_uri` | string | Yes | The callback URL where users are redirected after authorization. |
| `scope` | string | No | Space-separated list of requested permissions. |
| `state` | string | No | An opaque value for CSRF protection; echoed back in the callback. |

## Response

### Success

- **302 Found** -- Redirects the user's browser to the `redirect_uri` with an authorization code.

**Response Format:** `application/x-www-form-urlencoded`

### Response Headers

| Header | Description |
|--------|-------------|
| `Location` | The URL to redirect the user's browser to. |

### Success Redirect URL

```
https://example.com/callback?code=AUTHORIZATION_CODE&state=YOUR_STATE
```

### Success Response Parameters

| Parameter | Description |
|-----------|-------------|
| `code` | The authorization code to exchange for an access token. |
| `state` | Echo of the state parameter from the original request. |

### Error Redirect URL

```
https://example.com/callback?error=access_denied&state=YOUR_STATE
```

### Error Response Parameters

| Parameter | Description |
|-----------|-------------|
| `error` | Error identifier (e.g., `access_denied`). |
| `state` | Echo of the state parameter from the original request. |

## Example Request

```
https://id.kraken.com/oauth/authorize?response_type=code&client_id=YOUR_CLIENT_ID&redirect_uri=https://example.com/callback&state=YOUR_STATE
```

## Notes

- This endpoint requires browser redirection rather than direct API calls.
- The authorization code received in the callback should be exchanged for an access token via the [Get Access Token](get-access-token.md) endpoint.
- Always include the `state` parameter for CSRF protection.
- For language-specific OAuth flows, see [Get Authorization Code with Language](get-authorization-code-with-language.md).

---

*Source: [Kraken API Documentation -- Get Authorization Code](https://docs.kraken.com/api/docs/oauth/get-o-auth-code)*
