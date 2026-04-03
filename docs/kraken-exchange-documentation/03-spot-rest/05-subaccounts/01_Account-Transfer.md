# Account Transfer

> Source: https://docs.kraken.com/api/docs/rest-api/account-transfer

## Endpoint
`POST /0/private/AccountTransfer`

## Description
Transfer funds between the master account and subaccounts. This operation must be called using an API key from the master account.

## Authentication
Requires a valid API key with the following permission:
- `Funds permissions - Withdraw`

The API key must belong to the **master account**.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | Yes | Asset to transfer (e.g., `XBT`, `ETH`, `USD`). |
| `amount` | string | Yes | Amount to transfer. |
| `from` | string | Yes | Source account. The IIBAN or account identifier of the source (master or subaccount). |
| `to` | string | Yes | Destination account. The IIBAN or account identifier of the destination (master or subaccount). |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Transfer result object. |
| `result.transfer_id` | string | Unique identifier for the transfer. |
| `result.status` | string | Status of the transfer (e.g., `complete`, `pending`). |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/AccountTransfer" \
  -H "API-Key: YOUR_MASTER_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&asset=XBT&amount=1.0&from=MASTER_IIBAN&to=SUB_IIBAN"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "transfer_id": "TOH3AS2-LPCWR8-JDQGEU",
    "status": "complete"
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission or is not from the master account. |
| `EFunding:Unknown asset` | The specified asset is not recognized. |
| `EFunding:Insufficient funds` | Insufficient balance in the source account. |
| `EFunding:Unknown account` | The specified source or destination account was not found. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- This endpoint must be called with an API key from the master account. Subaccount-initiated transfers are not supported.
- Transfers between master and subaccounts are processed immediately (internal transfer).
- The `from` and `to` parameters use account identifiers (IIBANs) to specify the source and destination.
- Both directions are supported: master-to-subaccount and subaccount-to-master.
- The master account can transfer between any of its subaccounts by specifying the appropriate `from` and `to` values.
