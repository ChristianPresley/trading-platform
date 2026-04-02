## 9. Multi-Monitor and Workspace Management

### 9.1 Layout Management

Professional trading desks typically use 4-8 monitors. The UI must support:

**Layout paradigms:**

- **Tabbed panels:** Multiple components in a single panel area, switch via tabs.
- **Split panes:** Horizontal and vertical splits within a window; drag dividers to resize.
- **Floating windows:** Components detached from main window, positioned anywhere across monitors.
- **Docking system:** Drag components to dock positions (top, bottom, left, right, center) with visual guides.

**Typical multi-monitor arrangement (6 monitors, 3x2 grid):**

| Monitor | Position | Content |
|---|---|---|
| 1 | Top-left | Watchlists and quote board |
| 2 | Top-center | Charts (multi-timeframe, 2x2 grid) |
| 3 | Top-right | News feed and research |
| 4 | Bottom-left | Order blotter and execution blotter (stacked) |
| 5 | Bottom-center | Position blotter with P&L and Level 2 depth |
| 6 | Bottom-right | Risk dashboard and alerts |

### 9.2 Workspace Saving and Loading

- **Named workspaces:** Save entire layout as a named configuration (e.g., "US Equities Morning", "Earnings Season", "Risk Review").
- **Auto-save:** Layout state persisted on every change; restored on application restart.
- **Workspace sharing:** Export workspace as a file; import on another workstation.
- **Component state:** Each workspace saves not just layout positions but also:
  - Watchlist contents and column configuration
  - Chart symbols, timeframes, indicators, and drawings
  - Blotter filters and sort orders
  - Alert configurations
  - Window positions and sizes across all monitors

### 9.3 Tear-Off Windows

- Any panel or component can be "torn off" by dragging it out of its container.
- Torn-off window becomes a native OS window that can be moved to any monitor.
- Torn-off window remains linked to the application (linked symbol context, shared data).
- Double-click title bar to re-dock.
- Tear-off windows support independent resizing and z-ordering.

### 9.4 Linked Symbols (Symbol Linking)

- **Color-coded link groups:** Components assigned to the same color group (Red, Blue, Green, Yellow, etc.) share a selected symbol.
- Changing the symbol in one linked component updates all others in the same group.
- A component can be "unlinked" (gray) to be independent.
- Example: Watchlist (Red group), Chart (Red group), Level 2 (Red group), News (Red group) -- clicking a row in the watchlist updates the chart, depth display, and news filter simultaneously.

### 9.5 Multi-Screen Support

- Application detects monitor count, resolution, and arrangement on startup.
- Layout engine respects monitor boundaries (components do not span monitor bezels unless explicitly configured).
- DPI-aware rendering for mixed-resolution setups (e.g., 4K center monitor, 1080p side monitors).
- Taskbar/menu bar behavior: configurable whether tear-off windows appear as separate taskbar items.
- Fullscreen mode per monitor.

---

## 10. Keyboard-Driven Trading

### 10.1 Global Hotkeys

| Hotkey | Action |
|---|---|
| `Ctrl+N` | New order ticket |
| `Ctrl+Shift+B` | Quick-buy active symbol (opens pre-filled buy ticket) |
| `Ctrl+Shift+S` | Quick-sell active symbol |
| `Ctrl+F` | Global symbol search / command palette |
| `Ctrl+W` | Close active panel |
| `Ctrl+Tab` | Cycle through open panels |
| `Ctrl+1` through `Ctrl+9` | Switch to workspace 1-9 |
| `F5` | Refresh active panel data |
| `F11` | Toggle fullscreen |
| `Ctrl+Shift+L` | Lock/unlock layout |
| `Ctrl+,` | Open preferences/settings |

### 10.2 Order Management Hotkeys

| Hotkey | Action |
|---|---|
| `Ctrl+Shift+C` | Cancel selected order |
| `Ctrl+Shift+A` | Cancel all orders for active symbol |
| `Ctrl+Shift+X` | Cancel all orders (panic cancel) |
| `Ctrl+Shift+F` | Flatten position (close entire position for active symbol) |
| `Ctrl+Shift+P` | Flatten all positions |
| `Ctrl+R` | Replace/amend selected order |

### 10.3 Rapid Order Entry

Some professional platforms support a "speed trader" or "hot button" mode:

- Pre-configured order templates bound to keys: e.g., `F1` = Buy 1000 shares at market, `F2` = Sell 1000 shares at market, `F3` = Buy 100 at best bid, `F4` = Sell 100 at best ask.
- Numeric pad entry: type quantity then press side key. E.g., type `5000` then press `B` to buy 5,000 at market.
- Price ladder (DOM) trading: click or press keys on a vertical price ladder to place limit orders at specific price levels. The DOM (Depth of Market) ladder shows:
  - Price column (centered, scrollable)
  - Bid quantity column (left)
  - Ask quantity column (right)
  - Your working orders displayed at their price levels
  - One-click to place, click existing order to cancel

### 10.4 Command Palette

A searchable command palette (invoked via `Ctrl+Shift+P` or `Ctrl+F`) that supports:

- Symbol search: type a ticker to navigate all linked components.
- Action search: type "cancel all", "flatten", "new order" to execute actions.
- Component search: type "chart", "blotter", "news" to focus that panel.
- Settings search: type "theme", "font size", "sound" to jump to preferences.
- Recent actions: shows last 10 commands for quick repeat.

### 10.5 Customizable Keybindings

- All hotkeys configurable via a keybinding editor.
- Conflict detection: warns if a new binding conflicts with an existing one.
- Context-aware bindings: same key can have different actions depending on focused component (e.g., `Enter` submits an order in the ticket but expands a row in the blotter).
- Import/export keybinding profiles.
- Chord bindings supported: e.g., `Ctrl+K, Ctrl+C` (press Ctrl+K then Ctrl+C).

---

## Appendix: Common UX Patterns

### Color Themes

- **Dark theme** (dominant on trading desks): dark gray/black backgrounds (#1a1a2e, #16213e), high-contrast text, reduces eye strain over long sessions.
- **Light theme:** available but rarely used on active desks.
- **Color palette:** green for positive/buy, red for negative/sell (Western convention); some desks invert for Asian markets. Configurable in settings.

### Real-Time Update Patterns

- **Cell flash:** background color briefly changes on value update (200-500ms).
- **Tick arrows:** small up/down arrows next to prices showing direction of last change.
- **Stale data indicator:** values not updated within a configurable threshold (e.g., 5 seconds) shown dimmed or with a warning icon.
- **Connection status:** green/yellow/red indicator showing market data feed health.

### Accessibility Considerations

- Font size configurable globally and per-component (typical range: 10-16pt; some traders prefer 8pt for density).
- Color-blind modes: use shapes and patterns in addition to color to convey information.
- High-contrast mode for visually impaired users.
- Screen reader support for compliance requirements.

### Performance Expectations

- Market data latency: display within 1-5ms of receipt for co-located setups; within 50-200ms for WAN connections.
- Blotter update: order status changes reflected within 1ms of FIX message receipt.
- Chart rendering: re-render within 16ms (60fps target) for smooth scrolling and live candle updates.
- Startup time: workspace fully restored and streaming within 5-15 seconds.
- Memory: trading applications commonly consume 2-8 GB RAM depending on number of open instruments and historical data loaded.
