# Embed: Your First Trade

> Source: https://docs.kraken.com/api/docs/guides/embed-first-trade

## Overview

This guide walks you through executing your first trade using the Payward Embed API.

### Prerequisites

Users must have:

- Payward Embed API credentials (see Authentication Guide)
- A verified user with an IIBAN (Internet International Bank Account Number)
- Sufficient balance in the user's account

### Trading Workflow

The workflow follows three steps:

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│  Request Quote  │ ───>  │  Execute Quote  │ ───>  │  Monitor Status │
└─────────────────┘      └─────────────────┘      └─────────────────┘
     POST /quotes           PUT /quotes/{id}        GET /quotes/{id}
```

1. **Request Quote**: Get a price quote for desired trade
2. **Execute Quote**: Confirm and execute the quoted trade
3. **Monitor Status**: Poll until trade completes or listen for quote.executed webhook

## Step 1: Request a Quote

Request a quote to buy cryptocurrency with fiat currency. The quote locks in a price for a short period.

### Quote Types

| Type | Description | Use Case |
|------|-------------|----------|
| `spend` | Specify amount to spend | "I want to spend EUR50 on BTC" |
| `receive` | Specify amount to receive | "I want to receive 0.001 BTC" |

### Python Example

```python
import os
import json
import time
import hashlib
import hmac
import base64
import urllib.parse
import requests

API_KEY = os.environ.get("PAYWARD_API_KEY")
API_SECRET = os.environ.get("PAYWARD_API_SECRET")
BASE_URL = "https://nexus.kraken.com"

def get_payward_signature(urlpath, data, secret, nonce, params=None):
    if data is None:
        encoded = str(nonce).encode("utf-8")
    else:
        encoded = (str(nonce) + json.dumps(data)).encode("utf-8")
        sign_path = urlpath
    if params:
        query = urllib.parse.urlencode(params)
        sign_path += f"?{query}"
    message = sign_path.encode() + hashlib.sha256(encoded).digest()
    mac = hmac.new(base64.b64decode(secret), message, hashlib.sha512)
    return base64.b64encode(mac.digest()).decode()

