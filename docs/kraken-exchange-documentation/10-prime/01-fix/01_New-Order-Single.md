# New Order Single (FIX)

## Message Type

```
MsgType: D (NewOrderSingle)
```

## Description

Submit a new order to the Kraken exchange via the FIX 4.4 protocol. This message is used to place market, limit, and limit-all-in orders.

## Supported Order Types

| OrdType Value | Name | Description |
|---------------|------|-------------|
| `1` | Market | Full order quantity executes immediately at the best available price |
| `2` | Limit | Full order quantity is placed immediately with a limit price restriction |
| `A` | LimitAllIn | Limit order where price and quantity includes the fees |

## Request Fields

| FIX Tag | Field Name | Type | Required | Description |
|---------|-----------|------|----------|-------------|
| 1 | Account | string | Conditional | Required if multiple accounts are enabled |
| 11 | ClOrdID | string | Yes | Unique order identifier, max 36 characters. UUIDs recommended |
| 55 | Symbol | string | Yes | Currency pair in `BASE-QUOTE` format (e.g., `BTC-USD`) |
| 54 | Side | integer | Yes | `1` = Buy, `2` = Sell |
| 40 | OrdType | char | Yes | `1` = Market, `2` = Limit, `A` = LimitAllIn |
| 38 | OrderQty | float | Yes | Quantity in base asset terms |
| 15 | Currency | string | No | Defaults to base currency if unspecified |
| 44 | Price | float | Conditional | Required for Limit and LimitAllIn orders |
| 59 | TimeInForce | string | Yes | `1` = GTC (Good Till Cancel), `3` = IOC (Immediate or Cancel), `4` = FOK (Fill or Kill) |
| 60 | TransactTime | string | Yes | Timestamp format: `YYYYMMDD-HH:MM:SS.uuu` |
| 126 | ExpireTime | string | Conditional | GTD orders only. Format: `YYYYMMDD-HH:MM:SS` |
| 168 | EffectiveTime | string | No | Activation time. Format: `YYYYMMDD-HH:MM:SS.uuu` |
| 847 | TargetStrategy | string | No | `StopLimit` or `TakeProfitLimit` |
| 957 | NoStrategyParams | integer | No | Count of strategy parameter groups |
| 958 | StrategyParameterName | string | No | Strategy parameter identifier |
| 960 | StrategyParameterValue | string | No | Strategy parameter value |
| 20030 | CancelOnDisconnect | char | No | `Y` = Yes, `N` = No. Default: `Y` |

## Message Structure

- **Header**: Standard FIX 4.4 header with MsgType `D`
- **Body**: Fields listed above
- **Trailer**: Standard FIX trailer (Tag 10 checksum)

## Example Message

```
8=FIX.4.4|9=147|35=D|34=2|49=CUSTOMER|52=20220915-18:30:01.335|56={{ Customer }}|11=id-220912164936074-1152|38=1|40=2|44=1630.123|54=2|55=ETH-USD|59=1|60=20220915-14:30:01|10=228|
```

### Example Breakdown

| Tag | Value | Description |
|-----|-------|-------------|
| 8 | FIX.4.4 | FIX protocol version |
| 9 | 147 | Body length |
| 35 | D | NewOrderSingle message type |
| 34 | 2 | Message sequence number |
| 49 | CUSTOMER | Sender CompID |
| 52 | 20220915-18:30:01.335 | Sending time |
| 56 | {{ Customer }} | Target CompID |
| 11 | id-220912164936074-1152 | Client order ID |
| 38 | 1 | Order quantity (1 ETH) |
| 40 | 2 | Limit order |
| 44 | 1630.123 | Limit price |
| 54 | 2 | Sell side |
| 55 | ETH-USD | Symbol |
| 59 | 1 | GTC time in force |
| 60 | 20220915-14:30:01 | Transaction time |
| 10 | 228 | Checksum |

## Time In Force Values

| Value | Name | Description |
|-------|------|-------------|
| `1` | GTC | Good Till Cancel - order remains active until filled or cancelled |
| `3` | IOC | Immediate or Cancel - fill what is available immediately, cancel the rest |
| `4` | FOK | Fill or Kill - entire order must fill immediately or be cancelled entirely |

## Strategy Orders

For advanced order types like Stop Limit and Take Profit Limit, use the `TargetStrategy` (Tag 847) field along with `NoStrategyParams` (Tag 957), `StrategyParameterName` (Tag 958), and `StrategyParameterValue` (Tag 960) for additional configuration.

## Cancel on Disconnect

The `CancelOnDisconnect` field (Tag 20030) controls whether open orders are automatically cancelled when the FIX session disconnects. Default behavior is `Y` (cancel on disconnect).

## Notes

- Response handling is covered in the separate Execution Report documentation.
- Symbol format uses `BASE-QUOTE` convention (e.g., `BTC-USD`, `ETH-USD`).
- ClOrdID must be unique per order and should not exceed 36 characters. UUIDs are recommended.
- The `Account` field is only required when the FIX session has access to multiple trading accounts.

## Source

- [Kraken API Documentation - New Order Single (FIX)](https://docs.kraken.com/api/docs/prime-api/fix/nos-fix)
