---
phase: 1
iteration: 01
generated: 2026-04-03
---

# Research Questions: Professional Trading Desk with Kraken Exchange Integration

Source issue: Feature request — build a complete professional trading desk in pure Zig with Kraken exchange integration, zero external dependencies, everything from official specs/RFCs/academic papers.
Feature slug: trading-desk-kraken-integration

## Questions

1. What Kraken REST and WebSocket API endpoints are documented for spot trading, and what are the exact authentication mechanisms (API key signing, nonce handling, HMAC construction), rate limit structures, and error response formats specified across `docs/kraken-exchange-documentation/`?

2. What Kraken futures exchange API endpoints, WebSocket channels, and FIX protocol integration details are documented, and how do the futures API authentication, order types, and margin/collateral models differ from the spot exchange APIs?

3. What order types, order lifecycle states, state transition rules, amendment/cancellation workflows, and parent-child order relationships are specified in `docs/trading-desk/02-order-management-system/`, and what validation and pre-trade checks are described?

4. What real-time market data feed formats, normalization approaches, tick data storage strategies, order book reconstruction methods, and conflation techniques are detailed in `docs/trading-desk/01-market-data-systems/`?

5. What risk management calculations (VaR, Greeks, stress testing), pre-trade risk controls, risk limit structures, and real-time risk monitoring architectures are specified in `docs/trading-desk/05-risk-management/`?

6. What connectivity protocols, message formats, and session management patterns are documented in `docs/trading-desk/06-connectivity-and-protocols/`, particularly for FIX protocol, WebSocket lifecycle, and gateway/adapter architecture?

7. What low-latency architecture patterns, event-driven designs, high-availability strategies, capacity planning approaches, and security requirements are described in `docs/trading-desk/07-infrastructure-and-architecture/`?

8. What position tracking models, multi-currency position handling, P&L calculation methods, reconciliation workflows, and start-of-day/end-of-day position procedures are specified across `docs/trading-desk/04-position-management/` and `docs/trading-desk/15-operational-workflows/`?

9. What execution algorithm types (TWAP, VWAP, iceberg, etc.), smart order routing logic, execution quality measurement methods, and market microstructure considerations are documented in `docs/trading-desk/03-execution-and-algorithms/`?

10. What post-trade processing workflows (trade confirmation, clearing, settlement, allocation, reconciliation), audit trail requirements, and compliance/regulatory reporting obligations are specified across `docs/trading-desk/13-post-trade-processing/` and `docs/trading-desk/14-compliance-and-regulatory/`?

11. What trading UI components (order tickets, blotters, market data displays, charting), workspace layouts, keyboard interaction patterns, and dashboard/analytics views are documented in `docs/trading-desk/16-trading-ui-components/` and `docs/trading-desk/17-dashboard-and-analytics/`?

12. What cryptocurrency-specific trading features — including derivatives (futures, options), margin models, funding rates, liquidation mechanics, and settlement processes — are documented across `docs/trading-desk/12-futures-and-listed-derivatives/` and `docs/trading-desk/11-options-trading/` as they relate to the Kraken exchange integration?
