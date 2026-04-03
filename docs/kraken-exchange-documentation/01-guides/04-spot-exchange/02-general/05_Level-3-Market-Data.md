# Spot Level 3 Market Data

> Source: https://docs.kraken.com/api/docs/guides/spot-l3-data

## Overview

Level 3 (L3) market data provides visibility of individual orders in the order book. This insight enables determination of queue priorities, resting times, fill probabilities, and many other analytics to help make better informed trading decisions.

## Market Data Levels Overview

| Level | Description | Channel |
|-------|-------------|---------|
| L1 | Top of the book (best bid/offer) and recent trade data | `ticker` |
| L2 | Individual price levels with aggregated order quantities at each level | `book` |
| L3 | Individual orders in the book with order IDs and timestamps | `level3` |

## Order Visibility

The Level 3 feed shows orders **resting** in the visible order book. The book will never be crossed (i.e. no overlapping buy and sell orders).

Excluded from the feed:

- In-flight orders
- Unmatched market orders
- Untriggered stop-loss and take-profit orders
- Hidden quantity of `iceberg` orders

## Use Cases

Advanced trading analytics enabled by Level 3 data:

- **Queue Priority Analysis**: Understanding position in order queue at each price level
- **Resting Time Metrics**: Tracking order duration in the book
- **Fill Probability Estimation**: Estimating execution likelihood based on queue depth
- **Market Microstructure Analysis**: Studying order flow patterns and participant behavior
- **Liquidity Analysis**: Assessing true market depth beyond aggregated views

## REST API

The `/private/Level3` endpoint provides a snapshot of the Level 3 order book.

### Example Request

```json
{
    "nonce": 1695828490,
    "pair": "BTC/USD",
    "depth": 10
}
```

### Example Response

```json
{
    "error": [],
    "result": {
        "pair": "BTC/USD",
        "bids": [
            {
                "price": "90509.00000",
                "qty": "0.04902300",
                "order_id": "ONLALL-67PF5-3CAQCL",
                "timestamp": 1765628335242269554
            },
            {
                "price": "90509.00000",
                "qty": "0.00010000",
                "order_id": "OZMMNG-E5B3K-4DCURI",
                "timestamp": 1765628346024196738
            },
            {
                "price": "90509.00000",
                "qty": "0.14670600",
                "order_id": "OGXZBL-RDLER-I45MMN",
                "timestamp": 1765628373027400852
            },
            {
                "price": "90506.80000",
                "qty": "1.65733300",
                "order_id": "O3YQDB-56ZLD-PYJJCD",
                "timestamp": 1765628373581704382
            }
        ],
        "asks": [
            {
                "price": "90509.10000",
                "qty": "0.00110900",
                "order_id": "OVT3GM-4OLSW-L4PPLG",
                "timestamp": 1765628340224297666
            },
            {
                "price": "90509.10000",
                "qty": "0.02771600",
                "order_id": "OBT7YM-NK4AM-3Z6CZR",
                "timestamp": 1765628349238326760
            },
            {
                "price": "90509.10000",
                "qty": "0.88510000",
                "order_id": "OPFXIF-2BHGV-3NJJTE",
                "timestamp": 1765628369865692932
            },
            {
                "price": "90509.50000",
                "qty": "0.34119400",
                "order_id": "OWMYX7-E63XJ-RHV64F",
                "timestamp": 1765628363316840374
            }
        ]
    }
}
```

## Websockets

For real-time Level 3 data, use the `level3` channel on the authenticated websockets connection. The channel provides:

- Initial snapshot of the order book
- Real-time updates as orders are added, modified, or removed
- Sequence numbers for synchronization

### Building the Book

The `level3` channel synchronizes the initial snapshot and subsequent stream of updates in a similar mechanism to the `book` feed. Only a single subscription request is required to build the book -- the channel handles snapshot and update synchronization automatically.

### Checksum Verification

Optional checksum verification provides an additional check that the client version of the book has been constructed correctly and is synchronized to the exchange.

Reference: [Level3 Checksum Guide](/api/docs/guides/spot-ws-l3-v2)

## Performance Considerations

The latency differences between the `level3` and `book` feeds will be negligible compared to the transport time.

Performance factors:

- **Direct Stream**: Direct stream from matching engine; `book` feed contains aggregated data
- **Payload Size**: Level 3 payload larger than book data due to individual order descriptions
- **Channel Load**: Different stacks; authenticated channel typically has less load than public
- **Checksum Computation**: Level 3 checksum takes longer due to order sequence verification
- **Latency Metrics**: Timestamps enable client latency tracking
