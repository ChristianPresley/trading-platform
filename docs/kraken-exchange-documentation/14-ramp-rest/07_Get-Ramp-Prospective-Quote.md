# Get Ramp Prospective Quote

## Endpoint

```
GET /b2b/ramp/quotes/prospective
```

## Description

Retrieve a prospective quote for a Ramp transaction without reserving liquidity. Use this to preview spend/receive amounts before creating a checkout URL.

## Authentication

Required. Include `API-Key` and `API-Sign` headers with every request.

## Request Parameters

Query parameters should specify the transaction details (crypto asset, fiat currency, amount, payment method, etc.) for the prospective quote. Specific parameter details are defined by the Ramp API schema.

## Response

### Success

- **200 OK** -- Returns a prospective quote with indicative spend/receive amounts and fees.

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |

## Example Request

```http
GET /b2b/ramp/quotes/prospective HTTP/1.1
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

- This endpoint provides indicative pricing without reserving liquidity or committing to a transaction.
- Use this for previewing spend/receive amounts before generating a checkout URL.
- Actual transaction amounts may differ from the prospective quote due to market movements.
- Related endpoints: [Get Ramp Limits](get-ramp-limits.md), [Get Ramp Checkout](get-ramp-checkout.md).

---

*Source: [Kraken API Documentation -- Get Ramp Prospective Quote](https://docs.kraken.com/api/docs/ramp-api/get-ramp-prospective-quote)*
