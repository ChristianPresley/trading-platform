# Get Tradable Asset Pairs

> Source: https://docs.kraken.com/api/docs/rest-api/get-tradable-asset-pairs

## Endpoint

`GET https://api.kraken.com/0/public/AssetPairs`

## Description

Get tradable asset pairs.

## Authentication

None required. This is a public endpoint.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pair` | string | No | Asset pairs to get data for. Example: `BTC/USD,ETH/BTC` |
| `aclass_base` | string | No | Filters the asset class to retrieve. Default: `currency`. Possible values: `currency` (spot currency pairs), `tokenized_asset` (tokenized asset pairs, i.e. xstocks). |
| `info` | string | No | Info to retrieve. Default: `info`. Possible values: `info` (all info), `leverage` (leverage info), `fees` (fees schedule), `margin` (margin info). |
| `country_code` | ISO 3166-1 alpha-2 | No | Filter for response to only include pairs available in the provided country/region. Example: `GB` |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | string[] | Array of error messages. Empty on success. |
| `result` | object | Object with pair names as keys and AssetPair objects as values |

### AssetPair Object

Each key in `result` is a pair name (e.g., `XXBTZUSD`), with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `altname` | string | Alternate pair name (e.g., `XBTUSD`) |
| `wsname` | string | WebSocket pair name (if available, e.g., `XBT/USD`) |
| `aclass_base` | string | Asset class of base component |
| `base` | string | Asset ID of base component |
| `aclass_quote` | string | Asset class of quote component |
| `quote` | string | Asset ID of quote component |
| `lot` | string | **DEPRECATED** - Volume lot size |
| `pair_decimals` | integer | Number of decimal places for prices in this pair |
| `cost_decimals` | integer | Number of decimal places for cost of trades in pair (quote asset terms) |
| `lot_decimals` | integer | Number of decimal places for volume (base asset terms) |
| `lot_multiplier` | integer | Amount to multiply lot volume by to get currency volume |
| `leverage_buy` | integer[] | Array of leverage amounts available when buying |
| `leverage_sell` | integer[] | Array of leverage amounts available when selling |
| `fees` | array[] | Fee schedule array in `[<volume>, <percent fee>]` tuples |
| `fees_maker` | array[] | Maker fee schedule array in `[<volume>, <percent fee>]` tuples (if on maker/taker) |
| `fee_volume_currency` | string | Volume discount currency |
| `margin_call` | integer | Margin call level |
| `margin_stop` | integer | Stop-out/liquidation margin level |
| `ordermin` | string | Minimum order size (in terms of base currency) |
| `costmin` | string | Minimum order cost (in terms of quote currency) |
| `tick_size` | string | Minimum increment between valid price levels |
| `status` | string | Status of asset. Possible values: `online`, `cancel_only`, `post_only`, `limit_only`, `reduce_only`. |
| `long_position_limit` | integer | Maximum long margin position size (in terms of base currency) |
| `short_position_limit` | integer | Maximum short margin position size (in terms of base currency) |

## Example Request

### cURL

```bash
curl -L 'https://api.kraken.com/0/public/AssetPairs' \
  -H 'Accept: application/json'
```

### With Parameters

```bash
curl -L 'https://api.kraken.com/0/public/AssetPairs?pair=XBTUSD,ETHUSD' \
  -H 'Accept: application/json'
```

## Example Response

```json
{
  "error": [],
  "result": {
    "XXBTZUSD": {
      "altname": "XBTUSD",
      "wsname": "XBT/USD",
      "aclass_base": "currency",
      "base": "XXBT",
      "aclass_quote": "currency",
      "quote": "ZUSD",
      "lot": "unit",
      "cost_decimals": 5,
      "pair_decimals": 1,
      "lot_decimals": 8,
      "lot_multiplier": 1,
      "leverage_buy": [2, 3, 4, 5, 6, 7, 8, 9, 10],
      "leverage_sell": [2, 3, 4, 5, 6, 7, 8, 9, 10],
      "fees": [
        [0, 0.4],
        [10000, 0.35],
        [50000, 0.24],
        [100000, 0.22],
        [250000, 0.2],
        [500000, 0.18],
        [1000000, 0.16],
        [2500000, 0.14],
        [5000000, 0.12],
        [10000000, 0.1],
        [100000000, 0.08],
        [500000000, 0.05]
      ],
      "fees_maker": [
        [0, 0.25],
        [10000, 0.2],
        [50000, 0.14],
        [100000, 0.12],
        [250000, 0.1],
        [500000, 0.08],
        [1000000, 0.06],
        [2500000, 0.04],
        [5000000, 0.02],
        [10000000, 0.0],
        [100000000, 0.0],
        [500000000, 0.0]
      ],
      "fee_volume_currency": "ZUSD",
      "margin_call": 80,
      "margin_stop": 40,
      "ordermin": "0.00005",
      "costmin": "0.5",
      "tick_size": "0.1",
      "status": "online",
      "execution_venue": "international",
      "long_position_limit": 350,
      "short_position_limit": 250
    }
  }
}
```

## Notes

- The `lot` field is deprecated.
- Pair names returned use Kraken's internal naming convention (e.g., `XXBTZUSD` rather than `XBTUSD`). The `altname` and `wsname` fields provide more commonly used identifiers.
- The `fees` array contains taker fee tiers as `[volume_threshold, percent_fee]` tuples, where volume is measured in the `fee_volume_currency`.
- The `fees_maker` array follows the same format but applies to maker orders.
- The `country_code` parameter can be used to filter pairs available in a specific jurisdiction.
- When `info` is set to something other than `info`, only the relevant subset of fields will be returned.
