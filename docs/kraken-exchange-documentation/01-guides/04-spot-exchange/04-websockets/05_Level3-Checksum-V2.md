# Spot Websockets (v2) Level3 Checksum

> Source: https://docs.kraken.com/api/docs/guides/spot-ws-l3-v2

## Overview

This guide explains how to maintain the `level3` order book channel and generate checksums for Kraken's WebSocket v2 API. The checksum verification is optional. It provides an additional check that the client copy has been constructed correctly and is synchronised to the exchange.

## Key Concepts

### Book Maintenance Requirements

- Process all orders in a `level3` message before calculating the checksum
- Remove price levels with zero orders or quantity
- Truncate the book to your subscribed depth after each update
- The checksum only considers the top 10 price levels

### Precision Handling

To keep the full precision through deserialization and decoding, parse the `level3` message using a decimal (or string decoder) for the prices and quantities.

## Checksum Generation Steps

The process involves:

1. **Format asks** (low to high): Strip decimal points and leading zeros from prices and quantities, concatenate them
2. **Format bids** (high to low): Apply same formatting rules
3. **Combine** asks + bids strings
4. **Apply CRC32** function to generate the final unsigned 32-bit integer

The example provided demonstrates generating checksum value `1063832831` from a complete order book snapshot with specific formatting rules applied to each field.
