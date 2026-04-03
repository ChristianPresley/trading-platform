# Deallocate Earn Funds

> Source: https://docs.kraken.com/api/docs/rest-api/deallocate-strategy

## Endpoint
`POST /0/private/Earn/Deallocate`

## Description
Deallocate (remove) funds from an Earn strategy. The operation is asynchronous. If an HTTP `202` response is returned, clients should poll the `Earn/DeallocateStatus` endpoint to check for completion.

## Authentication
Requires a valid API key with the following permission:
- `Earn Funds`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `strategy_id` | string | Yes | The ID of the earn strategy to deallocate funds from. |
| `amount` | string | Yes | The amount to deallocate from the strategy. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | boolean | `true` if the deallocation request was accepted. |

A `200` response indicates the request was accepted. An HTTP `202` response indicates the request was accepted and is being processed asynchronously; poll `DeallocateStatus` for completion.

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/Earn/Deallocate" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&strategy_id=ESXUM7H-SJHQ6-KOQNNI&amount=50.0"
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
| `EEarn:Below min:(De)allocation operation amount less than minimum` | The deallocation amount is below the minimum for this strategy. |
| `EEarn:Busy:Another (de)allocation for the same strategy is in progress` | Another allocation or deallocation for this strategy is already in progress. |
| `EEarn:Invalid strategy ID` | The specified strategy ID is not valid. |
| `EFunding:Insufficient funds` | Not enough funds allocated to this strategy to deallocate the requested amount. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- Only one allocation or deallocation per user and strategy can be active simultaneously.
- While a deallocation is being processed, the `pending` attribute in allocation responses will reflect the deallocating amount (shown as a negative value).
- The `pending` flag in `DeallocateStatus` will be `true` while the operation is processing.
- For strategies with a `bonded` lock type, there will be an unbonding period before funds become available.
- For strategies with an `instant` lock type, deallocation is immediate.
- Use `Earn/DeallocateStatus` to poll for completion of the operation.
