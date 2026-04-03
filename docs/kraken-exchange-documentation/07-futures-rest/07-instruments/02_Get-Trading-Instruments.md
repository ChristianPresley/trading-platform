# Get Trading Instruments

Source: [https://docs.kraken.com/api/docs/futures-api/trading/get-trading-instruments](https://docs.kraken.com/api/docs/futures-api/trading/get-trading-instruments)

## Endpoint

```
GET /trading/instruments
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/trading/instruments`

## Description

Returns specifications for all currently accessible markets and indices.

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
| `instruments` | array[object] | Yes | A list containing structures for each available instrument. The list is in no particular order. |
| &nbsp;&nbsp;`instruments[].fundingRateCoefficient` | number (double) | No | Funding rate coefficient.  Only present for perpetual markets. Example: `12.03532` |
| &nbsp;&nbsp;`instruments[].lastTradingTime` | string (date-time) | No | Market expiry date-time (UTC).  Only present for fixed maturity markets. |
| &nbsp;&nbsp;`instruments[].minimumTradeSize` | number (double) | Yes | TODO: Not populated for any markets (at time of writing in Apr 2025). Example: `12.03532` |
| &nbsp;&nbsp;`instruments[].impactMidSize` | number (double) | Yes | Book depth used to calculate (impact) mid prices. Example: `12.03532` |
| &nbsp;&nbsp;`instruments[].maxPositionSize` | number (double) | Yes | Market-wide position size limit. Example: `12.03532` |
| &nbsp;&nbsp;`instruments[].openingDate` | string (date-time) | Yes | Date-time (UTC) that market was created. |
| &nbsp;&nbsp;`instruments[].marginLevels` | array[object] | No | Margin schedule applicable to logged-in account.  Only present for futures markets. |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].marginLevels[].contracts` | integer (uint64) | No | Position size/level to apply IM/MM rules within a single-collateral margin schedule. |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].marginLevels[].numNonContractUnits` | number (double) | No | Position size/level to apply IM/MM rules within a multi-collateral margin schedule. Example: `12.03532` |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].marginLevels[].initialMargin` | number (double) | Yes | Initial margin (IM) rate. Example: `12.03532` |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].marginLevels[].maintenanceMargin` | number (double) | Yes | Maintenance margin (MM) rate. Example: `12.03532` |
| &nbsp;&nbsp;`instruments[].maxRelativeFundingRate` | number (double) | No | Maximum relative funding rate.  Only present for perpetual markets. Example: `12.03532` |
| &nbsp;&nbsp;`instruments[].symbol` | number (double) | Yes |  Example: `12.03532` |
| &nbsp;&nbsp;`instruments[].pair` | string | Yes | Asset pair (uppercase, colon separated). Example: `BTC:USD` |
| &nbsp;&nbsp;`instruments[].base` | string | Yes | Base asset (uppercase). Example: `BTC` |
| &nbsp;&nbsp;`instruments[].quote` | string | Yes | Quote asset (uppercase). Example: `USD` |
| &nbsp;&nbsp;`instruments[].tickSize` | number (double) | Yes | Minimum order price increment. Example: `12.03532` |
| &nbsp;&nbsp;`instruments[].type` | string | Yes | Market type. Enum: `futures_inverse`, `futures_vanilla`, `flexible_futures`, `options` |
| &nbsp;&nbsp;`instruments[].underlying` | string | No | Underlying index code.  Only present for single-collateral markets. |
| &nbsp;&nbsp;`instruments[].isin` | ['string', 'null'] | Yes | International Securities Identification Number (ISIN). |
| &nbsp;&nbsp;`instruments[].contractMinimumTradePrecision` | integer | Yes | Minimum order quantity increment.  E.g., a trade precision of 2 means order quantities are not allowed to be more precise than the hundredth decimal place (0.01).  These values can be negative to specify quantity increments of 10 (-1), 100 (-2), etc. |
| &nbsp;&nbsp;`instruments[].postOnly` | boolean | Yes | True if market is in post-only mode. |
| &nbsp;&nbsp;`instruments[].feeScheduleUid` | string (uuid) | Yes | Fee schedule UID. |
| &nbsp;&nbsp;`instruments[].optionType` | string | No | Option type.  Only present for options markets. Enum: `call`, `put` |
| &nbsp;&nbsp;`instruments[].strikePrice` | number (double) | No | Strike price.  Only present for options markets. Example: `12.03532` |
| &nbsp;&nbsp;`instruments[].underlyingFuture` | string | No | Underlying futures market.  Only present for options markets. |
| &nbsp;&nbsp;`instruments[].rebateLevels` | object | Yes | Maps market share percentage levels to rebate percentages.  Keys and values are decimal strings.  |
| &nbsp;&nbsp;`instruments[].mtf` | boolean | Yes | True if this market is provided under the MTF license. |
| &nbsp;&nbsp;`instruments[].tradfi` | boolean | Yes | True if this is a non-crypto market. |
| &nbsp;&nbsp;`instruments[].restricted` | boolean | Yes | True if the account is restricted (to position-reducing orders) on this market. |
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
curl -X GET "https://futures.kraken.com/derivatives/api/v3/trading/instruments" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "instruments": [
    {
      "fundingRateCoefficient": 12.03532,
      "lastTradingTime": "2024-01-01T00:00:00.000Z",
      "minimumTradeSize": 12.03532,
      "impactMidSize": 12.03532,
      "maxPositionSize": 12.03532,
      "openingDate": "2024-01-01T00:00:00.000Z",
      "marginLevels": [
        {
          "contracts": 0,
          "numNonContractUnits": 12.03532,
          "initialMargin": 12.03532,
          "maintenanceMargin": 12.03532
        }
      ],
      "maxRelativeFundingRate": 12.03532,
      "symbol": 12.03532,
      "pair": "BTC:USD",
      "base": "BTC",
      "quote": "USD",
      "tickSize": 12.03532,
      "type": "futures_inverse",
      "underlying": "<underlying>",
      "isin": null,
      "contractMinimumTradePrecision": 0,
      "postOnly": false,
      "feeScheduleUid": "<feeScheduleUid>",
      "optionType": "call",
      "strikePrice": 12.03532,
      "underlyingFuture": "<underlyingFuture>",
      "rebateLevels": {},
      "mtf": false,
      "tradfi": false,
      "restricted": false
    }
  ],
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Instrument Details
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `getTradingInstruments`
