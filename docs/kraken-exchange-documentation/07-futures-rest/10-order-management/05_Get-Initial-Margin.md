# Get Initial Margin Requirements

Source: [https://docs.kraken.com/api/docs/futures-api/trading/get-initial-margin](https://docs.kraken.com/api/docs/futures-api/trading/get-initial-margin)

## Endpoint

```
GET /initialmargin
```

**Full URL:** `https://futures.kraken.com/derivatives/api/v3/initialmargin`

## Description

Returns initial margin requirements based on given order parameters.

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
| `orderType` | string | Yes | The order type: - `lmt` - a limit order - `mkt` - an immediate-or-cancel order with 1% price protection Enum values: `lmt`, `mkt` |
| `symbol` | string | Yes | The symbol of the Futures. |
| `side` | string | Yes | The direction of the order. Enum values: `buy`, `sell` |
| `size` | number | Yes | The size associated with the order. |
| `limitPrice` | number | No | The limit price associated with the order. |

## Response Fields

### 200

#### Success Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `initialMargin` | number | No | The initial margin requirement or null if there is no market. |
| `estimatedLiquidationThreshold` | number | No | The estimated liquidation price after execution. |
| `price` | number | No | The limit price of the order or null if the order type was `mkt` and there is no market. |
| `error` | string | No | An order error if the margin calculation could not be performed. Enum values: `MARKET_SUSPENDED`, `MARKET_NOT_FOUND`, `INVALID_PRICE`, `INVALID_QUANTITY`, `SMALL_ORDER_LIMIT_EXCEEDED`, `INSUFFICIENT_MARGIN`, `WOULD_CAUSE_LIQUIDATION`, `CLIENT_ORDER_ID_IN_USE`, `CLIENT_ORDER_ID_TOO_LONG`, `MAX_POSITION_EXCEEDED`, `PRICE_COLLAR`, `PRICE_DISLOCATION`, `EDIT_HAS_NO_EFFECT`, `ORDER_FOR_CANCELLATION_NOT_FOUND`, `ORDER_FOR_EDIT_NOT_FOUND`, `ORDER_CANNOT_HAVE_TRIGGER_PRICE`, `POST_WOULD_EXECUTE`, `IOC_WOULD_NOT_EXECUTE`, `WOULD_EXECUTE_SELF`, `WOULD_NOT_REDUCE_POSITION`, `REJECTED_AFTER_EXECUTION`, `MARKET_IS_POST_ONLY`, `ORDER_LIMIT_EXCEEDED`, `FIXED_LEVERAGE_TOO_HIGH`, `CANNOT_EDIT_TRIGGER_PRICE_OF_TRAILING_STOP`, `CANNOT_EDIT_LIMIT_PRICE_OF_TRAILING_STOP`, `TRAILING_STOP_ORDER_LIMIT_EXCEEDED`, `TRAILING_STOP_PERCENT_DEVIATION_EXCEEDS_MAX_DECIMAL_PLACES`, `TRAILING_STOP_QUOTE_DEVIATION_NOT_MULTIPLE_OF_TICK_SIZE`, `TRAILING_STOP_MAX_DEVIATION_TOO_LARGE`, `TRAILING_STOP_MAX_DEVIATION_TOO_SMALL`, `INSUFFICIENT_HEADROOM_AROUND_CURRENT_PRICE_TO_EDIT_TRAILING_STOP`, `NO_REFERENCE_PRICE_AVAILABLE_FOR_CALCULATING_TRAILING_STOP_TRIGGER_PRICE`, `INSUFFICIENT_CLOSING_MARGIN`, `LIMIT_PRICE_SET_AS_ABSOLUTE_AND_RELATIVE`, `LIMIT_PRICE_OFFSET_VALUE_INVALID`, `LIMIT_PRICE_OFFSET_UNIT_INVALID`, `LIMIT_PRICE_OFFSET_MUST_HAVE_VALUE_AND_UNIT`, `LIMIT_PRICE_OFFSET_QUOTE_CURRENCY_VALUE_MUST_BE_MULTIPLE_OF_TICK_SIZE`, `LIMIT_PRICE_OFFSET_PERCENT_VALUE_TOO_MANY_DECIMAL_PLACES`, `LIMIT_PRICE_OFFSET_TOO_HIGH`, `LIMIT_PRICE_OFFSET_TOO_LOW` |
| `result` | string | Yes | Enum: `success` Example: `success` |
| `serverTime` | string (date-time) | Yes | Server time in Coordinated Universal Time (UTC) Example: `2020-08-27T17:03:33.196Z` |

#### ErrorResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `errors` | array[string] | No |  |
| `error` | string | Yes | Error description.   - `accountInactive`: The Futures account the request refers to is inactive   - `apiLimitExceeded`: The API limit for the calling IP address has been exceeded   - `authenticationError`: The request could not be authenticated   - `insufficientFunds`: The amount requested for transfer is below the amount of funds available   - `invalidAccount`: The Futures account the transfer request refers to is invalid   - `invalidAmount`: The amount the transfer request refers to is invalid   - `invalidArgument`: One or more arguments provided are invalid   - `invalidUnit`: The unit the transfer request refers to is invalid   - `Json Parse Error`: The request failed to pass valid JSON as an argument   - `marketUnavailable`: The market is currently unavailable   - `nonceBelowThreshold`: The provided nonce is below the threshold   - `nonceDuplicate`: The provided nonce is a duplicate as it has been used in a previous request   - `notFound`: The requested information could not be found   - `requiredArgumentMissing`: One or more required arguments are missing   - `Server Error`: There was an error processing the request   - `Unavailable`: The endpoint being called is unavailable   - `unknownError`: An unknown error has occurred Enum: `accountInactive`, `apiLimitExceeded`, `authenticationError`, `insufficientFunds`, `invalidAccount`, `invalidAmount`, `invalidArgument`, `invalidUnit`, `Json Parse Error`, `marketUnavailable`, `nonceBelowThreshold`, `nonceDuplicate`, `notFound`, `requiredArgumentMissing`, `Server Error`, `Unavailable`, `unknownError` |
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
curl -X GET "https://futures.kraken.com/derivatives/api/v3/initialmargin?orderType=lmt&symbol=PF_XBTUSD&side=buy&size=1.0&limitPrice=30000" \
  -H "APIKey: <your_api_key>" \
  -H "Authent: <authentication_signature>" \
  -H "Nonce: <nonce>"
```

## Example Response

```json
{
  "initialMargin": 0.02,
  "estimatedLiquidationThreshold": 25000.0,
  "price": 30000.0,
  "result": "success",
  "serverTime": "2020-08-27T17:03:33.196Z"
}
```

## Notes

- **Category:** Order Management
- **Server:** `https://futures.kraken.com/derivatives/api/v3` - Kraken Futures
- **Operation ID:** `get initial margin requirements`
- This endpoint was previously listed at `https://docs.kraken.com/api/docs/futures-api/trading/get-initial-margin/` but has since been removed from the live documentation. The API endpoint path `/initialmargin` may still be available on the Kraken Futures platform.
