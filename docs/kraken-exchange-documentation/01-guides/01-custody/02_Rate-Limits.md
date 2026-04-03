# Custody Rate Limits

> Source: https://docs.kraken.com/api/docs/guides/custody-rest-ratelimits

## Specific Limits

Every Custody API user receives a "call counter" beginning at 0, incrementing by 1 for each API call. The maximum counter limit per user is 10, resetting after a rolling 10-second window. Each new request extends the expiration time of the rate limiter.

When rate limits are exceeded, additional calls face restrictions for several seconds or potentially longer if new calls continue during the limitation period.

## Errors

The API returns two primary error messages for rate-limit scenarios:

- **`EAPI:Rate limit exceeded`** -- indicates the REST API counter has surpassed the user's maximum threshold
- **`EService: Throttled: [UNIX timestamp]`** -- signals excessive concurrent requests; retry after the specified timestamp
