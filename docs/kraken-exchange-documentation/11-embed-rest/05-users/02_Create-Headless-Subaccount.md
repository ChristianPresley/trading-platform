# Create Headless Embed Subaccount

## Endpoint

```
POST /b2b/subaccounts
```

## Description

Create a lightweight account that only requires an external ID mapping, without any user profile data (email, name, phone, etc.). This option is suited for partners who manage user information independently.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Licensing Requirements

The availability of this endpoint depends on your licensing agreement. Only partners with the relevant licenses in their operating jurisdiction can choose not to share KYC data with Payward.

For accounts requiring comprehensive KYC verification with profile information, use the [Create User](create-embed-user.md) endpoint instead.

## Request Parameters

The request body should contain the external ID mapping for the subaccount. Specific parameter details are defined by the Embed API schema.

## Response

### Success

- **200 OK** -- The headless subaccount was successfully created.

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 400 | Bad Request -- the request was malformed or contained invalid parameters. | No |
| 401 | Unauthorized -- authentication failed or credentials are missing/invalid. | No |
| 403 | Forbidden -- the authenticated user does not have permission to perform this action. | No |
| 404 | Not Found -- the requested resource does not exist. | No |
| 408 | Request Timeout -- the request took too long to process. | Yes |
| 409 | Conflict -- the request conflicts with the current state of the resource. | Sometimes |
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |
| 503 | Service Unavailable -- the service is temporarily unavailable. | Yes |

## Example Request

```http
POST /b2b/subaccounts HTTP/1.1
Host: nexus.kraken.com
Content-Type: application/json
API-Key: <your-api-key>
API-Sign: <your-api-signature>
```

## Example Response

```
HTTP/1.1 200 OK
Content-Type: application/json
```

## Notes

- This endpoint creates a lightweight account without user profile data -- ideal for partners managing user information independently.
- Licensing agreement determines availability -- only partners with relevant licenses in their operating jurisdiction can use this endpoint.
- For full user profiles with KYC data, use the [Create User](create-embed-user.md) endpoint.

---

*Source: [Kraken API Documentation -- Create Headless Embed Subaccount](https://docs.kraken.com/api/docs/embed-api/create-headless-embed-subaccount)*
