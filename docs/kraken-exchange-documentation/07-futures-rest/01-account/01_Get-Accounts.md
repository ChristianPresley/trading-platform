# Get Wallets (Accounts)

Source: [https://docs.kraken.com/api/docs/futures-api/trading/get-accounts](https://docs.kraken.com/api/docs/futures-api/trading/get-accounts)

## Endpoint

```
GET /accounts
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/accounts`

## Description

This endpoint returns key information relating to all your accounts which may either be
cash accounts or margin accounts. This includes digital asset balances, instrument balances,
margin requirements, margin trigger estimates and auxiliary information such as available
funds, PnL of open positions and portfolio value.

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
| `accounts` | object | Yes | A structure containing structures with account-related information for all margin and cash accounts. |
| &nbsp;&nbsp;`accounts.cash` | object | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.cash.type` | string | Yes | The type of the account (always "cashAccount"). Enum: `cashAccount` |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.cash.balances` | object | Yes | A structure containing account balances. |
| &nbsp;&nbsp;`accounts.flex` | object | Yes | Structure showing multi-collateral wallet details. |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.type` | string | No | The type of the account (always multiCollateralMarginAccount) Enum: `multiCollateralMarginAccount` |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.currencies` | object | Yes | Structure with collateral currency details. |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.initialMargin` | number | Yes | Total initial margin held for open positions (USD). |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.initialMarginWithOrders` | number | Yes | Total initial margin held for open positions and open orders (USD). |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.maintenanceMargin` | number | Yes | Total maintenance margin held for open positions (USD). |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.balanceValue` | number | Yes | USD value of all collateral in multi-collateral wallet. |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.portfolioValue` | number | Yes | Balance value plus unrealised PnL in USD. |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.collateralValue` | number | Yes | USD value of balances in account usable for margin (Balance Value * Haircut). |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.pnl` | number | Yes | Unrealised PnL in USD. |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.unrealizedFunding` | number | Yes | Unrealised funding from funding rate (USD). |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.totalUnrealized` | number | Yes | Total USD value of unrealised funding and unrealised PnL. |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.totalUnrealizedAsMargin` | number | Yes | Unrealised pnl and unrealised funding that is usable as margin `[(Unrealised Profit/Loss + Unrealised Funding Rate) * Haircut - Conversion Fee]`. |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.availableMargin` | number | Yes | Margin Equity - Total Initial Margin. |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.marginEquity` | number | Yes | `[Balance Value in USD * (1-Haircut)] + (Total Unrealised Profit/Loss as Margin in USD)` |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.portfolioMarginBreakdown` | object | No | Breakdown of portfolio margin components. |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.portfolioMarginBreakdown.totalCrossAssetNettedMarketRisk` | number (double) | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.portfolioMarginBreakdown.totalMarketRisk` | number (double) | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.portfolioMarginBreakdown.totalScenarioPnls` | array[number (double)] | No |  |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.portfolioMarginBreakdown.totalAbsoluteOptionPositionDeltaNotional` | number (double) | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.portfolioMarginBreakdown.netPortfolioDelta` | number (double) | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.portfolioMarginBreakdown.totalPremium` | number (double) | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.portfolioMarginBreakdown.isBuyOnly` | boolean | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.portfolioMarginBreakdown.futuresMaintenanceMargin` | number (double) | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`accounts.flex.upnlInterestRate` | ['number', 'null'] | No | Interest rate applied to unrealized profit/loss. |
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
curl -X GET "https://futures.kraken.com/derivatives/api/v3/accounts" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "accounts": {
    "cash": {
      "type": "cashAccount",
      "balances": {}
    },
    "flex": {
      "type": "multiCollateralMarginAccount",
      "currencies": {},
      "initialMargin": 0.0,
      "initialMarginWithOrders": 0.0,
      "maintenanceMargin": 0.0,
      "balanceValue": 0.0,
      "portfolioValue": 0.0,
      "collateralValue": 0.0,
      "pnl": 0.0,
      "unrealizedFunding": 0.0,
      "totalUnrealized": 0.0,
      "totalUnrealizedAsMargin": 0.0,
      "availableMargin": 0.0,
      "marginEquity": 0.0,
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
      "upnlInterestRate": null
    }
  },
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Account Information
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `getAccounts`
