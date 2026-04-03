# Get Open Positions

Source: [https://docs.kraken.com/api/docs/futures-api/trading/get-open-positions](https://docs.kraken.com/api/docs/futures-api/trading/get-open-positions)

## Endpoint

```
GET /openpositions
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/openpositions`

## Description

This endpoint returns the size and average entry price of all open positions in Futures
contracts. This includes Futures contracts that have matured but have not yet been settled.

## Authentication

This endpoint requires authentication.

**Required Headers:**

| Header | Description |
|--------|-------------|
| `APIKey` | Your Kraken Futures API key |
| `Authent` | Authentication signature (HMAC-SHA512 of the request) |
| `Nonce` | A unique, incrementing value for each request |

The `Authent` header value is computed as: `HMAC-SHA512(base64_decode(api_secret), SHA256(postData + nonce + endpoint_path))`

## Request Parameters

This endpoint does not accept any parameters.

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `openPositions` | array[object] | Yes | A list containing structures with information on open positions.  The list is sorted descending by fillTime. |
| &nbsp;&nbsp;`openPositions[].symbol` | string | Yes | The symbol of the Futures. |
| &nbsp;&nbsp;`openPositions[].side` | string | Yes | The direction of the position. Enum: `long`, `short` |
| &nbsp;&nbsp;`openPositions[].size` | number (double) | Yes | The size of the position. |
| &nbsp;&nbsp;`openPositions[].price` | number (double) | Yes | The average price at which the position was entered into. |
| &nbsp;&nbsp;`openPositions[].fillTime` | string | Yes | The date and time the position was entered into (Deprecated field, fills endpoint for fill time is recommended). |
| &nbsp;&nbsp;`openPositions[].unrealizedFunding` | ['number', 'null'] (double) | Yes | Unrealised funding on the position. |
| &nbsp;&nbsp;`openPositions[].pnlCurrency` | ['string', 'null'] | No | Selected pnl currency for the position (default: USD) Enum: `USD`, `EUR`, `GBP`, `USDC`, `USDT`, `BTC`, `ETH` |
| &nbsp;&nbsp;`openPositions[].maxFixedLeverage` | ['number', 'null'] (double) | No | Max leverage selected for isolated position. |
| `result` | string | Yes |  Enum: `success` Example: `success` |
| `serverTime` | string (date-time) | Yes | Server time in Coordinated Universal Time (UTC) Example: `2020-08-27T17:03:33.196Z` |

#### ErrorResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `errors` | array[string] | No |  |
| `error` | string | Yes | Error description.    - `accountInactive`: The Futures account the request refers to is inactive   - `apiLimitExceeded`: The API limit for the calling IP address has been exceeded   - `authenticationError`: The request could not be authenticated   - `insufficientFunds`: The amount requested for transfer is below the amount of funds available   - `invalidAccount`: The Futures account the transfer request refers to is invalid   - `invalidAmount`: The amount the transfer request refers to is invalid   - `invalidArgument`: One or more arguments provided are invalid   - `invalidUnit`: The unit the transfer request refers to is invalid   - `Json Parse Error`: The request failed to pass valid JSON as an argument   - `marketUnavailable`: The market is currently unavailable   - `nonceBelowThreshold`: The provided nonce is below the threshold   - `nonceDuplicate`: The provided nonce is a duplicate as it has been used in a previous request   - `notFound`: The requested information could not be found   - `requiredArgumentMissing`: One or more required arguments are missing   - `Server Error`: There was an error processing the request   - `Unavailable`: The endpoint being called is unavailable   - `unknownError`: An unknown error has occurred Enum: `accountInactive`, `apiLimitExceeded`, `authenticationError`, `insufficientFunds`, `invalidAccount`, `invalidAmount`, `invalidArgument`, `invalidUnit`, `Json Parse Error`, `marketUnavailable`, `nonceBelowThreshold`, `nonceDuplicate`, `notFound`, `requiredArgumentMissing`, `Server Error`, `Unavailable`, `unknownError` |
| `result` | string | Yes |  Enum: `error` Example: `error` |
| `serverTime` | string (date-time) | Yes | Server time in Coordinated Universal Time (UTC) Example: `2020-08-27T17:03:33.196Z` |

## Error Codes

- `accountInactive`: The Futures account the request refers to is inactive
- `apiLimitExceeded`: The API limit for the calling IP address has been exceeded
- `authenticationError`: The request could not be authenticated
- `insufficientFunds`: The amount requested for transfer is below the amount of funds available
- `invalidAccount`: The Futures account the transfer request refers to is invalid
- `invalidAmount`: The amount the transfer request refers to is invalid
- `invalidArgument`: One or more arguments provided are invalid
- `invalidUnit`: The unit the transfer request refers to is invalid
- `Json Parse Error`: The request failed to pass valid JSON as an argument
- `marketUnavailable`: The market is currently unavailable
- `nonceBelowThreshold`: The provided nonce is below the threshold
- `nonceDuplicate`: The provided nonce is a duplicate as it has been used in a previous request
- `notFound`: The requested information could not be found
- `requiredArgumentMissing`: One or more required arguments are missing
- `Server Error`: There was an error processing the request
- `Unavailable`: The endpoint being called is unavailable
- `unknownError`: An unknown error has occurred

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/openpositions" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "openPositions": [
    {
      "symbol": "<symbol>",
      "side": "long",
      "size": 0.0,
      "price": 0.0,
      "fillTime": "<fillTime>",
      "unrealizedFunding": null,
      "pnlCurrency": null,
      "maxFixedLeverage": null
    }
  ],
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Account Information
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `getOpenPositions`
