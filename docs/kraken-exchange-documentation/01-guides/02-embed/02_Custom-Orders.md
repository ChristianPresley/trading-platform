# Embed: Custom Orders

> Source: https://docs.kraken.com/api/docs/guides/embed-custom-orders

## Overview

Custom orders are price-triggered trades that execute automatically when an asset reaches a target price. Use them to implement strategies like "Buy the Dip" (buy when price drops to a target), "Join the Rally" (buy when price rises to ride momentum), "Take the Profit" (sell when price rises to a target), and "Stop the Loss" (sell when price drops to limit losses) for your users.

### Prerequisites

- Payward Embed API credentials (see Authentication Guide)
- A verified user with an IIBAN and sufficient balance

### Custom Order Workflow

The workflow consists of three steps:

```
┌──────────────────────┐     ┌──────────────────┐     ┌────────────────────┐
│  Prospective Quote   │ ──> │   Create Order   │ ──> │  Monitor / Cancel  │
│  (optional preview)  │     │                  │     │                    │
└──────────────────────┘     └──────────────────┘     └────────────────────┘
  POST /quotes/prospective    POST /custom-orders      GET  /custom-orders
                                                       GET  /custom-orders/{id}
                                                       POST /custom-orders/{id}/cancel
```

1. **Prospective Quote** (optional): Preview indicative pricing at the target price so you can show your user what the trade would look like before they commit.
2. **Create Order**: Submit the custom order with a price trigger. The system monitors the market and executes the trade automatically when the condition is met.
3. **Monitor / Cancel**: List or retrieve orders to check their status. Cancel orders that haven't triggered yet.

## Trigger Conditions

| Condition | Description |
|-----------|-------------|
| `lte` | Trigger when price is **less than or equal** to target |
| `gte` | Trigger when price is **greater than or equal** to target |

The trigger price is denominated as a `base_asset`/`quote_asset` rate. For example, if `base_asset` is `BTC` and `quote_asset` is `USD`, a `target_price` of `"100000.00"` means "1 BTC = 100,000 USD". Equivalently, if `base_asset` is `USD` and `quote_asset` is `BTC`, a `target_price` of `"0.00001"` means "1 USD = 0.00001 BTC".

### Examples

- **Buy the Dip**: "Buy BTC when BTC/USD drops to 100,000" -- set `base_asset` to `BTC`, `quote_asset` to `USD`, `target_price` to `"100000.00"`, and `condition` to `lte`. The order triggers when the BTC/USD price is at or below 100,000.

- **Stop the Loss**: "Sell BTC when BTC/USD drops to 100,000" -- same trigger configuration as above, but with a sell action. The order triggers when the BTC/USD price is at or below 100,000.

- **Join the Rally**: "Buy BTC when BTC/USD rises to 100,000" -- set `base_asset` to `BTC`, `quote_asset` to `USD`, `target_price` to `"100000.00"`, and `condition` to `gte`. The order triggers when the BTC/USD price is at or above 100,000.

- **Take the Profit**: "Sell BTC when BTC/USD rises to 100,000" -- same trigger configuration as above, but with a sell action. The order triggers when the BTC/USD price is at or above 100,000.

## Execution Behavior

Custom orders are not guaranteed to execute at exactly the target price. The target price is a **trigger threshold**, not a limit price:

- **Buy the Dip / Stop the Loss**: The order triggers when the market price drops to or below the target. The actual execution price may be **lower** than the target price.
- **Join the Rally / Take the Profit**: The order triggers when the market price rises to or above the target. The actual execution price may be **higher** than the target price.

> **Note**: For orders where the execution price is **higher** than the market price and the user is spending the client's reserve fiat currency, an error will be returned at order creation. Because the execution price may be higher than the target, the final spend amount is unbounded upward -- this prevents a situation where a user creates an order that could spend more fiat than the client has approved.

## Step 1: Request a Prospective Quote (Optional)

Before creating an order, you can request a prospective quote to display **indicative** fees and amounts to the user at the target price. This is useful for showing the user what the trade would cost before they commit to creating the order. If the `trigger` is omitted, the response reflects current market prices instead.

> **Caution**: Prospective quote fees are indicative and may not be exact. The final execution price is determined when the trigger condition is met, which may differ from the target price. As a result, the actual fees at execution time may vary from those shown in the prospective quote.

### Python

