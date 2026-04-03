# List Countries

## Endpoint

```
GET /b2b/ramp/countries
```

## Description

List countries and regions where Ramp is available. Depending on regulatory rules, availability may be scoped to specific states, provinces, or regions.

## Authentication

Required. Include `API-Key` and `API-Sign` headers with every request.

## Request Parameters

No request parameters are required for this endpoint.

## Response

### Success

- **200 OK** -- Returns a list of countries and regions where Ramp is available, including any sub-regional restrictions.

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |

## Example Request

```http
GET /b2b/ramp/countries HTTP/1.1
Host: nexus.kraken.com
API-Key: <your-api-key>
API-Sign: <your-api-signature>
Payward-Version: 2025-04-15
```

## Example Response

```
HTTP/1.1 200 OK
Content-Type: application/json
```

## Notes

- Availability may vary by sub-region (state, province) due to regulatory requirements.
- Use this endpoint to determine where Ramp services can be offered before initiating transactions.
- Part of the Ramp REST API "Supported Options" section.

---

*Source: [Kraken API Documentation -- List Countries](https://docs.kraken.com/api/docs/ramp-api/get-ramp-countries)*
