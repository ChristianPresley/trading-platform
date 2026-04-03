# Get User Info

## Endpoint

```
GET /userinfo
```

## Description

Returns the email address and IIBAN of the user.

## Authentication

Required. OAuth access token with `account.info:basic` scope.

```
Authorization: Bearer <access_token>
```

## Request Parameters

No request parameters are required for this endpoint.

## Response

### Success

- **200 OK** -- Returns the user's email address and IIBAN.

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `email` | string | The user's email address. |
| `iiban` | string | The user's IIBAN (International Identifier of Bank Account Number). |

## Example Request

```http
GET /userinfo HTTP/1.1
Host: api.kraken.com
Authorization: Bearer <access_token>
```

## Example Response

```
HTTP/1.1 200 OK
Content-Type: application/json
```

## Notes

- Requires an OAuth access token with the `account.info:basic` scope.
- Returns only basic user information (email and IIBAN).
- The access token must be obtained through the [Get Access Token](get-access-token.md) endpoint.

---

*Source: [Kraken API Documentation -- Get User Info](https://docs.kraken.com/api/docs/oauth/get-o-auth-info)*
