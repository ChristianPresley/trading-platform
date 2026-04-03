# Get Portfolio Margin Parameters

Source: [https://docs.kraken.com/api/docs/futures-api/trading/get-portfolio-margining-parameters](https://docs.kraken.com/api/docs/futures-api/trading/get-portfolio-margining-parameters)

## Endpoint

```
GET /portfolio-margining/parameters
```

**Full URL:** `https://demo-futures.kraken.com/derivatives/api/v3/portfolio-margining/parameters`

## Description

Retrieve current portfolio margin calculation parameters.

Also includes user specific limits related to options trading.

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

This endpoint does not accept any parameters.

## Response Fields

### 200 - Portfolio margining parameters

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `crossAssetNettingFactor` | number (double) | Yes |  Example: `12.03532` |
| `extremePriceShockMultiplier` | number (double) | Yes |  Example: `12.03532` |
| `volShockMultiplicationFactor` | number (double) | Yes |  Example: `12.03532` |
| `volShockExponentFactor` | number (double) | Yes |  Example: `12.03532` |
| `optionExpiryTimeShockHours` | number (uint64) | Yes |  |
| `optionsInitialMarginFactor` | number (double) | Yes |  Example: `12.03532` |
| `totalOptionOrdersConsideredInInitialMarginCalc` | number (uint64) | Yes |  |
| `priceShockLevels` | array[number (double)] | Yes |  |
| `optionsUserLimits` | object | Yes |  |
| &nbsp;&nbsp;`optionsUserLimits.maxNetPositionDelta` | number (double) | Yes |  Example: `12.03532` |
| &nbsp;&nbsp;`optionsUserLimits.limitsPerBaseCurrency` | object | Yes | User limits per option contract base currency |
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
curl -X GET "https://futures.kraken.com/derivatives/api/v3/portfolio-margining/parameters" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "crossAssetNettingFactor": 12.03532,
  "extremePriceShockMultiplier": 12.03532,
  "volShockMultiplicationFactor": 12.03532,
  "volShockExponentFactor": 12.03532,
  "optionExpiryTimeShockHours": 0.0,
  "optionsInitialMarginFactor": 12.03532,
  "totalOptionOrdersConsideredInInitialMarginCalc": 0.0,
  "priceShockLevels": [],
  "optionsUserLimits": {
    "maxNetPositionDelta": 12.03532,
    "limitsPerBaseCurrency": {}
  },
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Account Information
- **Server:** `https://demo-futures.kraken.com/derivatives/api/v3`
- **Operation ID:** `getPortfolioMarginingParameters`
