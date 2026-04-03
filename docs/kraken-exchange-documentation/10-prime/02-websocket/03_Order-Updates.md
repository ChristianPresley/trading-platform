# Order Updates (WebSocket)

## Endpoint

```
wss://wss.prime.kraken.com/ws/v1
```

## Channel

```
Order
```

## Description

Delivers a continuous stream of order status changes. The data structure resembles an ExecutionReport message format, providing real-time updates on order lifecycle events.

## Authentication

Authentication is required to access this stream.

## Subscribe Request

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reqid` | number | Yes | Request ID - will be echoed back in the response structure |
| `type` | string | Yes | Must be `subscribe` |
| `streams` | array | Yes | Configuration array for the Order stream |
| `streams[].name` | string | Yes | Must be `Order` |
| `streams[].StartDate` | string | No | ISO-8601 UTC timestamp. Filter orders submitted after this date. Format: `2019-02-13T05:17:32.000000Z` |
| `streams[].EndDate` | string | No | ISO-8601 UTC timestamp. Filter orders submitted before this date. |
| `streams[].Symbol` | string | No | Filter by security symbol (e.g., `BTC-USD`) |
| `streams[].Statuses` | array | No | Filter by order statuses (e.g., `New`, `Filled`) |
| `streams[].OrderID` | string | No | Filter by specific Order ID |
| `streams[].RFQID` | string | No | Filter by Request for Quote ID |

### Example Request

```json
{
  "reqid": 7,
  "type": "subscribe",
  "streams": [
    {
      "name": "Order",
      "StartDate": "2021-09-14T00:00:00.000000Z"
    }
  ]
}
```

## Response Message

### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reqid` | number | Yes | Relates response to original request |
| `type` | string | Yes | Message type identifier (`Order`) |
| `ts` | string | Yes | ISO-8601 UTC timestamp |
| `initial` | boolean | No | Indicates if this is initial data |
| `seqNum` | number | Yes | Sequence number per request |
| `action` | string | No | `Update` or `Remove` |
| `data` | array | Yes | Array of order data records |

### Order Data Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `Timestamp` | string | Yes | Message timestamp |
| `Symbol` | string | Yes | Order security symbol (e.g., `BTC-USD`) |
| `OrderID` | string | Yes | Server-assigned Order ID (UUID format) |
| `ClOrdID` | string | Yes | Client-assigned order identifier |
| `SubmitTime` | string | No | When the order was submitted |
| `ExecID` | string | No | Execution identifier |
| `Side` | string | Yes | `Buy` or `Sell` |
| `ExecType` | string | Yes | Specific execution description (e.g., `New`, `Trade`, `Cancelled`) |
| `OrdStatus` | string | Yes | Identifies current status of order (e.g., `New`, `PartiallyFilled`, `Filled`, `Cancelled`) |
| `OrderQty` | string | Yes | Order quantity |
| `OrdType` | string | Yes | Order type classification (e.g., `Market`, `Limit`) |
| `Currency` | string | Yes | Currency of Quantity |
| `LeavesQty` | string | No | Remaining unfilled quantity |
| `CumQty` | string | No | Cumulative filled quantity |
| `AvgPx` | string | No | Average execution price |
| `TimeInForce` | string | No | Order duration specification (e.g., `GoodTillCancel`, `FillOrKill`, `ImmediateOrCancel`) |
| `LastPx` | string | No | Most recent execution price |
| `LastQty` | string | No | Most recent execution quantity |
| `LastAmt` | string | No | Most recent execution amount |
| `LastFee` | string | No | Most recent execution fee |
| `CumAmt` | string | No | Cumulative execution amount |
| `DecisionStatus` | string | No | Order decision state (e.g., `Active`) |
| `AmountCurrency` | string | No | Currency for amount fields |
| `CustomerUser` | string | No | The customer user associated with this order |

### Example Response

```json
{
  "reqid": 7,
  "type": "Order",
  "ts": "2021-09-14T22:26:44.518538Z",
  "initial": false,
  "seqNum": 3,
  "data": [
    {
      "Timestamp": "2021-09-14T22:26:44.505519Z",
      "Symbol": "BTC-USD",
      "OrderID": "b35b1c3b-a304-4224-919f-9db1319de188",
      "ClOrdID": "d7635e40-15aa-11ec-b0a2-2554a9e1e7a4",
      "SubmitTime": "2021-09-14T22:26:44.457050Z",
      "ExecID": "c73fcf77-aaa1-46e7-9260-f625d6416646",
      "Side": "Buy",
      "ExecType": "New",
      "OrdStatus": "New",
      "OrderQty": "0.10000000",
      "OrdType": "Market",
      "Currency": "BTC",
      "LeavesQty": "0.10000000",
      "CumQty": "0",
      "AvgPx": "0",
      "TimeInForce": "FillOrKill",
      "LastPx": "0",
      "LastQty": "0",
      "LastAmt": "0",
      "LastFee": "0",
      "CumAmt": "0",
      "DecisionStatus": "Active",
      "AmountCurrency": "USD",
      "CustomerUser": "tom@company.com"
    }
  ]
}
```

## Notes

- Related endpoints include Execution Report, Order Control Request, and other order management functions.
- The `OrderID` is server-assigned and will be a UUID.
- The `ClOrdID` is the client-assigned identifier that corresponds to the one sent in the NewOrderSingle message.
- Use `StartDate` and `EndDate` filters to limit the historical scope of order updates received on initial subscription.
- The `Statuses` filter accepts multiple status values to narrow the stream to specific order states.

## Source

- [Kraken API Documentation - Order Updates (WebSocket)](https://docs.kraken.com/api/docs/prime-api/websocket/order)
