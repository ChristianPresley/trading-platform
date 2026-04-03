# Get Fee Schedules

## Endpoint

```
GET /feeschedules
```

## Description

Lists all fee schedules available on the Kraken Futures platform. Fee schedules define the maker and taker fee rates applied to trades based on volume tiers.

## Authentication

This endpoint may be publicly accessible. No authentication is required to retrieve fee schedule information.

## Request Parameters

This endpoint does not accept any request parameters.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `feeSchedules` | array | List of fee schedule objects |
| `feeSchedules[].uid` | string | Unique identifier for the fee schedule |
| `feeSchedules[].name` | string | Name of the fee schedule |
| `feeSchedules[].tiers` | array | List of volume tier objects |
| `feeSchedules[].tiers[].makerFee` | number | Maker fee rate for this tier (decimal, e.g., 0.0002 = 0.02%) |
| `feeSchedules[].tiers[].takerFee` | number | Taker fee rate for this tier (decimal, e.g., 0.0005 = 0.05%) |
| `feeSchedules[].tiers[].usdVolume` | number | Minimum USD volume threshold for this tier |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/feeschedules"
```

## Example Response

```json
{
  "result": "success",
  "feeSchedules": [
    {
      "uid": "eef90775-995b-4596-9257-5e23a3f1b???",
      "name": "KF Fee Schedule",
      "tiers": [
        {
          "makerFee": 0.0002,
          "takerFee": 0.0005,
          "usdVolume": 0
        },
        {
          "makerFee": 0.00015,
          "takerFee": 0.0004,
          "usdVolume": 100000
        }
      ]
    }
  ]
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 500 | Internal server error |

## Notes

- This is version 3 of the fee schedules endpoint.
- Fee rates are expressed as decimals (e.g., 0.0002 represents 0.02%).
- Volume tiers determine the applicable fee rate based on the user's trailing 30-day trading volume.
- Related endpoint: Get Fee Schedule Volumes (`GET /feeschedules/volumes`) to retrieve your current volume for each fee schedule.
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-fee-schedules-v-3)
