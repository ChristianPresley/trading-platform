# Cancel All Orders

Source: [https://docs.kraken.com/api/docs/futures-api/trading/cancel-all-orders](https://docs.kraken.com/api/docs/futures-api/trading/cancel-all-orders)

## Endpoint

```
POST /cancelallorders
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/cancelallorders`

## Description

This endpoint allows cancelling orders which are associated with a future's contract or a
margin account. If no arguments are specified all open orders will be cancelled.

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
| `symbol` | string | No | A futures product to cancel all open orders. |

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `cancelStatus` | object | Yes | A structure containing information on the cancellation request. |
| &nbsp;&nbsp;`cancelStatus.cancelOnly` | string | Yes | The symbol of the futures or all. |
| &nbsp;&nbsp;`cancelStatus.cancelledOrders` | array[object] | Yes | A list of structures containing all the successfully cancelled orders. |
| &nbsp;&nbsp;&nbsp;&nbsp;`cancelStatus.cancelledOrders[].cliOrdId` | ['string', 'null'] | No | Unique client order identifier. |
| &nbsp;&nbsp;&nbsp;&nbsp;`cancelStatus.cancelledOrders[].order_id` | string (uuid) | Yes | Order ID. |
| &nbsp;&nbsp;`cancelStatus.orderEvents` | array[object] | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`cancelStatus.orderEvents[].type` | string | Yes | Always `CANCEL`. Enum: `CANCEL` |
| &nbsp;&nbsp;&nbsp;&nbsp;`cancelStatus.orderEvents[].uid` | string | Yes | The UID associated with the order. |
| &nbsp;&nbsp;&nbsp;&nbsp;`cancelStatus.orderEvents[].order` | any | Yes |  |
| &nbsp;&nbsp;`cancelStatus.receivedTime` | string | Yes | The date and time the order cancellation was received. |
| &nbsp;&nbsp;`cancelStatus.status` | string | Yes | The status of the order cancellation:  - `cancelled` - successful cancellation - `noOrdersToCancel` - no open orders for cancellation Enum: `noOrdersToCancel`, `cancelled` |
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
curl -X POST "https://futures.kraken.com/derivatives/api/v3/cancelallorders" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "cancelStatus": {
    "cancelOnly": "<cancelOnly>",
    "cancelledOrders": [
      {
        "cliOrdId": null,
        "order_id": "<order_id>"
      }
    ],
    "orderEvents": [
      {
        "type": "CANCEL",
        "uid": "<uid>",
        "order": null
      }
    ],
    "receivedTime": "<receivedTime>",
    "status": "noOrdersToCancel"
  },
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Order Management
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `cancelAllOrders`
