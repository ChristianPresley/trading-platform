# Batch Order Management

Source: [https://docs.kraken.com/api/docs/futures-api/trading/send-batch-order](https://docs.kraken.com/api/docs/futures-api/trading/send-batch-order)

## Endpoint

```
POST /batchorder
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/batchorder`

## Description

This endpoint allows sending limit or stop order(s) and/or cancelling open order(s) and/or
editing open order(s) for a currently listed Futures contract in batch.

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

This endpoint does not accept any parameters.

### Request Body

**Content-Type:** `application/x-www-form-urlencoded`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ProcessBefore` | any | No | The time before which the request should be processed, otherwise it is rejected. Example: `2023-11-08T19:56:35.441899Z` |
| `json` | object | Yes | :::info This parameter is required to be encoded as a json string. ::: |
| &nbsp;&nbsp;`json.batchOrder` | array[any] | Yes | A list containing structures of order sending and order cancellation instructions. The list is in no particular order. |

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `batchStatus` | array[object] | Yes | A structure containing information on the send order request. |
| &nbsp;&nbsp;`batchStatus[].cliOrdId` | string | No | The unique client order identifier. This field is returned only if the order has a client order ID. |
| &nbsp;&nbsp;`batchStatus[].dateTimeReceived` | ['string', 'null'] | No | The date and time the order was received. |
| &nbsp;&nbsp;`batchStatus[].orderEvents` | array[any] | Yes |  |
| &nbsp;&nbsp;`batchStatus[].order_id` | ['string', 'null'] | No | The unique identifier of the order. |
| &nbsp;&nbsp;`batchStatus[].order_tag` | ['string', 'null'] | No | The arbitrary string provided client-side when the order was sent for the purpose of mapping order sending instructions to the API's response. |
| &nbsp;&nbsp;`batchStatus[].status` | string | Yes | The status of the order:  - `placed` - the order was placed successfully - `cancelled` - the order was cancelled successfully - `invalidOrderType` - the order was not placed because orderType is invalid - `invalidSide` - the order was not placed because side is invalid - `invalidSize` - the order was not placed because size is invalid - `invalidPrice` - the order was not placed because limitPrice and/or stopPrice are invalid - `insufficientAvailableFunds` - the order was not placed because available funds are insufficient - `selfFill` - the order was not placed because it would be filled against an existing order belonging to the same account - `tooManySmallOrders` - the order was not placed because the number of small open orders would exceed the permissible limit - `marketSuspended` - the order was not placed because the market is suspended - `marketInactive` - the order was not placed because the market is inactive - `clientOrderIdAlreadyExist` - the specified client ID already exist - `clientOrderIdTooLong` - the client ID is longer than the permissible limit - `outsidePriceCollar` - the limit order crosses the spread but is an order of magnitude away from the mark price - fat finger control - `postWouldExecute` - the post-only order would be filled upon placement, thus is  cancelled - `iocWouldNotExecute` - the immediate-or-cancel order would not execute Enum: `placed`, `edited`, `cancelled`, `invalidOrderType`, `invalidSide`, `invalidSize`, `invalidPrice`, `insufficientAvailableFunds`, `selfFill`, `tooManySmallOrders`, `marketSuspended`, `marketInactive`, `clientOrderIdAlreadyExist`, `clientOrderIdTooLong`, `outsidePriceCollar`, `postWouldExecute`, `iocWouldNotExecute` |
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
curl -X POST "https://futures.kraken.com/derivatives/api/v3/batchorder" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "batchStatus": [
    {
      "cliOrdId": "<cliOrdId>",
      "dateTimeReceived": null,
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
      "order_id": null,
      "order_tag": null,
      "status": "placed"
    }
  ],
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Order Management
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `sendBatchOrder`
