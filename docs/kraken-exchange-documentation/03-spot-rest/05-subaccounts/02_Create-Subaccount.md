# Create Subaccount

> Source: https://docs.kraken.com/api/docs/rest-api/create-subaccount

## Endpoint
`POST /0/private/CreateSubaccount`

## Description
Create a trading subaccount. **Note:** `CreateSubaccount` must be called using an API key from the master account, not from a subaccount.

## Authentication
Requires a valid API key with the following permission:
- `Funds permissions - Withdraw`

The API key must belong to the **master account**.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `username` | string | Yes | Username for the new subaccount. |
| `email` | string | Yes | Email address for the new subaccount. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | boolean | `true` if the subaccount was created successfully. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/CreateSubaccount" \
  -H "API-Key: YOUR_MASTER_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&username=mysubaccount&email=sub@example.com"
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
| `EGeneral:Permission denied` | API key does not have the required permission or is not from the master account. |
| `EGeneral:Internal error` | An internal error occurred during subaccount creation. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- This endpoint must be called with an API key from the master account.
- Subaccount API keys must be created separately after the subaccount is created.
- Subaccounts inherit certain properties from the master account but operate with independent balances and order books.
- The master account can transfer funds to/from subaccounts using the `AccountTransfer` endpoint.