def request_quote(user_id):
    endpoint = "/b2b/quotes"
    nonce = int(time.time() * 1000000000)  # Nanoseconds
    
    body = {
        "type": "spend",           # 'spend' fiat to buy crypto
        "amount": {
            "asset": "EUR",        # Currency to spend
            "amount": "50.00",     # Amount to spend
        },
        "fee_bps": "100",          # Fee in basis points (1%)
        "spread_bps": "100",       # Spread in basis points (1%)
        "quote": {
            "asset": "BTC",        # Cryptocurrency to receive
        },
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

user_id = "YOUR_USER_IIBAN"
quote = request_quote(user_id)
print(f"Quote ID: {quote['result']['quote_id']}")
print(f"You spend: {quote['result']['spend']['total']} {quote['result']['spend']['asset']}")
print(f"You receive: {quote['result']['receive']['total']} {quote['result']['receive']['asset']}")
```

### JavaScript Example

```javascript
import crypto from 'crypto';

const API_KEY = process.env.PAYWARD_API_KEY;
const API_SECRET = process.env.PAYWARD_API_SECRET;
const BASE_URL = 'https://nexus.kraken.com';

function getPaywardSignature(urlpath, data, secret, nonce, params = null) {
  const encoded = data === null
     ? String(nonce)
     : String(nonce) + JSON.stringify(data);
  let signPath = urlpath;
  if (params) {
    signPath += '?' + new URLSearchParams(params).toString();
  }
  const sha256Hash = crypto.createHash('sha256').update(encoded).digest();
  const message = Buffer.concat([Buffer.from(signPath), sha256Hash]);
  
  const secretBuffer = Buffer.from(secret, 'base64');
  const hmac = crypto.createHmac('sha512', secretBuffer);
  hmac.update(message);
  
  return hmac.digest('base64');
}

async function requestQuote(userId) {
  const endpoint = '/b2b/quotes';
  const nonce = Date.now() * 1000000;  // Nanoseconds
  
  const body = {
    type: 'spend',
    amount: { asset: 'EUR', amount: '50.00' },
    fee_bps: '100',
    spread_bps: '100',
    quote: { asset: 'BTC' },
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

const userId = 'YOUR_USER_IIBAN';
const quote = await requestQuote(userId);
console.log('Quote ID:', quote.result.quote_id);
```

### Response Example

```json
{
  "result": {
    "quote_id": "BQEXAMP-LE123-ABCDEF",
    "type": "spend",
    "status": "new",
    "expires": "2026-01-26T12:00:30Z",
    "spend": {
      "asset": "EUR",
      "total": "50.00",
      "fee": "0.50",
      "subtotal": "49.50"
    },
    "receive": {
      "asset": "BTC",
      "total": "0.00052341",
      "fee": "0.00000000",
      "subtotal": "0.00052341"
    },
    "unit_price": {
      "asset": "BTC",
      "unit_price": "94567.50",
      "denomination_asset": "EUR"
    }
  }
}
```

**Caution:** Quotes expire after 120 seconds (2 minutes). Execute the quote promptly or request a new one if it expires. The exact expiration time is returned in the `expires` field of the quote response.

## Step 2: Execute the Quote

Once you have a quote, execute it by making a PUT request with the quote ID.

### Python

```python
def execute_quote(user_id, quote_id):
    endpoint = f"/b2b/quotes/{quote_id}"
    nonce = int(time.time() * 1000000000)  # Nanoseconds
    
    params = {"user": user_id}
    signature = get_payward_signature(endpoint, None, API_SECRET, nonce, params)
    
    headers = {
        "API-Key": API_KEY,
        "API-Sign": signature,
        "API-Nonce": str(nonce),
    }
    
    response = requests.put(
        f"{BASE_URL}{endpoint}",
        headers=headers,
        params=params,
    )
    return response.json()

result = execute_quote(user_id, quote["result"]["quote_id"])
print(f"Status: {result['result']['status']}")
```

### JavaScript

```javascript
async function executeQuote(userId, quoteId) {
  const endpoint = `/b2b/quotes/${quoteId}`;
  const nonce = Date.now() * 1000000;  // Nanoseconds
  
  const params = { user: userId };
  const signature = getPaywardSignature(endpoint, null, API_SECRET, nonce, params);
  const url = `${BASE_URL}${endpoint}?user=${userId}`;
  const response = await fetch(url, {
    method: 'PUT',
    headers: {
      'API-Key': API_KEY,
      'API-Sign': signature,
      'API-Nonce': String(nonce),
    },
  });
  return response.json();
}

const result = await executeQuote(userId, quote.result.quote_id);
console.log('Status:', result.result.status);
```

## Step 3: Monitor Trade Status

After execution, poll the quote status until the trade completes.

### Status Values

| Status | Description |
|--------|-------------|
| `new` | Quote created, awaiting execution |
| `accepted` | Quote has been accepted for execution |
| `order_complete` | Trade order has been completed |
| `credit_transfer_complete` | Trade fully completed, funds transferred |
| `quote_cancelled` | Quote was cancelled or expired |
| `quote_execution_failed` | Trade execution failed |

### Python

```python
import time

def get_quote_status(user_id, quote_id):
    endpoint = f"/b2b/quotes/{quote_id}"
    nonce = int(time.time() * 1000000000)  # Nanoseconds
    
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

def wait_for_completion(user_id, quote_id, max_attempts=60):
    terminal_statuses = ["credit_transfer_complete", "quote_cancelled", "quote_execution_failed"]
    
    for i in range(max_attempts):
        status = get_quote_status(user_id, quote_id)
        current_status = status["result"]["status"]
        print(f"Status: {current_status}")
        
        if current_status == "credit_transfer_complete":
            print("Trade completed!")
            return status
        
        if current_status in terminal_statuses:
            raise Exception(f"Trade ended with status: {current_status}")
        
        time.sleep(1)
    raise Exception("Trade did not complete in time")

final = wait_for_completion(user_id, quote["result"]["quote_id"])
```

### JavaScript

```javascript
async function getQuoteStatus(userId, quoteId) {
  const endpoint = `/b2b/quotes/${quoteId}`;
  const nonce = Date.now() * 1000000;  // Nanoseconds
  
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

async function waitForCompletion(userId, quoteId, maxAttempts = 60) {
  const terminalStatuses = ['credit_transfer_complete', 'quote_cancelled', 'quote_execution_failed'];
  
  for (let i = 0; i < maxAttempts; i++) {
    const status = await getQuoteStatus(userId, quoteId);
    const currentStatus = status.result.status;
    console.log(`Status: ${currentStatus}`);
    
    if (currentStatus === 'credit_transfer_complete') {
      console.log('Trade completed!');
      return status;
    }
    
    if (terminalStatuses.includes(currentStatus)) {
      throw new Error(`Trade ended with status: ${currentStatus}`);
    }
    
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  
  throw new Error('Trade did not complete in time');
}

const final = await waitForCompletion(userId, quote.result.quote_id);
```

## Error Handling

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `quote_expired` | Quote timeout exceeded | Request a new quote and execute faster |
| `insufficient_balance` | User lacks funds | Check user balance before trading |
| `invalid_amount` | Amount too small/large | Check min/max limits for the asset |
| `asset_disabled` | Asset not tradable | Use List Assets to check availability |

### Best Practices

1. **Handle quote expiration**: Always be prepared to request a new quote
2. **Check asset availability**: Call List Assets before trading
3. **Verify user balance**: Ensure sufficient funds before requesting quotes
4. **Implement retry logic**: Network issues can cause temporary failures
5. **Log trace IDs**: Store the `x-trace-id` header for debugging
