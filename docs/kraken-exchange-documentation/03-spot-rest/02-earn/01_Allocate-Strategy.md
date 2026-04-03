# Allocate Earn Funds

> Source: https://docs.kraken.com/api/docs/rest-api/allocate-strategy

## Endpoint
`POST /0/private/Earn/Allocate`

## Description
Allocate funds to an Earn strategy. The operation is asynchronous. A successful initial response does not guarantee completion. Clients should poll the `Earn/AllocateStatus` endpoint to check for the result.

## Authentication
Requires a valid API key with the following permission:
- `Earn Funds`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `strategy_id` | string | Yes | The ID of the earn strategy to allocate funds to. |
| `amount` | string | Yes | The amount to allocate to the strategy. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | boolean | `true` if the allocation request was accepted. |

A `200` response indicates the request was accepted. An HTTP `202` response indicates the request was accepted and is being processed asynchronously; poll `AllocateStatus` for completion.

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/Earn/Allocate" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&strategy_id=ESXUM7H-SJHQ6-KOQNNI&amount=100.0"
```

## Example Response

```json
{
  "error": [],
  "result": true
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EGeneral:Permission denied:The user's tier is not high enough` | The user's verification tier does not meet the strategy's requirements. |
| `EEarn:Below min:(De)allocation operation amount less than minimum` | The allocation amount is below the minimum for this strategy. |
| `EEarn:Busy:Another (de)allocation for the same strategy is in progress` | Another allocation or deallocation for this strategy is already in progress. |
| `EEarn:Busy` | The Earn service is temporarily unavailable. |
| `EEarn:Invalid strategy ID` | The specified strategy ID is not valid. |
| `EFunding:Insufficient funds` | Insufficient funds for the allocation. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- Only one allocation or deallocation per user and strategy can be active simultaneously.
- While an allocation is being processed, the `pending` attribute in allocation responses will reflect the allocating amount.
- The amount parameter is mandatory.
- Earn products generally require Intermediate verification tier or higher.
- Use `Earn/AllocateStatus` to poll for completion of the operation.
- If the allocation fails asynchronously, the error will be available via `AllocateStatus`.
