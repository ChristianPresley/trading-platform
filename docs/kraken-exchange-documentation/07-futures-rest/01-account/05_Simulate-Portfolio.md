# Calculate Portfolio Margin, PNL and Greeks

Source: [https://docs.kraken.com/api/docs/futures-api/trading/simulate-portfolio](https://docs.kraken.com/api/docs/futures-api/trading/simulate-portfolio)

## Endpoint

```
POST /portfolio-margining/simulate
```

**Full URL:** `https://demo-futures.kraken.com/derivatives/api/v3/portfolio-margining/simulate`

## Description

For a given portfolio of balances and positions (futures and options), calculate the
margin requirements, pnl and option greeks.

Note: This is currently available exclusively in the Kraken Futures DEMO environment.

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

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `json` | any | Yes | Request body as a JSON string |

## Response Fields

### 200 - Simulated portfolio calculations

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `maintenanceMargin` | number (double) | Yes |  |
| `initialMargin` | number (double) | Yes |  |
| `pnl` | number (double) | Yes |  |
| `portfolioMarginBreakdown` | object | Yes | Breakdown of components that make up the portfolio margin calculation. |
| &nbsp;&nbsp;`portfolioMarginBreakdown.totalCrossAssetNettedMarketRisk` | number (double) | Yes |  |
| &nbsp;&nbsp;`portfolioMarginBreakdown.totalMarketRisk` | number (double) | Yes |  |
| &nbsp;&nbsp;`portfolioMarginBreakdown.totalScenarioPnls` | array[number (double)] | No |  |
| &nbsp;&nbsp;`portfolioMarginBreakdown.totalAbsoluteOptionPositionDeltaNotional` | number (double) | Yes |  |
| &nbsp;&nbsp;`portfolioMarginBreakdown.netPortfolioDelta` | number (double) | Yes |  |
| &nbsp;&nbsp;`portfolioMarginBreakdown.totalPremium` | number (double) | Yes |  |
| &nbsp;&nbsp;`portfolioMarginBreakdown.isBuyOnly` | boolean | Yes |  |
| &nbsp;&nbsp;`portfolioMarginBreakdown.futuresMaintenanceMargin` | number (double) | Yes |  |
| `greeks` | object | Yes |  |
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
curl -X POST "https://futures.kraken.com/derivatives/api/v3/portfolio-margining/simulate?json=<json>" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "maintenanceMargin": 0.0,
  "initialMargin": 0.0,
  "pnl": 0.0,
  "portfolioMarginBreakdown": {
    "totalCrossAssetNettedMarketRisk": 0.0,
    "totalMarketRisk": 0.0,
    "totalScenarioPnls": [],
    "totalAbsoluteOptionPositionDeltaNotional": 0.0,
    "netPortfolioDelta": 0.0,
    "totalPremium": 0.0,
    "isBuyOnly": false,
    "futuresMaintenanceMargin": 0.0
  },
  "greeks": {},
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Account Information
- **Server:** `https://demo-futures.kraken.com/derivatives/api/v3`
- **Operation ID:** `simulatePortfolio`
