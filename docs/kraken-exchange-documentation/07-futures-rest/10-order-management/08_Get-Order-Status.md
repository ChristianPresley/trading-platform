# Get Specific Orders' Status

Source: [https://docs.kraken.com/api/docs/futures-api/trading/get-order-status](https://docs.kraken.com/api/docs/futures-api/trading/get-order-status)

## Endpoint

```
POST /orders/status
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/orders/status`

## Description

Returns information on specified orders which are open or were filled/cancelled in the last
5 seconds.

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
| `orderIds` | array[string (uuid)] | No | UIDs associated with orders or triggers. |
| `cliOrdIds` | array[string] | No | Client Order IDs associated with orders or triggers. Example: `['testOrder1', 'testOrder2']` |

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `orders` | array[object] | Yes |  |
| &nbsp;&nbsp;`orders[].order` | object | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.type` | string | Yes |  Enum: `TRIGGER_ORDER`, `ORDER` |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.orderId` | string (uuid) | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.cliOrdId` | ['string', 'null'] | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.symbol` | string | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.side` | string | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.quantity` | ['number', 'null'] | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.filled` | ['number', 'null'] | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.limitPrice` | ['number', 'null'] | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.reduceOnly` | boolean | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.timestamp` | string | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.lastUpdateTimestamp` | string | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.priceTriggerOptions` | any | Yes |  |
| &nbsp;&nbsp;&nbsp;&nbsp;`orders[].order.triggerTime` | ['string', 'null'] | Yes |  |
| &nbsp;&nbsp;`orders[].status` | string | Yes |  Enum: `ENTERED_BOOK`, `FULLY_EXECUTED`, `REJECTED`, `CANCELLED`, `TRIGGER_PLACED`, `TRIGGER_ACTIVATION_FAILURE` |
| &nbsp;&nbsp;`orders[].updateReason` | any | Yes |  |
| &nbsp;&nbsp;`orders[].error` | any | Yes |  |
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
curl -X POST "https://futures.kraken.com/derivatives/api/v3/orders/status" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "orders": [
    {
      "order": {
        "type": "TRIGGER_ORDER",
        "orderId": "<orderId>",
        "cliOrdId": null,
        "symbol": "<symbol>",
        "side": "<side>",
        "quantity": null,
        "filled": null,
        "limitPrice": null,
        "reduceOnly": false,
        "timestamp": "<timestamp>",
        "lastUpdateTimestamp": "<lastUpdateTimestamp>",
        "priceTriggerOptions": null,
        "triggerTime": null
      },
      "status": "ENTERED_BOOK",
      "updateReason": null,
      "error": null
    }
  ],
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Order Management
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `getOrderStatus`
