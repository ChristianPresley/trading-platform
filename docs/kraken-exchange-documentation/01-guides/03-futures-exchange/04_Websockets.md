# Futures Websockets

> Source: https://docs.kraken.com/api/docs/guides/futures-websockets

## Overview

This documentation covers WebSocket connections for Kraken's Futures Exchange API, specifically focusing on authentication via signed challenges and subscription management.

## Sign Challenge

### Process

The Futures WebSocket API requires authenticated requests to private feeds using a signed challenge message. The challenge is a UUID string obtained through the WebSocket API Public endpoint.

To sign a challenge, follow these cryptographic steps:

1. Hash the challenge using SHA-256
2. Base64-decode your `api_secret`
3. Use step 2's result to HMAC-SHA-512 hash step 1's result
4. Base64-encode the step 3 result

### Example

**Challenge:** `c100b894-1729-464d-ace1-52dbce11db42`

**API Secret:** `7zxMEF5p/Z8l2p2U7Ghv6x14Af+Fx+92tPgUdVQ748FOIrEoT9bgT+bTRfXc5pz8na+hL/QdrCVG7bh9KpT0eMTm`

**Signed Output:** `4JEpF3ix66GA2B+ooK128Ift4XQVtc137N9yeg4Kqsn9PI0Kpzbysl9M1IeCEdjg0zl00wkVqcsnG4bmnlMb3A==`

## Subscriptions

### WebSocket URL

`wss://futures.kraken.com/ws/v1`

### Connection Maintenance

You will need to make a ping request at least every 60 seconds to maintain the connection.

## Data Delivery

Most feeds provide an initial snapshot followed by real-time updates.

## Authentication Requirements

Private feed subscriptions require passing a signed challenge in subscribe/unsubscribe messages.
