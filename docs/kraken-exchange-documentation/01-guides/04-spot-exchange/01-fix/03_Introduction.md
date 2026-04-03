# FIX Introduction

> Source: https://docs.kraken.com/api/docs/guides/fix-intro

## Overview

Kraken's FIX (Financial Information Exchange) API is a standardized and widely adopted messaging protocol designed to facilitate electronic communication between institutional clients and the exchange. The protocol enables access to both spot and derivatives trading, with capabilities for trading, liquidity access, and streaming market data.

Access requires contacting your Account Manager at Kraken.

## Key Features

### Messages

The FIX API supports multiple message types:

- Reference data (InstrumentListRequest, InstrumentList)
- Order book and trades (MarketDataRequest, MarketDataFull with snapshots)
- Trading engine status updates
- Order entry and management (NewOrderSingle, OrderCancelRequest, OrderMassCancelRequest)
- Order status tracking (OrderStatusRequest, ExecutionReport)
- Session-based cancel on disconnect functionality

### Performance

- Co-located hosting near Kraken's data center for low-latency access
- Native integration with the trading engine for rapid execution

### Guaranteed Delivery and Recovery

The system ensures recovery of missed messages and reliable connection maintenance through the FIX resend request mechanism, plus guaranteed message ordering from clients to the trading engine.

### User Acceptance Testing (UAT)

Test FIX 4.4 in a sandboxed environment against Kraken's complete trading stack before production deployment.

### Security

- Advanced encryption and authentication protocols
- Regular infrastructure security updates

### Dedicated Support

24/7 professional support with comprehensive documentation and portal access.

### Session Protocol

Based on FIX 4.4 specification (available at https://fixtrading.org/standards). Provides session management, authentication, messaging, sequencing, heartbeats, and gap fills over TCP/IP.

### Hours of Operation

24/7 operation with daily logical session rollover at 10PM UTC, lasting approximately 30 seconds. Both trading and market data sequence numbers reset to 0 during maintenance.

### Connectivity Details

- Client IP addresses must be whitelisted
- Secure TCP SSL connection required (TLS 1.3)
- Kraken provides designated compIDs, URLs, and separate ports for trading and market data endpoints

### Trading Rate Limits

Rate limiting protects against malicious usage and market manipulation. Full documentation is available in the spot rate limits guide.

### FIX Dictionary

The FIX 4.4 XML dictionary for message and field validation can be downloaded from the API documentation portal.
