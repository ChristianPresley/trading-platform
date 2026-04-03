# Get Tickers

Source: [https://docs.kraken.com/api/docs/futures-api/trading/get-tickers](https://docs.kraken.com/api/docs/futures-api/trading/get-tickers)

## Endpoint

```
GET /tickers
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/tickers`

## Description

This endpoint returns current market data for all currently listed Futures contracts and
indices.

## Authentication

This endpoint does not require authentication (public endpoint).

## Request Parameters

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `symbol` | array[string] | No | Market symbol(s) to filter tickers by.  Symbols are case-insensitive. Multi-value example: `?symbol=PF_BTCUSD&symbol=pf_ethusd` |

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `tickers` | array[any] | Yes | A list containing a structures for each available instrument. The list is in no particular order. |
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
curl -X GET "https://futures.kraken.com/derivatives/api/v3/tickers"
```

## Example Response

```json
{
  "tickers": [
    {
      "symbol": "PF_BTCUSD",
      "last": 12.03532,
      "lastTime": "<lastTime>",
      "lastSize": 0.0,
      "tag": "perpetual",
      "pair": "BTC:USD",
      "markPrice": 0.0,
      "bid": 0.0,
      "bidSize": 0.0,
      "ask": 0.0,
      "askSize": 0.0,
      "vol24h": 0.0,
      "volumeQuote": 0.0,
      "openInterest": 0.0,
      "open24h": 0.0,
      "high24h": 0.0,
      "low24h": 0.0,
      "extrinsicValue": 0.0,
      "fundingRate": 0.0,
      "fundingRatePrediction": 0.0,
      "suspended": false,
      "indexPrice": 0.0,
      "postOnly": false,
      "change24h": 0.0,
      "greeks": {
        "iv": 0.0,
        "delta": 0.0,
        "gamma": null,
        "vega": null,
        "theta": null,
        "rho": null
      },
      "isUnderlyingMarketClosed": false
    }
  ],
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Market Data
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `getTickers`
