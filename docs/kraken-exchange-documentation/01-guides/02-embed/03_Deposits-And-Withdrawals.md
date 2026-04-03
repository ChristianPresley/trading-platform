# Embed: Deposits & Withdrawals

> Source: https://docs.kraken.com/api/docs/guides/embed-deposits-and-withdrawals

## Overview

This guide enables crypto deposits and withdrawals for users via the Payward Embed API.

### Prerequisites

- Payward Embed API credentials (see Authentication Guide)
- A verified user with an IIBAN
- **Note:** Only cryptocurrency deposits are supported; fiat deposits unavailable

---

## Crypto Deposits

### Deposit Workflow

The deposit process follows these stages:

1. List Deposit Methods
2. Create Deposit Address
3. Display Address to User
4. User Sends Crypto
5. Receive Webhooks

Completed deposits appear in `GET /b2b/portfolio/transactions?user={iiban}&types=deposit`.

### Step 1: List Deposit Methods

Query available deposit methods for a crypto asset using the `method_id` for address creation.

#### Python

```python
def list_deposit_methods(user_id, asset):
    endpoint = f"/b2b/funds/deposits/methods/{asset}"
    nonce = int(time.time() * 1000000000)
    params = {"user": user_id}
    signature = get_payward_signature(endpoint, None, API_SECRET, nonce, params)
    headers = {
        "API-Key": API_KEY,
        "API-Sign": signature,
        "API-Nonce": str(nonce),
    }
    response = requests.get(
        f"{BASE_URL}{endpoint}",
        headers=headers,
        params=params,
    )
    return response.json()
```

#### JavaScript

```javascript
async function listDepositMethods(userId, asset) {
  const endpoint = `/b2b/funds/deposits/methods/${asset}`;
  const nonce = Date.now() * 1000000;
  const params = { user: userId };
  const signature = getPaywardSignature(endpoint, null, API_SECRET, nonce, params);
  const url = `${BASE_URL}${endpoint}?user=${userId}`;
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'API-Key': API_KEY,
      'API-Sign': signature,
      'API-Nonce': String(nonce),
    },
  });
  return response.json();
}
```

#### Response Example

```json
{
  "result": {
    "methods": [
      {
        "method_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "network": "Bitcoin",
        "fee": { "asset": "BTC", "amount": "0.00000000" },
        "fee_percentage": "0.00",
        "minimum": { "asset": "BTC", "amount": "0.00010000" },
        "maximum": { "asset": "BTC", "amount": "100.00000000" },
        "address_setup_fee": { "asset": "BTC", "amount": "0.00000000" },
        "network_info": {
          "explorer": "https://blockchair.com/bitcoin",
          "confirmations": "3",
          "est_confirmation_time": "45"
        }
      }
    ]
  }
}
```

Display to users: `network`, `fee`, `minimum`, and `est_confirmation_time`.

**Note:** Most cryptocurrency deposits are free; some charge an `address_setup_fee` or per-deposit `fee`.

### Step 2: Create a Deposit Address

Generate a deposit address using the `method_id` from Step 1.

#### Python

```python
def create_deposit_address(user_id, asset, method_id):
    endpoint = "/b2b/funds/deposits/addresses"
    nonce = int(time.time() * 1000000000)
    body = {
        "asset": asset,
        "method_id": method_id,
    }
    params = {"user": user_id}
    signature = get_payward_signature(endpoint, body, API_SECRET, nonce, params)
    headers = {
        "API-Key": API_KEY,
        "API-Sign": signature,
        "API-Nonce": str(nonce),
        "Content-Type": "application/json",
    }
    response = requests.post(
        f"{BASE_URL}{endpoint}",
        headers=headers,
        params=params,
        json=body,
    )
    return response.json()
```

#### JavaScript

