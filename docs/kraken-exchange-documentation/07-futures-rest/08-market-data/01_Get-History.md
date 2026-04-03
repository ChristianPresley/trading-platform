# Get Trade History

Source: [https://docs.kraken.com/api/docs/futures-api/trading/get-history](https://docs.kraken.com/api/docs/futures-api/trading/get-history)

## Endpoint

```
GET /history
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/history`

## Description

This endpoint returns the most recent 100 trades prior to the specified `lastTime` value up
to past 7 days or recent trading engine restart (whichever is sooner).

If no `lastTime` specified, it will return 100 most recent trades.

## Authentication

This endpoint does not require authentication (public endpoint).

## Request Parameters

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `symbol` | string | Yes | The symbol of the Futures. |
| `lastTime` | string | No | Returns the last 100 trades from the specified lastTime value. |

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `history` | array[object] | Yes | A list containing structures with historical price information. The list is sorted descending by time. |
| &nbsp;&nbsp;`history[].price` | number | Yes | For futures: The price of a fill  For indices: The calculated value |
| &nbsp;&nbsp;`history[].side` | string | No | The classification of the taker side in the matched trade: "buy" if the taker is a buyer, "sell" if the taker is a seller. |
| &nbsp;&nbsp;`history[].size` | string | No | For futures: The size of a fill For indices: Not returned because N/A |
| &nbsp;&nbsp;`history[].time` | string | Yes | The date and time of a trade or an index computation  For futures: The date and time of a trade. Data is not aggregated For indices: The date and time of an index computation. For real-time indices, data is aggregated to the last computation of each full hour. For reference rates, data is not aggregated |
| &nbsp;&nbsp;`history[].trade_id` | integer (int32) | No | For futures: A continuous index starting at 1 for the first fill in a Futures contract maturity For indices: Not returned because N/A |
| &nbsp;&nbsp;`history[].type` | string | No | The classification of the matched trade in an orderbook:  - `fill` - it is a normal buyer and seller - `liquidation` - it is a result of a user being liquidated from their position - `assignment` - the fill is the result of a users position being assigned to a marketmaker - `termination` - it is a result of a user being terminated - `block` - it is an element of a block trade Enum: `fill`, `liquidation`, `assignment`, `termination`, `block` |
| &nbsp;&nbsp;`history[].uid` | string | No |  |
| &nbsp;&nbsp;`history[].instrument_identification_type` | string | No |  |
| &nbsp;&nbsp;`history[].isin` | string | No |  |
| &nbsp;&nbsp;`history[].execution_venue` | string | No |  |
| &nbsp;&nbsp;`history[].price_notation` | string | No |  |
| &nbsp;&nbsp;`history[].price_currency` | string | No |  |
| &nbsp;&nbsp;`history[].notional_amount` | number | No |  |
| &nbsp;&nbsp;`history[].notional_currency` | string | No |  |
| &nbsp;&nbsp;`history[].publication_time` | string | No |  |
| &nbsp;&nbsp;`history[].publication_venue` | string | No |  |
| &nbsp;&nbsp;`history[].transaction_identification_code` | string | No |  |
| &nbsp;&nbsp;`history[].to_be_cleared` | boolean | No |  |
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
curl -X GET "https://futures.kraken.com/derivatives/api/v3/history?symbol=PF_XBTUSD"
```

## Example Response

```json
{
  "history": [
    {
      "price": 0.0,
      "side": "<side>",
      "size": "<size>",
      "time": "<time>",
      "trade_id": 0,
      "type": "fill",
      "uid": "<uid>",
      "instrument_identification_type": "<instrument_identification_type>",
      "isin": "<isin>",
      "execution_venue": "<execution_venue>",
      "price_notation": "<price_notation>",
      "price_currency": "<price_currency>",
      "notional_amount": 0.0,
      "notional_currency": "<notional_currency>",
      "publication_time": "<publication_time>",
      "publication_venue": "<publication_venue>",
      "transaction_identification_code": "<transaction_identification_code>",
      "to_be_cleared": false
    }
  ],
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Market Data
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `getHistory`
