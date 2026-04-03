# Cancel Order

Source: [https://docs.kraken.com/api/docs/futures-api/trading/cancel-order](https://docs.kraken.com/api/docs/futures-api/trading/cancel-order)

## Endpoint

```
POST /cancelorder
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/cancelorder`

## Description

This endpoint allows cancelling an open order for a Futures contract.

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
| `order_id` | string | No | The unique identifier of the order to be cancelled. |
| `cliOrdId` | string | No | The client unique identifier of the order to be cancelled. |

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `cancelStatus` | object | Yes | A structure containing information on the cancellation request. |
| &nbsp;&nbsp;`cancelStatus.cliOrdId` | ['string', 'null'] | No | The client order ID. Shown only if client specified one. |
| &nbsp;&nbsp;`cancelStatus.orderEvents` | array[any] | No |  |
| &nbsp;&nbsp;`cancelStatus.order_id` | string (uuid) | No | The cancelled order UID |
| &nbsp;&nbsp;`cancelStatus.receivedTime` | string | No | The date and time the order cancellation was received. |
| &nbsp;&nbsp;`cancelStatus.status` | string | Yes | The status of the order cancellation:  - `cancelled` - The order has been cancelled. This may only be part of the order as part may have been filled. Check open_orders websocket feed for status of the order. - `filled` - The order was found completely filled and could not be cancelled - `notFound` - The order was not found, either because it had already been cancelled or it never existed Enum: `cancelled`, `filled`, `notFound` |
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
curl -X POST "https://futures.kraken.com/derivatives/api/v3/cancelorder" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "cancelStatus": {
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
    "order_id": "<order_id>",
    "receivedTime": "<receivedTime>",
    "status": "cancelled"
  },
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Order Management
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `cancelOrder`