```javascript
async function createDepositAddress(userId, asset, methodId) {
  const endpoint = '/b2b/funds/deposits/addresses';
  const nonce = Date.now() * 1000000;
  const body = {
    asset: asset,
    method_id: methodId,
  };
  const params = { user: userId };
  const signature = getPaywardSignature(endpoint, body, API_SECRET, nonce, params);
  const url = `${BASE_URL}${endpoint}?user=${userId}`;
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'API-Key': API_KEY,
      'API-Sign': signature,
      'API-Nonce': String(nonce),
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  return response.json();
}
```

#### Response Example

```json
{
  "result": {
    "address": "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
    "name": "Bitcoin",
    "tag": null,
    "memo": null,
    "expire_time": null,
    "is_new": true
  }
}
```

**Important:** Some networks (XRP, XLM) require a `tag` or `memo`. If present, display prominently and instruct users to include it. Missing tags/memos can result in lost funds.

### Step 3: List Deposit Addresses

Retrieve existing deposit addresses for a given asset and method to display previously generated addresses.

#### Python

```python
def list_deposit_addresses(user_id, asset, method_id, cursor=None):
    endpoint = "/b2b/funds/deposits/addresses"
    nonce = int(time.time() * 1000000000)
    params = {
        "user": user_id,
        "asset": asset,
        "method_id": method_id,
    }
    if cursor:
        params["cursor"] = cursor
    signature = get_payward_signature(endpoint, None, API_SECRET, nonce, params)
    headers = {
        "API-Key": API_KEY,
        "API-Sign": signature,
        "API-Nonce": str(nonce),
    }
    response = requests.get(
        f"{BASE_URL}{endpoint}",
        headers=headers,
        params=params,
    )
    return response.json()
```

#### JavaScript

```javascript
async function listDepositAddresses(userId, asset, methodId, cursor = null) {
  const endpoint = '/b2b/funds/deposits/addresses';
  const nonce = Date.now() * 1000000;
  const params = { user: userId, asset, method_id: methodId };
  if (cursor) params.cursor = cursor;
  const signature = getPaywardSignature(endpoint, null, API_SECRET, nonce, params);
  const searchParams = new URLSearchParams(params);
  const url = `${BASE_URL}${endpoint}?${searchParams.toString()}`;
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'API-Key': API_KEY,
      'API-Sign': signature,
      'API-Nonce': String(nonce),
    },
  });
  return response.json();
}
```

#### Response Example

```json
{
  "result": {
    "addresses": [
      {
        "address": "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
        "tag": null,
        "memo": null,
        "method_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "asset": "BTC",
        "fee": { "asset": "BTC", "amount": "0.00000000" },
        "minimum": { "asset": "BTC", "amount": "0.00010000" },
        "maximum": { "asset": "BTC", "amount": "100.00000000" },
        "expire_time": null,
        "last_deposit_at": null
      }
    ],
    "next_cursor": null
  }
}
```

### Deposit Best Practices

1. Always display tag/memo prominently for networks requiring them
2. Show minimum amounts and confirmation times before users send funds
3. Fetch fresh data before displaying options rather than relying on cached results
4. Available methods and limits are user-specific and may change based on account standing or regulations

---

## Crypto Withdrawals

Withdrawals use key-based storage: save an address once, then use its `key` in withdrawal requests.

### Withdrawal Workflow

1. List Withdrawal Methods
2. Validate Address (optional)
3. Save Address (create key)
4. Preview / Submit Withdrawal
5. Monitor Status (webhook / polling)

### Step 1: List Withdrawal Methods

Determine valid `method_id`, fee estimates, limits, and optional `fee_token`.

#### Python

```python
def list_withdrawal_methods(user_id, asset):
    endpoint = f"/b2b/funds/withdrawals/methods/{asset}"
    nonce = int(time.time() * 1000000000)
    params = {"user": user_id}
    signature = get_payward_signature(endpoint, None, API_SECRET, nonce, params)
    headers = {
        "API-Key": API_KEY,
        "API-Sign": signature,
        "API-Nonce": str(nonce),
    }
    response = requests.get(
        f"{BASE_URL}{endpoint}",
        headers=headers,
        params=params,
    )
    return response.json()
```

