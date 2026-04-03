# Send Order

Source: [https://docs.kraken.com/api/docs/futures-api/trading/send-order](https://docs.kraken.com/api/docs/futures-api/trading/send-order)

## Endpoint

```
POST /sendorder
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/sendorder`

## Description

This endpoint allows sending a limit, stop, take profit or immediate-or-cancel order for a
currently listed Futures contract.

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
| `orderType` | string | Yes | The order type:  - `lmt` - a limit order - `post` - a post-only limit order - `mkt` - an immediate-or-cancel order with 1% price protection - `stp` - a stop order - `take_profit` - a take profit order - `ioc` - an immediate-or-cancel order - `trailing_stop` - a trailing stop order - `fok` - fill or kill order Enum values: `lmt`, `post`, `ioc`, `mkt`, `stp`, `take_profit`, `trailing_stop`, `fok` |
| `symbol` | string | Yes | The symbol of the Futures |
| `side` | string | Yes | The direction of the order. Enum values: `buy`, `sell` |
| `size` | number | Yes | The size associated with the order. Note that different Futures have different contract sizes. |
| `limitPrice` | number | No | The limit price associated with the order. Note that for stop orders, limitPrice denotes the worst price at which the `stp` or `take_profit` order can get filled at. If no `limitPrice` is provided the `stp` or `take_profit` order will trigger a market order. If placing a `trailing_stop` order then leave undefined. |
| `stopPrice` | number | No | The stop price associated with a stop or take profit order.  Required if orderType is `stp` or `take_profit`, but if placing a `trailing_stop` then leave undefined. Note that for stop orders, limitPrice denotes the worst price at which the `stp` or `take_profit` order can get filled at. If no `limitPrice` is provided the `stp` or `take_profit` order will trigger a market order. |
| `cliOrdId` | string | No | The order identity that is specified from the user. It must be globally unique. Max length: 100 |
| `triggerSignal` | string | No | If placing a `stp`, `take_profit` or `trailing_stop`, the signal used for trigger.  - `mark` - the mark price - `index` - the index price - `last` - the last executed trade Enum values: `mark`, `index`, `last` |
| `reduceOnly` | boolean | No | Set as true if you wish the order to only reduce an existing position.  Any order which increases an existing position will be rejected. Default false. |
| `trailingStopMaxDeviation` | number | No | Required if the order type is `trailing_stop`. Maximum value of 50%, minimum value of 0.1% for 'PERCENT' 'maxDeviationUnit'.  Is the maximum distance the trailing stop's trigger price may trail behind the requested trigger signal. It defines the threshold at which the trigger price updates. |
| `trailingStopDeviationUnit` | string | No | Required if the order type is `trailing_stop`.  This defines how the trailing trigger price is calculated from the requested trigger signal. For example, if the max deviation is set to 10, the unit is 'PERCENT', and the underlying order is a sell, then the trigger price will never be more then 10% below the trigger signal. Similarly, if the deviation is 100, the unit is 'QUOTE_CURRENCY', the underlying order is a sell, and the contract is quoted in USD, then the trigger price will never be more than $100 below the trigger signal. Enum values: `PERCENT`, `QUOTE_CURRENCY` |
| `limitPriceOffsetValue` | number | No | Can only be set for triggers, e.g. order types `take_profit`, `stop` and `trailing_stop`. If set, `limitPriceOffsetUnit` must be set as well. This defines a relative limit price depending on the trigger `stopPrice`. The price is determined when the trigger is activated by the `triggerSignal`. The offset can be positive or negative, there might be restrictions on the value depending on the `limitPriceOffsetUnit`. |
| `limitPriceOffsetUnit` | string | No | Can only be set together with `limitPriceOffsetValue`. This defines the unit for the relative limit price distance from the trigger's `stopPrice`. Enum values: `QUOTE_CURRENCY`, `PERCENT` |
| `broker` | string (iiban) | No | Valid Broker IIBAN on whose behalf the order is sent. The format must follow the usual IIBAN pattern `XXXX YYYY ZZZZ WWWW` or machine pattern `XXXXYYYYZZZZWWWW`.  Note: This is currently available exclusively in the Kraken Futures DEMO environment. |

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sendStatus` | object | Yes | A structure containing information on the send order request. |
| &nbsp;&nbsp;`sendStatus.cliOrdId` | string | No | The unique client order identifier.  This field is returned only if the order has a client order ID. |
| &nbsp;&nbsp;`sendStatus.orderEvents` | array[any] | No |  |
| &nbsp;&nbsp;`sendStatus.order_id` | string (uuid) | No | The unique identifier of the order |
| &nbsp;&nbsp;`sendStatus.receivedTime` | string (date-time) | No | The date and time the order was received. |
| &nbsp;&nbsp;`sendStatus.status` | string | Yes | The status of the order, either of:  - `placed` - the order was placed successfully - `cancelled` - the order was cancelled successfully - `invalidOrderType` - the order was not placed because orderType is invalid - `invalidSide` - the order was not placed because side is invalid - `invalidSize` - the order was not placed because size is invalid - `invalidPrice` - the order was not placed because limitPrice and/or stopPrice are invalid - `insufficientAvailableFunds` - the order was not placed because available funds are insufficient - `selfFill` - the order was not placed because it would be filled against an existing order belonging to the same account - `tooManySmallOrders` - the order was not placed because the number of small open orders would exceed the permissible limit - `maxPositionViolation` - Order would cause you to exceed your maximum position in this contract. - `marketSuspended` - the order was not placed because the market is suspended - `marketInactive` - the order was not placed because the market is inactive - `clientOrderIdAlreadyExist` - the specified client id already exist - `clientOrderIdTooLong` - the client id is longer than the permissible limit - `outsidePriceCollar` - the order would have executed outside of the price collar for its order type - `postWouldExecute` - the post-only order would be filled upon placement, thus is cancelled - `iocWouldNotExecute` - the immediate-or-cancel order would not execute. - `wouldCauseLiquidation` - returned when a new order would fill at a worse price than the mark price, causing the portfolio value to fall below maintenance margin and triggering a liquidation. - `wouldNotReducePosition` - the reduce only order would not reduce position. - `wouldProcessAfterSpecifiedTime` - order would be processed after the time specified in `processBefore` parameter. Enum: `placed`, `partiallyFilled`, `filled`, `cancelled`, `edited`, `marketSuspended`, `marketInactive`, `invalidPrice`, `invalidSize`, `tooManySmallOrders`, `insufficientAvailableFunds`, `wouldCauseLiquidation`, `clientOrderIdAlreadyExist`, `clientOrderIdTooBig`, `maxPositionViolation`, `outsidePriceCollar`, `wouldIncreasePriceDislocation`, `notFound`, `orderForEditNotAStop`, `orderForEditNotFound`, `postWouldExecute`, `iocWouldNotExecute`, `selfFill`, `wouldNotReducePosition`, `marketIsPostOnly`, `tooManyOrders`, `fixedLeverageTooHigh`, `clientOrderIdInvalid`, `cannotEditTriggerPriceOfTrailingStop`, `cannotEditLimitPriceOfTrailingStop`, `wouldProcessAfterSpecifiedTime` |
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
curl -X POST "https://futures.kraken.com/derivatives/api/v3/sendorder?orderType=lmt&symbol=PF_XBTUSD&side=buy&size=1.0" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "sendStatus": {
    "cliOrdId": "<cliOrdId>",
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
    "order_id": "<order_id>",
    "receivedTime": "2024-01-01T00:00:00.000Z",
    "status": "placed"
  },
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Order Management
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `sendOrder`
