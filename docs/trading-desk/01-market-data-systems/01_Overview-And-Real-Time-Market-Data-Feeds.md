## Overview

Market data systems form the nervous system of any professional trading desk. They are responsible for the ingestion, normalization, distribution, storage, and entitlement management of financial instrument pricing information across all asset classes. A well-architected market data platform must handle millions of messages per second with microsecond-level latency while maintaining data integrity, auditability, and regulatory compliance.

The core responsibilities of a market data system include:

- **Ingestion**: Connecting to exchanges, consolidated feeds, and third-party vendors to receive raw pricing events.
- **Normalization**: Translating venue-specific message formats and symbology into a uniform internal representation.
- **Distribution**: Delivering normalized data to consuming applications (trading UIs, algorithmic engines, risk systems, compliance monitors) with appropriate entitlements.
- **Persistence**: Storing tick-level and aggregated data for historical analysis, backtesting, and regulatory record-keeping.
- **Entitlement enforcement**: Ensuring that data usage complies with exchange licensing agreements, user-level permissions, and display/non-display classification.

---

## Real-Time Market Data Feeds

### Level 1 Data (Top of Book)

Level 1 data provides the most basic real-time pricing information for a financial instrument. It represents the current best available prices and the most recent trade activity.

#### Core Fields

| Field | Description |
|-------|-------------|
| **Best Bid Price** | Highest price at which a buyer is willing to purchase |
| **Best Bid Size** | Number of shares/contracts available at the best bid |
| **Best Ask Price** (Offer) | Lowest price at which a seller is willing to sell |
| **Best Ask Size** | Number of shares/contracts available at the best ask |
| **Last Trade Price** | Price of the most recent executed trade |
| **Last Trade Size** | Volume of the most recent executed trade |
| **Last Trade Time** | Timestamp of the most recent execution (typically exchange timestamp) |
| **Cumulative Volume** | Total shares/contracts traded in the current session |
| **VWAP** | Volume-weighted average price for the session |
| **Open Price** | First trade price of the session (or indicative open from auction) |
| **High Price** | Highest trade price during the session |
| **Low Price** | Lowest trade price during the session |
| **Previous Close** | Official closing price from the prior session |
| **Net Change** | Difference between last trade price and previous close |
| **Turnover** | Cumulative notional value traded (price x volume) |

#### NBBO vs BBO

- **BBO (Best Bid and Offer)**: The best bid and ask prices available on a single venue. Each exchange publishes its own BBO.
- **NBBO (National Best Bid and Offer)**: The best bid and ask prices across all protected exchanges in the United States. The NBBO is the regulatory benchmark under Regulation NMS (National Market System). It is calculated by the Securities Information Processors (SIPs) by comparing BBOs from all NMS exchanges. Brokers have a duty of best execution against the NBBO. In practice, many firms calculate their own "direct NBBO" from direct exchange feeds to achieve lower latency than the SIP-disseminated NBBO.

#### Quote Condition Codes

Quotes carry condition codes that indicate their nature: regular trading, pre-market, after-hours, auction indicative, halted, short-sale restricted, odd-lot, and so on. Proper interpretation of these codes is essential for accurate pricing displays and algorithmic decision-making.

### Level 2 Data (Depth of Book)

Level 2 data reveals the full order book beyond the top-of-book, showing the supply and demand landscape at multiple price levels.

#### Market-by-Price (MBP)

Market-by-Price aggregates all orders at each price level into a single entry showing the total quantity available. This is the most common Level 2 representation for display purposes.

```
Price Level | Bid Qty | Bid Price | Ask Price | Ask Qty
     1      |  5,000  |  150.25   |  150.26   |  3,200
     2      |  8,300  |  150.24   |  150.27   |  7,100
     3      | 12,400  |  150.23   |  150.28   |  4,500
     4      |  2,100  |  150.22   |  150.29   |  9,800
     5      |  6,700  |  150.21   |  150.30   | 15,200
```

Typical depth: 5, 10, or 20 price levels, depending on the exchange and subscription tier. CME provides 10 levels of implied and explicit depth in its Market-by-Price feed. NYSE Arca publishes full depth. NASDAQ TotalView provides full depth-of-book with attributed orders.

#### Market-by-Order (MBO)

Market-by-Order provides individual order-level detail: each resting order in the book is represented as a separate entry with its unique order ID, price, size, timestamp, and (on some venues) the identity of the market participant (attributed feeds).

MBO data is significantly higher bandwidth than MBP. It enables:

- Precise order book reconstruction.
- Queue position estimation (knowing how many orders are ahead at a price level).
- Detection of order patterns (iceberg detection, spoofing analysis).
- More accurate simulation for backtesting fill models.

Exchanges offering MBO feeds include:

| Exchange | MBO Feed Name |
|----------|---------------|
| NASDAQ | TotalView-ITCH |
| NYSE | NYSE Integrated Feed (pillar) |
| CME | CME Market-by-Order (MBO, via MDP 3.0) |
| LSE | Level 2 - Full Order Book (via MIT/native) |
| Eurex | EOBI (Enhanced Order Book Interface) |
| ASX | ASX ITCH |
| TMX | TMX Quantum Feed |

#### Implied and Composite Books

In derivatives markets, exchanges like CME calculate implied prices from combinations of outright and spread orders. The implied book is published alongside the explicit book. Trading systems must merge these to present a complete depth view. Similarly, for securities trading across multiple venues, a composite or consolidated book aggregates depth from all lit venues.

### Level 3 Data

Level 3 is not a standardized industry term but sometimes refers to the ability to submit and manage orders directly within the exchange's order book, essentially market-maker functionality. Some practitioners use it to refer to the full MBO feed with add/modify/delete messages.