#### JavaScript

```javascript
async function listWithdrawalMethods(userId, asset) {
  const endpoint = `/b2b/funds/withdrawals/methods/${asset}`;
  const nonce = Date.now() * 1000000;
  const params = { user: userId };
  const signature = getPaywardSignature(endpoint, null, API_SECRET, nonce, params);
  const url = `${BASE_URL}${endpoint}?user=${userId}`;
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'API-Key': API_KEY,
      'API-Sign': signature,
      'API-Nonce': String(nonce),
    },
  });
  return response.json();
}
```

#### Response Example

```json
{
  "result": {
    "methods": [
      {
        "method_id": "00e4796b-a142-4589-a7c1-8927933788c9",
        "network": "Bitcoin",
        "fee": { "asset": "BTC", "amount": "0.00020000" },
        "fee_token": "wft_abc123",
        "minimum": { "asset": "BTC", "amount": "0.00050000" },
        "maximum": { "asset": "BTC", "amount": "1.00000000" }
      }
    ]
  }
}
```

### Step 2: Validate Withdrawal Address (Recommended)

Validate the destination address before saving it.

#### Python

```python
def validate_withdrawal_address(asset, method_id, address, memo=None):
    endpoint = "/b2b/funds/withdrawals/addresses/validate"
    nonce = int(time.time() * 1000000000)
    body = {
        "asset": asset,
        "method_id": method_id,
        "address": address,
        "memo": memo,
    }
    signature = get_payward_signature(endpoint, body, API_SECRET, nonce)
    headers = {
        "API-Key": API_KEY,
        "API-Sign": signature,
        "API-Nonce": str(nonce),
        "Content-Type": "application/json",
    }
    response = requests.post(
        f"{BASE_URL}{endpoint}",
        headers=headers,
        json=body,
    )
    return response.json()
```

#### JavaScript

```javascript
async function validateWithdrawalAddress(asset, methodId, address, memo = null) {
  const endpoint = '/b2b/funds/withdrawals/addresses/validate';
  const nonce = Date.now() * 1000000;
  const body = { asset, method_id: methodId, address, memo };
  const signature = getPaywardSignature(endpoint, body, API_SECRET, nonce);
  const response = await fetch(`${BASE_URL}${endpoint}`, {
    method: 'POST',
    headers: {
      'API-Key': API_KEY,
      'API-Sign': signature,
      'API-Nonce': String(nonce),
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  return response.json();
}
```

### Step 3: Save Withdrawal Address

Save the address once and retain the `key` for future withdrawals.

#### Python

```python
def save_withdrawal_address(user_id, asset, method_id, key, address, memo=None, tag=None):
    endpoint = "/b2b/funds/withdrawals/addresses"
    nonce = int(time.time() * 1000000000)
    body = {
        "asset": asset,
        "method_id": method_id,
        "key": key,
        "address": address,
        "memo": memo,
        "tag": tag,
    }
    params = {"user": user_id}
    signature = get_payward_signature(endpoint, body, API_SECRET, nonce, params)
    headers = {
        "API-Key": API_KEY,
        "API-Sign": signature,
        "API-Nonce": str(nonce),
        "Content-Type": "application/json",
    }
    response = requests.post(
        f"{BASE_URL}{endpoint}",
        headers=headers,
        params=params,
        json=body,
    )
    return response.json()
```

#### JavaScript

```javascript
async function saveWithdrawalAddress(userId, asset, methodId, key, address, memo = null, tag = null) {
  const endpoint = '/b2b/funds/withdrawals/addresses';
  const nonce = Date.now() * 1000000;
  const body = { asset, method_id: methodId, key, address, memo, tag };
  const params = { user: userId };
  const signature = getPaywardSignature(endpoint, body, API_SECRET, nonce, params);
  const url = `${BASE_URL}${endpoint}?user=${userId}`;
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'API-Key': API_KEY,
      'API-Sign': signature,
      'API-Nonce': String(nonce),
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  return response.json();
}
```

