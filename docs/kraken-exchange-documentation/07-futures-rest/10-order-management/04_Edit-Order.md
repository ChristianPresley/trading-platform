# Edit Order

Source: [https://docs.kraken.com/api/docs/futures-api/trading/edit-order-spring](https://docs.kraken.com/api/docs/futures-api/trading/edit-order-spring)

## Endpoint

```
POST /editorder
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/editorder`

## Description

This endpoint allows editing an existing order for a currently listed Futures contract.

When editing an order, if the `trailingStopMaxDeviation` and `trailingStopDeviationUnit`
parameters are sent unchanged, the system will recalculate a new stop price upon successful
order modification.

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
| `processBefore` | string (date-time) | No | The time before which the request should be processed, otherwise it is rejected. Example: `2023-11-08T19:56:35.441899Z` |
| `orderId` | string | No | ID of the order you wish to edit. (Required if CliOrdId is not included) |
| `cliOrdId` | string | No | The order identity that is specified from the user. It must be globally unique (Required if orderId is not included) |
| `size` | number | No | The size associated with the order |
| `limitPrice` | number | No | The limit price associated with the order. Must not exceed the tick size of the contract. |
| `stopPrice` | number | No | The stop price associated with a stop order. Required if old orderType is stp. Must not exceed tick size of the contract. Note that for stp orders, limitPrice is also required and denotes the worst price at which the stp order can get filled. |
| `trailingStopMaxDeviation` | number | No | Only relevant for trailing stop orders. Maximum value of 50%, minimum value of 0.1% for 'PERCENT' 'maxDeviationUnit'.  Is the maximum distance the trailing stop's trigger price may trail behind the requested trigger signal. It defines the threshold at which the trigger price updates. |
| `trailingStopDeviationUnit` | string | No | Only relevant for trailing stop orders.  This defines how the trailing trigger price is calculated from the requested trigger signal. For example, if the max deviation is set to 10, the unit is 'PERCENT', and the underlying order is a sell, then the trigger price will never be more then 10% below the trigger signal. Similarly, if the deviation is 100, the unit is 'QUOTE_CURRENCY', the underlying order is a sell, and the contract is quoted in USD, then the trigger price will never be more than $100 below the trigger signal. Enum values: `PERCENT`, `QUOTE_CURRENCY` |
| `qtyMode` | string | No | Determines how the updated size is interpreted, defaulting to 'RELATIVE'.  'ABSOLUTE' means that the total order size, including past fills, is set to `size`. 'RELATIVE' means that the current open order size is set to `size`. Enum values: `ABSOLUTE`, `RELATIVE` |

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `editStatus` | object | Yes | A structure containing information on the send order request |
| &nbsp;&nbsp;`editStatus.orderId` | ['string', 'null'] | No | The unique identifier of the order |
| &nbsp;&nbsp;`editStatus.cliOrdId` | ['string', 'null'] | No | The unique client order identifier.  This field is returned only if the order has a client order ID. |
| &nbsp;&nbsp;`editStatus.orderEvents` | array[any] | Yes |  |
| &nbsp;&nbsp;`editStatus.receivedTime` | ['string', 'null'] | No | The date and time the order was received |
| &nbsp;&nbsp;`editStatus.status` | string | Yes | The status of the order, either of:  - `edited` - The order was edited successfully - `invalidSize` - The order was not placed because size is invalid - `invalidPrice` - The order was not placed because limitPrice and/or stopPrice are invalid - `insufficientAvailableFunds` - The order was not placed because available funds are insufficient - `selfFill` - The order was not placed because it would be filled against an existing order belonging to the same account - `tooManySmallOrders` - The order was not placed because the number of small open orders would exceed the permissible limit - `outsidePriceCollar` - The limit order crosses the spread but is an order of magnitude away from the mark price - fat finger control - `postWouldExecute` - The post-only order would be filled upon placement, thus is cancelled - `wouldNotReducePosition` - The edit cannot be applied because the reduce only policy is violated. (Only for reduceOnly orders) - `orderForEditNotFound` - The requested order for edit has not been found - `orderForEditNotAStop` - The supplied stopPrice cannot be applied because order is not a stop order Enum: `edited`, `invalidSize`, `invalidPrice`, `insufficientAvailableFunds`, `selfFill`, `tooManySmallOrders`, `outsidePriceCollar`, `postWouldExecute`, `wouldNotReducePosition`, `orderForEditNotFound`, `orderForEditNotAStop` |
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
curl -X POST "https://futures.kraken.com/derivatives/api/v3/editorder" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "editStatus": {
    "orderId": null,
    "cliOrdId": null,
    "orderEvents": [
      {
        "type": "PLACE",
        "order": {
          "orderId": "<orderId>",
          "cliOrdId": null,
          "type": "lmt",
          "symbol": "<symbol>",
          "side": "buy",
          "quantity": 0.0,
          "filled": 0.0,
          "limitPrice": 0.0,
          "reduceOnly": false,
          "timestamp": "<timestamp>",
          "lastUpdateTimestamp": "<lastUpdateTimestamp>"
        },
        "reducedQuantity": null
      }
    ],
    "receivedTime": null,
    "status": "edited"
  },
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Order Management
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `editOrderSpring`
