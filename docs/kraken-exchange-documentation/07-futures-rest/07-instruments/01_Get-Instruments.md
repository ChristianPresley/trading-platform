# Get Instruments

Source: [https://docs.kraken.com/api/docs/futures-api/trading/get-instruments](https://docs.kraken.com/api/docs/futures-api/trading/get-instruments)

## Endpoint

```
GET /instruments
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/instruments`

## Description

Returns specifications for all currently listed markets and indices.

## Authentication

This endpoint does not require authentication (public endpoint).

## Request Parameters

This endpoint does not accept any parameters.

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `instruments` | array[object] | Yes | A list containing structures for each available instrument. The list is in no particular order. |
| &nbsp;&nbsp;`instruments[].category` | string | No | 'Category of the contract: "Layer 1", "Layer 2", "DeFi", or "Privacy" (multi-collateral contracts only).' |
| &nbsp;&nbsp;`instruments[].contractSize` | number | No | The contract size of the Futures. |
| &nbsp;&nbsp;`instruments[].contractValueTradePrecision` | number | No | Trade precision for the contract (e.g. trade precision of 2 means trades are precise to the hundredth decimal place 0.01). |
| &nbsp;&nbsp;`instruments[].fundingRateCoefficient` | number | No |  |
| &nbsp;&nbsp;`instruments[].impactMidSize` | number | No | Amount of contract used to calculated the mid price for the mark price. |
| &nbsp;&nbsp;`instruments[].isin` | string | No | International Securities Identification Number (ISIN) |
| &nbsp;&nbsp;`instruments[].lastTradingTime` | string (date-time) | No |  |
| &nbsp;&nbsp;`instruments[].marginSchedules` | object | No | A map containing margin schedules by platform. |
| &nbsp;&nbsp;`instruments[].retailMarginLevels` | array[object] | No | Margin levels for retail clients. |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].retailMarginLevels[].contracts` | ['integer', 'null'] (int64) | No | For futures: The lower limit of the number of contracts to which this margin level applies  For indices: Not returned because N/A |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].retailMarginLevels[].numNonContractUnits` | ['number', 'null'] (double) | No | For futures: The lower limit of the number of non-contract units (i.e. quote currency units for linear futures) to which this margin level applies  For indices: Not returned because N/A.  |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].retailMarginLevels[].initialMargin` | number | Yes | For futures: The initial margin requirement for this level  For indices: Not returned because N/A |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].retailMarginLevels[].maintenanceMargin` | number | Yes | For futures: The maintenance margin requirement for this level  For indices: Not returned because N/A |
| &nbsp;&nbsp;`instruments[].marginLevels` | array[object] | No | Margin levels for professional clients. |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].marginLevels[].contracts` | ['integer', 'null'] (int64) | No | For futures: The lower limit of the number of contracts to which this margin level applies  For indices: Not returned because N/A |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].marginLevels[].numNonContractUnits` | ['number', 'null'] (double) | No | For futures: The lower limit of the number of non-contract units (i.e. quote currency units for linear futures) to which this margin level applies  For indices: Not returned because N/A.  |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].marginLevels[].initialMargin` | number | Yes | For futures: The initial margin requirement for this level  For indices: Not returned because N/A |
| &nbsp;&nbsp;&nbsp;&nbsp;`instruments[].marginLevels[].maintenanceMargin` | number | Yes | For futures: The maintenance margin requirement for this level  For indices: Not returned because N/A |
| &nbsp;&nbsp;`instruments[].maxPositionSize` | number | No | Maximum number of contracts that one can hold in a position |
| &nbsp;&nbsp;`instruments[].maxRelativeFundingRate` | number | No | Perpetuals only: the absolute value of the maximum permissible funding rate |
| &nbsp;&nbsp;`instruments[].openingDate` | string (date-time) | No | When the contract was first available for trading |
| &nbsp;&nbsp;`instruments[].postOnly` | boolean | No | True if the instrument is in post-only mode, false otherwise. |
| &nbsp;&nbsp;`instruments[].feeScheduleUid` | string | No | Unique identifier of fee schedule associated with the instrument |
| &nbsp;&nbsp;`instruments[].symbol` | string | Yes | Market symbol. Example: `PF_BTCUSD` |
| &nbsp;&nbsp;`instruments[].pair` | string | No | Asset pair. Example: `BTC:USD` |
| &nbsp;&nbsp;`instruments[].base` | string | No | Base asset. Example: `BTC` |
| &nbsp;&nbsp;`instruments[].quote` | string | No | Quote asset. Example: `USD` |
| &nbsp;&nbsp;`instruments[].tags` | array[string] | No | Tag for the contract (currently does not return a value). |
| &nbsp;&nbsp;`instruments[].tickSize` | number | No | Tick size of the contract being traded. |
| &nbsp;&nbsp;`instruments[].tradeable` | boolean | Yes | True if the instrument can be traded, False otherwise. |
| &nbsp;&nbsp;`instruments[].type` | string | No | The type of the instrument:  - `flexible_futures` - `futures_inverse` - `futures_vanilla` Enum: `flexible_futures`, `futures_inverse`, `futures_vanilla` |
| &nbsp;&nbsp;`instruments[].underlying` | string | No | The underlying of the Futures. |
| &nbsp;&nbsp;`instruments[].underlyingFuture` | string | No | For options: The underlying future of the option. Otherwise null. |
| &nbsp;&nbsp;`instruments[].tradfi` | boolean | Yes | True if this is a non-crypto market. |
| &nbsp;&nbsp;`instruments[].mtf` | boolean | No | True if currently has MTF status. |
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
curl -X GET "https://futures.kraken.com/derivatives/api/v3/instruments"
```

## Example Response

```json
{
  "instruments": [
    {
      "category": "<category>",
      "contractSize": 0.0,
      "contractValueTradePrecision": 0.0,
      "fundingRateCoefficient": 0.0,
      "impactMidSize": 0.0,
      "isin": "<isin>",
      "lastTradingTime": "2024-01-01T00:00:00.000Z",
      "marginSchedules": {},
      "retailMarginLevels": [
        {
          "contracts": null,
          "numNonContractUnits": null,
          "initialMargin": 0.0,
          "maintenanceMargin": 0.0
        }
      ],
      "marginLevels": [
        {
          "contracts": null,
          "numNonContractUnits": null,
          "initialMargin": 0.0,
          "maintenanceMargin": 0.0
        }
      ],
      "maxPositionSize": 0.0,
      "maxRelativeFundingRate": 0.0,
      "openingDate": "2024-01-01T00:00:00.000Z",
      "postOnly": false,
      "feeScheduleUid": "<feeScheduleUid>",
      "symbol": "PF_BTCUSD",
      "pair": "BTC:USD",
      "base": "BTC",
      "quote": "USD",
      "tags": [],
      "tickSize": 0.0,
      "tradeable": false,
      "type": "flexible_futures",
      "underlying": "<underlying>",
      "underlyingFuture": "<underlyingFuture>",
      "tradfi": false,
      "mtf": false
    }
  ],
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Instrument Details
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `getInstruments`
