# Create Fast API Key

## Endpoint

```
POST /fast-api-key
```

## Description

Creates a Fast API key for programmatic access to Kraken APIs.

## Authentication

Required. OAuth access token with `account.fast-api-key:write` scope.

```
Authorization: Bearer <access_token>
```

## Request Parameters

The request body should contain the configuration for the new Fast API key, including desired permissions and restrictions. Specific parameter details are defined by the OAuth API schema.

## Response

### Success

- **200 OK** -- Returns the newly created Fast API key and associated metadata.

## Example Request

```http
POST /fast-api-key HTTP/1.1
Host: api.kraken.com
Content-Type: application/json
Authorization: Bearer <access_token>
```

## Example Response

```
HTTP/1.1 200 OK
Content-Type: application/json
```

## Notes

- Requires an OAuth access token with the `account.fast-api-key:write` scope.
- The created API key can be used for direct API access without going through the OAuth flow.
- The access token must be obtained through the [Get Access Token](get-access-token.md) endpoint.
- Related operations include deleting keys (see the Delete Key endpoint in the OAuth REST API documentation).

---

*Source: [Kraken API Documentation -- Create Fast API Key](https://docs.kraken.com/api/docs/oauth/create-fast-api-key)*