### Step 4: Preview and Submit a Withdrawal

Use `preview=true` to quote fees and totals without creating a withdrawal, then submit with `preview=false`.

#### Python

```python
def withdraw_funds(user_id, asset, key, amount, idempotency_token, preview=False, fee_token=None):
    endpoint = "/b2b/funds/withdrawals"
    nonce = int(time.time() * 1000000000)
    body = {
        "asset": asset,
        "key": key,
        "amount": amount,
        "idempotency_token": idempotency_token,
        "preview": preview,
        "fee_token": fee_token,
    }
    params = {"user": user_id}
    signature = get_payward_signature(endpoint, body, API_SECRET, nonce, params)
    headers = {
        "API-Key": API_KEY,
        "API-Sign": signature,
        "API-Nonce": str(nonce),
        "Content-Type": "application/json",
    }
    response = requests.post(
        f"{BASE_URL}{endpoint}",
        headers=headers,
        params=params,
        json=body,
    )
    return response.json()
```

#### JavaScript

```javascript
async function withdrawFunds(userId, asset, key, amount, idempotencyToken, preview = false, feeToken = null) {
  const endpoint = '/b2b/funds/withdrawals';
  const nonce = Date.now() * 1000000;
  const body = {
    asset,
    key,
    amount,
    idempotency_token: idempotencyToken,
    preview,
    fee_token: feeToken,
  };
  const params = { user: userId };
  const signature = getPaywardSignature(endpoint, body, API_SECRET, nonce, params);
  const url = `${BASE_URL}${endpoint}?user=${userId}`;
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'API-Key': API_KEY,
      'API-Sign': signature,
      'API-Nonce': String(nonce),
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  return response.json();
}
```

### Withdrawal Statuses

| Status | Description |
|--------|-------------|
| `pending` | Withdrawal detected and being processed |
| `held` | Held for review |
| `success` | Completed successfully |
| `failure` | Failed (terminal) |

### Withdrawal Best Practices

1. Generate unique `idempotency_token` per intended withdrawal to avoid duplicate sends
2. Run preview requests immediately before submit
3. `fee_token` values are short-lived; if rejected, fetch withdrawal methods again for a new token
4. Store which `key` belongs to each user and enforce access checks
5. For XRP/XLM-like networks, capture and persist memo/tag fields
6. Subscribe to `withdrawal.status_updated` webhooks to reconcile events

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `EGeneral:Bad data` | Invalid payload (malformed key or amount) | Validate payload before sending |
| `ENexus:Unknown asset` | Asset not recognized | Verify asset code (e.g., `BTC`, `ETH`) |
| `EFunding:Unknown withdraw key` | Saved key not found | Re-list addresses and use existing key |
| `EFunding:Duplicate withdraw key` | Key already exists | Choose unique key per saved address |

---

## API Reference

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/b2b/funds/deposits/methods/{asset}` | GET | List deposit methods for an asset |
| `/b2b/funds/deposits/addresses` | POST | Create a new deposit address |
| `/b2b/funds/deposits/addresses` | GET | List existing deposit addresses |
| `/b2b/funds/withdrawals/methods/{asset}` | GET | List withdrawal methods for an asset |
| `/b2b/funds/withdrawals/addresses/validate` | POST | Validate withdrawal address without saving |
| `/b2b/funds/withdrawals/addresses` | POST | Save a withdrawal address |
| `/b2b/funds/withdrawals/addresses` | GET | List saved withdrawal addresses |
| `/b2b/funds/withdrawals/addresses/{key}` | PATCH | Rename a saved withdrawal key |
| `/b2b/funds/withdrawals/addresses/{key}` | DELETE | Delete a saved withdrawal address |
| `/b2b/funds/withdrawals` | POST | Preview or submit a withdrawal |
| `/b2b/webhooks` | POST | Register for deposit/withdrawal status webhooks |
