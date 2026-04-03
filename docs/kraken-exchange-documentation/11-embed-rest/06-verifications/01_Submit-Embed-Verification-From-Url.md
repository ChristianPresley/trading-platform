# Submit Embed Verification from URL

## Endpoint

```
POST /b2b/verifications/:user/url
```

## Description

Submit a verification for a user with documents provided via presigned URLs. Instead of direct file uploads via multipart form data, this endpoint accepts presigned URLs directing to document files. The server downloads files from the provided URLs and extracts filenames from URL paths. This approach is suited for situations where documents already reside in cloud storage providers like AWS S3 or Google Cloud Storage.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Domain Allowlisting Requirement

For security, the domains you use for presigned URLs must be allowlisted before you can use this endpoint. Account managers must configure permitted domains for your integration.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user` | string | Yes | The unique identifier of the user to submit verification for. |

### Request Body

The request body should contain presigned URLs pointing to verification documents, along with any additional verification details.

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
POST /b2b/verifications/user-123/url HTTP/1.1
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

- Presigned URL domains must be allowlisted before use -- contact your account manager to configure permitted domains.
- The server downloads files from the provided URLs and extracts filenames from URL paths.
- Ideal for documents stored in cloud storage (AWS S3, Google Cloud Storage, etc.).
- For direct file uploads via multipart form data, see [Submit Embed Verification](submit-embed-verification.md).
- Verifications involve identity checks performed by third-party specialists, commonly examining passports, driver's licenses, sanctions checks, and PEP assessments.

---

*Source: [Kraken API Documentation -- Submit Embed Verification from URL](https://docs.kraken.com/api/docs/embed-api/submit-embed-verification-from-url)*
