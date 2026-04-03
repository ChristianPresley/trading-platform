# Book (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/book

## Overview

The Book channel provides Level 2 order book data for currency pairs. On subscription, a snapshot of the order book is published at the specified depth, followed by incremental level updates.

**Endpoint:** `wss://ws.kraken.com`
**Channel Name:** `book`

## Authentication

Not required. This is a public market data channel.

## Subscription Format

```json
{
  "event": "subscribe",
  "pair": ["XBT/USD", "XBT/EUR"],
  "subscription": {
    "name": "book",
    "depth": 10
  }
}
```

## Subscription Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"subscribe"` |
| `pair` | array of strings | Yes | Currency pairs to subscribe to (e.g., `["BTC/USD", "MATIC/GBP"]`) |
| `subscription.name` | string | Yes | Must be `"book"` |
| `subscription.depth` | integer | No | Number of price levels per side. Possible values: `10`, `25`, `100`, `500`, `1000`. Default: `10` |
| `reqid` | string | No | Client-originated request identifier echoed in acknowledgment response |

## Snapshot Response Format

The initial snapshot is sent upon subscription and contains the full order book state at the requested depth.

**Structure:** `[channel_id, book_object, pair, channel_name]`

**There is no checksum on the snapshot.**

### Snapshot Book Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `as` | array | Ask price levels, ascending from best ask. Each entry: `[price, volume, timestamp]` |
| `bs` | array | Bid price levels, ascending from best bid. Each entry: `[price, volume, timestamp]` |

Each level array element:

| Position | Field | Type | Description |
|----------|-------|------|-------------|
| 0 | `price` | string | Price level |
| 1 | `volume` | string | Volume at price level |
| 2 | `timestamp` | string | Last update time in epoch seconds with microsecond precision (e.g., `1534614248.456738`) |

### Snapshot Example

```json
[
  0,
  {
    "as": [
      ["5541.30000", "2.50700000", "1534614248.123678"],
      ["5541.80000", "0.33000000", "1534614098.345543"]
    ],
    "bs": [
      ["5541.20000", "1.52900000", "1534614248.765567"],
      ["5541.10000", "0.30000000", "1534614048.654321"]
    ]
  },
  "XBT/USD",
  "book-100"
]
```

## Update Response Format

After the initial snapshot, incremental updates are sent for order book changes.

**Structure:** `[channel_id, book_object, pair, channel_name]`

### Update Book Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `a` | array | Ask updates. Each entry: `[price, volume, timestamp, update_type]` |
| `b` | array | Bid updates. Each entry: `[price, volume, timestamp, update_type]` |
| `c` | string | Book checksum as a quoted unsigned 32-bit integer. Present on the last update in a batch only |

Each update level array element:

| Position | Field | Type | Description |
|----------|-------|------|-------------|
| 0 | `price` | string | Price level |
| 1 | `volume` | string | Volume at price level. **If volume is `0`, remove the level from the book** |
| 2 | `timestamp` | string | Last update time in epoch seconds with microsecond precision |
| 3 | `update_type` | string | Optional. Value `"r"` indicates a republish scenario |

### Update Examples

**Ask update with checksum:**

```json
[
  1234,
  {
    "a": [
      ["5541.30000", "2.50700000", "1534614248.456738"]
    ],
    "c": "974942666"
  },
  "XBT/USD",
  "book-10"
]
```

**Bid update (volume 0 = remove level):**

```json
[
  1234,
  {
    "b": [
      ["5541.20000", "0.00000000", "1534614249.123456"]
    ],
    "c": "123456789"
  },
  "XBT/USD",
  "book-10"
]
```

## Response Array Elements

| Position | Field | Type | Description |
|----------|-------|------|-------------|
| 0 | `channel_id` | integer | **Deprecated.** Use `channel_name` and `pair` instead |
| 1 | `book_object` | object | Snapshot (`as`/`bs`) or update (`a`/`b`/`c`) data |
| 2 | `pair` | string | Currency pair symbol (e.g., `"XBT/USD"`) |
| 3 | `channel_name` | string | Format: `book-[depth]` (e.g., `"book-10"`, `"book-25"`, `"book-100"`) |

## Notes

- The `channel_id` (position 0) is deprecated. Use `channel_name` and `pair` for channel identification.
- The `channel_name` includes the depth suffix (e.g., `book-10`, `book-25`, `book-100`, `book-500`, `book-1000`).
- A volume of `"0"` in an update means the price level should be removed from the local book.
- The `update_type` field with value `"r"` appears only in republish scenarios.
- The checksum (`c` field) is present only on the last update in a batch, not on the initial snapshot.
- All price, volume, and timestamp values are returned as strings.
- This is a WebSocket v1 channel. Kraken recommends migrating to WebSocket v2 for new implementations.