```python
def request_prospective_quote(user_id):
    endpoint = "/b2b/quotes/prospective"
    nonce = int(time.time() * 1000000000)
    body = {
        "action": {
            "type": "spend",
            "amount": {
                "asset": "USD",
                "amount": "500.00",
            },
            "quote": {
                "asset": "BTC",
            },
            "fee_bps": "100",
            "spread_bps": "100",
        },
        "trigger": {
            "type": "price",
            "base_asset": "BTC",
            "quote_asset": "USD",
            "target_price": "100000.00",
            "condition": "lte",
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
```

### JavaScript

```javascript
async function requestProspectiveQuote(userId) {
  const endpoint = '/b2b/quotes/prospective';
  const nonce = Date.now() * 1000000;
  const body = {
    action: {
      type: 'spend',
      amount: { asset: 'USD', amount: '500.00' },
      quote: { asset: 'BTC' },
      fee_bps: '100',
      spread_bps: '100',
    },
    trigger: {
      type: 'price',
      base_asset: 'BTC',
      quote_asset: 'USD',
      target_price: '100000.00',
      condition: 'lte',
    },
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

### Response Example

```json
{
  "result": {
    "type": "spend",
    "spend": {
      "asset": "USD",
      "asset_class": "currency",
      "total": "500.00",
      "fee": "5.00",
      "subtotal": "495.00"
    },
    "receive": {
      "asset": "BTC",
      "asset_class": "currency",
      "total": "0.00990000",
      "fee": "0.00000000",
      "subtotal": "0.00990000"
    },
    "unit_price": {
      "asset": "BTC",
      "unit_price": "100000.00",
      "denomination_asset": "USD"
    }
  }
}
```

If you pass `quote_currency` in the request body, the response will also include `quoted_spend`, `quoted_receive`, and `quoted_unit_price` fields denominated in that currency.

## Step 2: Create a Custom Order

Submit the order with a `name`, `trigger`, and `action`. The `name` is a display label your user can identify the order by.

### Python

```python
def create_custom_order(user_id):
    endpoint = "/b2b/custom-orders"
    nonce = int(time.time() * 1000000000)
    body = {
        "name": "Buy BTC at 100k",
        "trigger": {
            "type": "price",
            "base_asset": "BTC",
            "quote_asset": "USD",
            "target_price": "100000.00",
            "condition": "lte",
        },
        "action": {
            "type": "spend",
            "amount": {
                "asset": "USD",
                "amount": "500.00",
            },
            "quote": {
                "asset": "BTC",
            },
            "fee_bps": "100",
            "spread_bps": "100",
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

order = create_custom_order(user_id)
order_id = order["result"]["order"]["id"]
print(f"Order created: {order_id}")
print(f"Status: {order['result']['order']['status']['status']}")
```

### JavaScript

```javascript
async function createCustomOrder(userId) {
  const endpoint = '/b2b/custom-orders';
  const nonce = Date.now() * 1000000;
  const body = {
    name: 'Buy BTC at 100k',
    trigger: {
      type: 'price',
      base_asset: 'BTC',
      quote_asset: 'USD',
      target_price: '100000.00',
      condition: 'lte',
    },
    action: {
      type: 'spend',
      amount: { asset: 'USD', amount: '500.00' },
      quote: { asset: 'BTC' },
      fee_bps: '100',
      spread_bps: '100',
    },
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

const order = await createCustomOrder(userId);
console.log('Order ID:', order.result.order.id);
console.log('Status:', order.result.order.status.status);
```

### Response Example

```json
{
  "result": {
    "order": {
      "id": "sched_abc123",
      "name": "Buy BTC at 100k",
      "action": {
        "type": "spend",
        "amount": {
          "asset": "USD",
          "asset_class": "currency",
          "amount": "500.00"
        },
        "quote": {
          "asset": "BTC"
        },
        "fee_bps": "100",
        "spread_bps": "100"
      },
      "trigger": {
        "type": "price",
        "base_asset": "BTC",
        "quote_asset": "USD",
        "target_price": "100000.00",
        "condition": "lte"
      },
      "created_at": "2026-02-20T10:00:00Z",
      "updated_at": "2026-02-20T10:00:00Z",
      "status": {
        "status": "active"
      }
    }
  }
}
```

## Step 3: Monitor Orders

### Get a Single Order

#### Python

```python
def get_custom_order(user_id, order_id):
    endpoint = f"/b2b/custom-orders/{order_id}"
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
async function getCustomOrder(userId, orderId) {
  const endpoint = `/b2b/custom-orders/${orderId}`;
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

### List Orders

You can filter by status using the `statuses` query parameter. Valid values are `active`, `cancelled`, and `completed`. If omitted, all statuses are returned. Use the `cursor` parameter for pagination.

#### Python

```python
def list_custom_orders(user_id, statuses=None):
    endpoint = "/b2b/custom-orders"
    nonce = int(time.time() * 1000000000)
    params = {"user": user_id}
    if statuses:
        params["statuses"] = statuses  # e.g. ["active", "completed"]
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

# List only active orders
orders = list_custom_orders(user_id, statuses=["active"])
for o in orders["result"]["orders"]:
    print(f"{o['name']} — {o['status']['status']}")
```

#### JavaScript

```javascript
async function listCustomOrders(userId, statuses = []) {
  const endpoint = '/b2b/custom-orders';
  const nonce = Date.now() * 1000000;
  const params = { user: userId };
  const searchParams = new URLSearchParams(params);
  for (const s of statuses) {
    searchParams.append('statuses', s);
  }
  const signature = getPaywardSignature(endpoint, null, API_SECRET, nonce, params);
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

const orders = await listCustomOrders(userId, ['active']);
for (const o of orders.result.orders) {
  console.log(`${o.name} — ${o.status.status}`);
}
```

### Order Statuses

| Status | Description |
|--------|-------------|
| `active` | Order is monitoring the market, waiting for the trigger condition to be met |
| `completed` | Trigger condition was met and the trade executed |
| `cancelled` | Order was cancelled (by user request or system) |

When an order is `cancelled`, the response includes a `reason` field explaining why.

## Step 4: Cancel an Order

Cancel an active order that hasn't triggered yet.

### Python

```python
def cancel_custom_order(user_id, order_id):
    endpoint = f"/b2b/custom-orders/{order_id}/cancel"
    nonce = int(time.time() * 1000000000)
    params = {"user": user_id}
    signature = get_payward_signature(endpoint, None, API_SECRET, nonce, params)
    headers = {
        "API-Key": API_KEY,
        "API-Sign": signature,
        "API-Nonce": str(nonce),
    }
    response = requests.post(
        f"{BASE_URL}{endpoint}",
        headers=headers,
        params=params,
    )
    return response.json()

result = cancel_custom_order(user_id, order_id)
print(f"Status: {result['result']['order']['status']['status']}")
# Output: Status: cancelled
```

### JavaScript

```javascript
async function cancelCustomOrder(userId, orderId) {
  const endpoint = `/b2b/custom-orders/${orderId}/cancel`;
  const nonce = Date.now() * 1000000;
  const params = { user: userId };
  const signature = getPaywardSignature(endpoint, null, API_SECRET, nonce, params);
  const url = `${BASE_URL}${endpoint}?user=${userId}`;
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'API-Key': API_KEY,
      'API-Sign': signature,
      'API-Nonce': String(nonce),
    },
  });
  return response.json();
}

const result = await cancelCustomOrder(userId, orderId);
console.log('Status:', result.result.order.status.status);
```

## Portfolio Transactions

Executed custom orders appear in the List Portfolio Transactions endpoint with the following transaction types:

| Transaction Type | Description |
|------------------|-------------|
| `custom_order` | Successfully executed custom order |
| `custom_order_failed` | Custom order execution that failed |

Filter for custom order transactions specifically:

```
GET /b2b/portfolio/transactions?user={iiban}&types=custom_order,custom_order_failed
```

## API Reference

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/b2b/quotes/prospective` | POST | Get indicative pricing at a target price |
| `/b2b/custom-orders` | POST | Create a custom order |
| `/b2b/custom-orders` | GET | List custom orders (filterable by status) |
| `/b2b/custom-orders/{order_id}` | GET | Get a single custom order |
| `/b2b/custom-orders/{id}/cancel` | POST | Cancel an active custom order |

## Further Reading

- [Custom Orders on the Kraken App](https://support.kraken.com/articles/10371946346132-custom-orders-on-the-kraken-app-) -- Kraken's product FAQ for custom orders. While written for the consumer app, it provides a useful reference for how custom order functionality works in practice.
