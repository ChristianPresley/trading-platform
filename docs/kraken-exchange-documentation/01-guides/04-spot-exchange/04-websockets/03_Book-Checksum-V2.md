# Spot Websockets (v2) Book Checksum

> Source: https://docs.kraken.com/api/docs/guides/spot-ws-book-v2

## Overview

This guide explains how to maintain the order book and generate checksums for WebSocket v2's book channel, which provides aggregate quantities at each price level. The checksum verification is optional but offers validation that your local book copy remains synchronized with the exchange.

**Key constraint:** The checksum is only calculated for the top 10 price levels of the book regardless of the subscription depth.

## Maintaining the Book Channel

When processing book messages:

- Each `"qty": 0` update removes that price level from your book
- After updates, truncate your book to match your subscribed depth (e.g., if subscribed to depth 10 with 11 bids, remove the worst bid)
- Process all price level updates before calculating checksums

## Checksum Calculation Process

To preserve full precision during deserialization, parse book messages using decimal or string decoders for prices and quantities. Python example:

```python
async for bytes in websocket:
    message = json.loads(bytes, parse_float=Decimal)
    self.on_message(message)
```

### Step-by-Step Checksum Generation

**Step 1: Format Ask Prices (sorted low to high)**

- Remove decimal points
- Strip leading zeros
- Concatenate price + quantity pairs

**Step 2: Format Bid Prices (sorted high to low)**

- Remove decimal points
- Strip leading zeros
- Concatenate price + quantity pairs

**Step 3: Combine**

Concatenate the asks string + bids string

**Step 4: Apply CRC32**

Feed the concatenated string to a CRC32 function, optionally casting to unsigned 32-bit integer

The result is the final checksum integer value to compare against the received checksum.
