# Submit Embed Verification

## Endpoint

```
POST /b2b/verifications/:user
```

## Description

Submit a verification for a user with documents and details. Verifications are checks performed on users to verify information provided by the user, typically conducted by third-party identity verification specialists. These checks commonly examine documents like passports or driver's licenses, though they may also include sanctions checks or Politically Exposed Person (PEP) assessments.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user` | string | Yes | The unique identifier of the user to submit verification for. |

### Request Body

The request body should contain the verification documents and details. This endpoint expects multipart form data with document uploads.

## Response

### Success

- **200 OK** -- The verification was successfully submitted.

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
POST /b2b/verifications/user-123 HTTP/1.1
Host: nexus.kraken.com
Content-Type: multipart/form-data
API-Key: <your-api-key>
API-Sign: <your-api-signature>
```

## Example Response

```
HTTP/1.1 200 OK
Content-Type: application/json
```

## Notes

- Verifications involve identity checks performed by third-party specialists.
- Common document types include passports, driver's licenses, and other government-issued IDs.
- Verification checks may also include sanctions screening and PEP (Politically Exposed Person) assessments.
- For submitting verifications using presigned URLs instead of direct file uploads, see [Submit Embed Verification from URL](submit-embed-verification-from-url.md).

---

*Source: [Kraken API Documentation -- Submit Embed Verification](https://docs.kraken.com/api/docs/embed-api/submit-embed-verification)*
