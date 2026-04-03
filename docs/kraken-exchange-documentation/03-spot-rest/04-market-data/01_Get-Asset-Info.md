# Get Asset Info

> Source: https://docs.kraken.com/api/docs/rest-api/get-asset-info

## Endpoint

`GET https://api.kraken.com/0/public/Assets`

## Description

Get information about the assets that are available for deposit, withdrawal, trading and earn.

## Authentication

None required. This is a public endpoint.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `asset` | string | No | Comma delimited list of assets to get info on. Default: all available assets. Example: `XBT,ETH` |
| `aclass` | string | No | Filters the asset class to retrieve. Default: `currency`. Possible values: `currency`, `tokenized_asset`. `currency` = spot currency pairs. `tokenized_asset` = xstocks. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | string[] | Array of error messages. Empty on success. |
| `result` | object | Object with asset names as keys and AssetInfo objects as values |

### AssetInfo Object

Each key in `result` is an asset name (e.g., `BTC`, `ETH`), with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `aclass` | string | Asset class (e.g., `currency`) |
| `altname` | string | Alternate name (e.g., `XBT` for Bitcoin) |
| `decimals` | integer | Number of decimal places for record keeping amounts of this asset |
| `display_decimals` | integer | Number of decimal places shown for display purposes in frontends |
| `collateral_value` | number | Valuation as margin collateral (if applicable) |
| `status` | string | Status of asset. Possible values: `enabled`, `deposit_only`, `withdrawal_only`, `funding_temporarily_disabled`. |

## Example Request

### cURL

```bash
curl -L 'https://api.kraken.com/0/public/Assets' \
  -H 'Accept: application/json'
```

### With Parameters

```bash
curl -L 'https://api.kraken.com/0/public/Assets?asset=XBT,ETH' \
  -H 'Accept: application/json'
```

## Example Response

```json
{
  "error": [],
  "result": {
    "BTC": {
      "aclass": "currency",
      "altname": "XBT",
      "decimals": 10,
      "display_decimals": 5,
      "collateral_value": 0.99,
      "status": "enabled",
      "margin_rate": "0.01"
    },
    "ETH": {
      "aclass": "currency",
      "altname": "ETH",
      "decimals": 10,
      "display_decimals": 5,
      "collateral_value": 0.99,
      "status": "enabled",
      "margin_rate": "0.02"
    }
  }
}
```

## Notes

- If no `asset` parameter is provided, all available assets are returned.
- The `aclass` parameter can be used to filter between regular crypto/fiat assets (`currency`) and tokenized assets like xstocks (`tokenized_asset`).
- Asset names may use Kraken's internal naming convention (e.g., `XXBT` for Bitcoin, `XETH` for Ethereum, `ZUSD` for US Dollar).
