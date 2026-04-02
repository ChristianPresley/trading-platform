## Appendix: Dashboard Design Principles

### Layout Hierarchy

1. **Top bar:** Global P&L summary, market status, alert count, clock (multiple time zones: ET, CT, GMT, HKT, JST).
2. **Primary panels:** The dashboard's core content (charts, tables, visualizations).
3. **Side panel:** Contextual detail for selected items (drill-down, properties).
4. **Bottom bar:** System status (data feed health, connection status, last update timestamp).

### Refresh and Latency

| Data Type | Refresh Rate | Typical Latency |
|---|---|---|
| Market data (prices, quotes) | Streaming / tick-by-tick | 1-50ms |
| P&L calculations | On every tick or 1-second interval | 10-100ms |
| Risk metrics (VaR, Greeks) | 1-second to 1-minute | 100ms-1s |
| Factor analytics | 1-minute to intraday batch | 1-60 seconds |
| Performance attribution | Intraday batch (every 15-60 min) or EOD | 15-60 minutes |
| Surveillance alerts | Near-real-time | 1-30 seconds |
| Reports | Scheduled (EOD, weekly, monthly) | Batch |

### Interactivity Standards

- **Drill-down:** every aggregated number should be clickable to reveal underlying detail.
- **Cross-filtering:** selecting a dimension in one chart filters all other charts on the same dashboard.
- **Tooltip on hover:** show contextual data without requiring a click.
- **Export:** every table and chart should be exportable (CSV, XLSX, PDF, PNG).
- **Bookmarking:** save current filter/drill-down state as a named bookmark for quick return.
- **Undo:** support Ctrl+Z to reverse filter/view changes.

### Data Quality Indicators

- **Stale data warning:** if a feed has not updated within its expected interval, display a yellow/red indicator.
- **Data source badge:** indicate where data originates (real-time feed, delayed, end-of-day, calculated).
- **Last updated timestamp:** shown per panel or per data element.
- **Reconciliation status:** for P&L and positions, indicate whether front-office and back-office figures are reconciled.
