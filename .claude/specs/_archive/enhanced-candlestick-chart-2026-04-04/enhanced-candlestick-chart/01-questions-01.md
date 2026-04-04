---
phase: 1
iteration: 01
generated: 2026-04-03
---

# Research Questions: Enhanced Candlestick Chart

Source issue: Enhance the candlestick chart in the CLI/terminal app — higher-res rendering, volume bars, technical indicators, zoom/scroll with crosshair
Feature slug: enhanced-candlestick-chart

## Questions

1. How does `chart_panel.zig` currently render candlesticks — what Unicode characters does it use, how does `drawCandle` map OHLC values to terminal rows, and what is the effective vertical resolution per terminal cell?

2. How does the renderer (`renderer.zig`) handle character output — what methods exist for writing single characters vs. multi-byte UTF-8 sequences, and does it support combining characters or half-block/Braille Unicode rendering today?

3. How is candle history stored and passed to the chart panel — what are the data structures in `main.zig` (ring buffer sizes, instrument indexing), and how does the `CandleUpdate` message flow from engine through the ring buffer to the TUI?

4. How does the layout system (`layout.zig`) allocate space to the chart panel — what is the current chart `Rect` size relative to terminal dimensions, and how does resizing work? Is there room to add a volume sub-panel below the chart area within the same `Rect`?

5. How does the `BarAggregator` in `sdk/domain/bar_aggregator.zig` work — what bar types are supported (time, volume, tick), and how is the 1-minute interval configured in `engine.zig`? Does the `CandleUpdate` message carry volume data that could be used for volume bars?

6. How does the input handling system (`input.zig` and `main.zig:processAction`) work — what keybindings exist today, how are arrow keys and modifier keys decoded, and what is the mechanism for adding new keyboard actions (e.g., zoom, scroll, crosshair toggle)?

7. How do the existing sparkline panels (in the orderbook panel or elsewhere) render sub-cell-resolution graphics — do they use Braille characters (`U+2800..U+28FF`) or half-block characters (`▄▀`), and what rendering helpers exist that could be reused for higher-resolution candlestick rendering?

8. How does the theme system (`theme.zig`) define colors for chart elements — what color fields exist for candles, and what would need to be added for volume bars, indicator lines, and crosshair overlays?

9. What test patterns exist for the chart panel and renderer — how are rendering outputs verified in tests today, and what test infrastructure (mock renderer, snapshot testing, etc.) is available for testing new chart features?

10. How does the current Y-axis price label system work in `chart_panel.zig` — how are prices formatted (fixed-point with 8 decimal places), where are labels positioned, and how much horizontal space do they consume within the chart `Rect`?
