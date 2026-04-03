# Trading User Interface Components

Comprehensive reference for UI components found on professional trading desks, covering order entry, blotters, market data, charting, news, alerts, workspace management, and keyboard-driven workflows.

## Contents

1. [Order Entry Tickets and Trading Blotter](01_Order-Entry-Tickets-And-Trading-Blotter.md) — Order entry forms for equities, options, FX, and fixed income with validation rules and keyboard shortcuts
   - `OrderTicket`, `AlgoSubParameters`, `LegBuilder`, `FXStreamingQuote`, `RFQWorkflow`, `QuickTrade`, `FatFingerCheck`

2. [Execution Blotter and Position Blotter](02_Execution-Blotter-And-Position-Blotter.md) — Per-fill execution reports, average price calculations, live P&L positions, and exposure heat maps
   - `ExecutionBlotter`, `PartialFillAvgPrice()`, `ArrivalPriceSlippage`, `PositionBlotter`, `UnrealizedPnL`, `ExposureView`, `PositionHeatMap`

3. [Market Data Displays](03_Market-Data-Displays.md) — Watchlists, quote boards, Level 2 market depth, and time-and-sales tape
   - `Watchlist`, `QuoteBoard`, `MarketDepthDisplay`, `TimeAndSales`, `CumulativeDepth`, `ClickToTrade`, `SparklineChart`

4. [Charting](04_Charting.md) — Chart types, timeframes, technical indicators, drawing tools, and multi-timeframe analysis
   - `CandlestickChart`, `VolumeProfile`, `TechnicalIndicator`, `SMA`, `EMA`, `RSI`, `MACD`, `BollingerBands`, `FibonacciRetracement`, `DrawingLayer`, `CompareMode`

5. [News, Research, and Alerts](05_News-Research-And-Alerts.md) — Real-time news feeds, sentiment indicators, economic calendar, and configurable alert/notification systems
   - `NewsFeed`, `SentimentScore`, `EconomicCalendar`, `PriceAlert`, `VolumeAlert`, `TechnicalAlert`, `AlertConditionBuilder`, `NotificationChannel`

6. [Workspace, Keyboard, and UX Patterns](06_Workspace-Keyboard-And-UX-Patterns.md) — Multi-monitor layouts, workspace save/load, symbol linking, keyboard-driven trading, and command palette
   - `WorkspaceLayout`, `TearOffWindow`, `SymbolLinkGroup`, `DockingSystem`, `CommandPalette`, `HotkeyManager`, `PriceLadderDOM`, `KeybindingEditor`
