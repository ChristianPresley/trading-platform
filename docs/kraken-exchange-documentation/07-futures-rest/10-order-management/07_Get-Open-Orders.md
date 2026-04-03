# Get Open Orders

Source: [https://docs.kraken.com/api/docs/futures-api/trading/get-open-orders](https://docs.kraken.com/api/docs/futures-api/trading/get-open-orders)

## Endpoint

```
GET /openorders
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/openorders`

## Description

This endpoint returns information on all open orders for all Futures contracts.

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
| `openOrders` | array[object] | Yes | A list containing structures with information on open orders. The list is sorted descending by receivedTime. |
| &nbsp;&nbsp;`openOrders[].order_id` | string (uuid) | Yes | The unique identifier of the order. |
| &nbsp;&nbsp;`openOrders[].cliOrdId` | string | No | The unique client order identifier. This field is returned only if the order has a client order ID. |
| &nbsp;&nbsp;`openOrders[].status` | string | Yes | The status of the order:  - `untouched` - the entire size of the order is unfilled - `partiallyFilled` - the size of the order is partially but not entirely filled Enum: `untouched`, `partiallyFilled` |
| &nbsp;&nbsp;`openOrders[].side` | string | Yes | The direction of the order. Enum: `buy`, `sell` |
| &nbsp;&nbsp;`openOrders[].orderType` | string | Yes | The order type:  - `lmt` - limit order - `stp` - stop order - `take_profit` - take profit order Enum: `lmt`, `stop`, `take_profit` |
| &nbsp;&nbsp;`openOrders[].symbol` | string | Yes | The symbol of the futures to which the order refers. |
| &nbsp;&nbsp;`openOrders[].limitPrice` | number | No | The limit price associated with the order. |
| &nbsp;&nbsp;`openOrders[].stopPrice` | number | No | If orderType is `stp`: The stop price associated with the order  If orderType is `lmt`: Not returned because N/A |
| &nbsp;&nbsp;`openOrders[].filledSize` | number | Yes | The filled size associated with the order. |
| &nbsp;&nbsp;`openOrders[].unfilledSize` | number | No | The unfilled size associated with the order. |
| &nbsp;&nbsp;`openOrders[].reduceOnly` | boolean | Yes | Is the order a reduce only order or not. |
| &nbsp;&nbsp;`openOrders[].triggerSignal` | string | No | The trigger signal for the stop or take profit order. Enum: `mark`, `last`, `spot` |
| &nbsp;&nbsp;`openOrders[].lastUpdateTime` | string (date-time) | Yes | The date and time the order was last updated. |
| &nbsp;&nbsp;`openOrders[].receivedTime` | string (date-time) | Yes | The date and time the order was received. |
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
curl -X GET "https://futures.kraken.com/derivatives/api/v3/openorders" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "openOrders": [
    {
      "order_id": "<order_id>",
      "cliOrdId": "<cliOrdId>",
      "status": "untouched",
      "side": "buy",
      "orderType": "lmt",
      "symbol": "<symbol>",
      "limitPrice": 0.0,
      "stopPrice": 0.0,
      "filledSize": 0.0,
      "unfilledSize": 0.0,
      "reduceOnly": false,
      "triggerSignal": "mark",
      "lastUpdateTime": "2024-01-01T00:00:00.000Z",
      "receivedTime": "2024-01-01T00:00:00.000Z"
    }
  ],
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Order Management
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `getOpenOrders`
