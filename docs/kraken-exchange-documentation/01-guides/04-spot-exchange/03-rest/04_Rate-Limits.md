# Spot REST Rate Limits

> Source: https://docs.kraken.com/api/docs/guides/spot-rest-ratelimits

## REST Specific Limits

Every REST API user maintains a "call counter" beginning at zero. Ledger and trade history calls increment the counter by 2, while all other API calls increase it by 1. AddOrder and CancelOrder operate under separate rate limiting mechanisms.

| Tier | Max API Counter | API Counter Decay |
|------|-----------------|-------------------|
| Starter | 15 | -0.33/sec |
| Intermediate | 20 | -0.5/sec |
| Pro | 20 | -1/sec |

The counter decreases based on the user's verification tier. Each API key has its own counter, and exceeding the maximum triggers rate limiting for subsequent calls. If limits are reached, additional calls will be restricted for a few seconds (or possibly longer if calls continue).

**Note:** Master accounts and subaccounts share the same default trading rate limits determined by the master account's tier.

## Matching Engine Limits

Beyond REST-specific constraints, the trading engine enforces additional limits applicable to all user activity. These are detailed in the Trading Engine Rate Limits documentation.

## Errors

Rate limiting generates two possible error responses:

- `EAPI:Rate limit exceeded` when the REST API counter surpasses the user's maximum
- `EService: Throttled: [UNIX timestamp]` for excessive concurrent requests

Additional details are available through Kraken's support center.
