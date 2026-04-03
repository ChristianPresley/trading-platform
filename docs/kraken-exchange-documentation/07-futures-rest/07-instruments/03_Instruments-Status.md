# Get Instrument Status List

Source: [https://docs.kraken.com/api/docs/futures-api/trading/instruments-status](https://docs.kraken.com/api/docs/futures-api/trading/instruments-status)

## Endpoint

```
GET /instruments/status
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/instruments/status`

## Description

Returns price dislocation and volatility details for all markets.

## Authentication

This endpoint does not require authentication (public endpoint).

## Request Parameters

This endpoint does not accept any parameters.

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `instrumentStatus` | array[object] | Yes |  |
| &nbsp;&nbsp;`instrumentStatus[].tradeable` | string | Yes | Market symbol Example: `PF_BTCUSD` |
| &nbsp;&nbsp;`instrumentStatus[].experiencingDislocation` | boolean | Yes |  |
| &nbsp;&nbsp;`instrumentStatus[].priceDislocationDirection` | ['string', 'null'] | Yes |  Enum: `ABOVE_UPPER_BOUND`, `BELOW_LOWER_BOUND` |
| &nbsp;&nbsp;`instrumentStatus[].experiencingExtremeVolatility` | boolean | Yes |  |
| &nbsp;&nbsp;`instrumentStatus[].extremeVolatilityInitialMarginMultiplier` | integer | Yes |  |
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
curl -X GET "https://futures.kraken.com/derivatives/api/v3/instruments/status"
```

## Example Response

```json
{
  "instrumentStatus": [
    {
      "tradeable": "PF_BTCUSD",
      "experiencingDislocation": false,
      "priceDislocationDirection": null,
      "experiencingExtremeVolatility": false,
      "extremeVolatilityInitialMarginMultiplier": 0
    }
  ],
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Instrument Details
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `instrumentsStatus`
