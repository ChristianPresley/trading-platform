## Rate Limits

Kraken uses a **call counter** system. Each call has a cost; the counter decays over time. Exceeding the max returns `EAPI:Rate limit exceeded`.

### Account Tier Limits

| Tier | Max Counter | Decay Rate |
|------|-------------|------------|
| Starter | 15 | -0.33/sec (1 every 3s) |
| Intermediate | 20 | -0.5/sec (1 every 2s) |
| Pro | 20 | -1/sec |

### Endpoint Costs

| Category | Cost |
|----------|------|
| Public endpoints | 1 |
| Most private endpoints | 1 |
| Ledgers / QueryLedgers | 2 |
| TradesHistory | 2 |

> **Note**: Order operations (AddOrder, EditOrder, CancelOrder) have a separate matching engine penalty system. Since orders are placed via WebSocket, see the WebSocket API docs for matching engine rate limits.

---

## Error Handling

- All responses include an `error` array — empty means success.
- HTTP status is typically **200 even for API errors** — always check `error` array.

### Common Errors

| Error | Description |
|-------|-------------|
| `EAPI:Invalid nonce` | Nonce is not increasing |
| `EAPI:Rate limit exceeded` | Call counter exceeded |
| `EGeneral:Invalid arguments` | Bad parameters |
