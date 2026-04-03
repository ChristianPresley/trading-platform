# Futures Rate Limits

> Source: https://docs.kraken.com/api/docs/guides/futures-rate-limits

## REST Request Limits

Request limits depend on the cost associated with each API call and the rate limiting budgets for endpoint paths. Public endpoints carry no cost and don't count against rate limiting budgets. For `/derivatives` endpoints, clients may spend up to 500 every 10 seconds.

### Cost Table for `/derivatives` Endpoints

| Endpoint | Cost |
|----------|------|
| sendorder | 10 |
| editorder | 10 |
| cancelorder | 10 |
| batchorder | 9 + size of batch |
| accounts | 2 |
| openpositions | 2 |
| fills (without lastFillTime specified) | 2 |
| fills (with lastFillTime specified) | 25 |
| cancelallorders | 25 |
| cancelallordersafter | 25 |
| withdrawaltospotwallet | 100 |
| openorders | 2 |
| orders/status | 1 |
| unwindqueue | 200 |
| GET leveragepreferences | 2 |
| PUT leveragepreferences | 10 |
| GET pnlpreferences | 2 |
| PUT pnlpreferences | 10 |
| transfer | 10 |
| transfer/subaccount | 10 |
| subaccount/:subaccountUid/trading-enabled | 2 |
| self-trade-strategy | 2 |

The Batch Order endpoint cost formula is 9 + batch size. A batch of 10 orders would cost 19 total.

When API limits are exceeded, the response returns `"error": "apiLimitExceeded"`.

### Cost Table for `/history` Endpoints

For `/history` endpoints, clients receive a pool of 100 tokens that replenishes at 100 tokens per 10 minutes.

| Endpoint | Cost |
|----------|------|
| historicalorders | 1 |
| historicaltriggers | 1 |
| historicalexecutions | 1 |
| accountlogcsv | 6 |
| accountlog (count: 1-25) | 1 |
| accountlog (count: 26-50) | 2 |
| accountlog (count: 51-1000) | 3 |
| accountlog (count: 1001-5000) | 6 |
| accountlog (count: 5001-100000) | 10 |

### Error Response Example

```json
{
  "result": "error",
  "serverTime": "2016-02-25T09:45:53.818Z",
  "error": "apiLimitExceeded"
}
```

## Websocket Limits

Clients face concurrent connection limits and per-connection request limits.

| Resource | Allowance | Replenish Period |
|----------|-----------|------------------|
| Connections | 100 | N/A |
| Requests | 100 | 1 second |

Limits may change and additional restrictions could be introduced.
