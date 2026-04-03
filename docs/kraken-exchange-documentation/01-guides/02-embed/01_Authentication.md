# Embed REST Authentication

> Source: https://docs.kraken.com/api/docs/guides/embed-rest-auth

## Overview

This page documents the authentication mechanism for Kraken's Embed REST API.

## Authentication Parameters

The Embed REST API requires three HTTP header parameters:

- **API-Key**: Your public API key
- **API-Sign**: HMAC-SHA512 signature of the request
- **API-Nonce**: Always increasing, unsigned 64-bit integer

An optional header is also available:

- **Kraken-Version**: API version string (e.g., `2025-04-15`); defaults to latest version if omitted

## Setting the API-Key Parameter

The `API-Key` header value is your **public** API key obtained from your Payward account representative.

**Critical distinction**: The public key appears in the `API-Key` header, while the private key is never transmitted -- it only generates the `API-Sign` signature.

## Setting the API-Sign Parameter

The `API-Sign` header contains a signature derived from: "URI path + SHA256(nonce + JSON body)" signed with your base64-decoded secret API key using HMAC-SHA512.

### Algorithm Steps

1. **Build the message**: Concatenate nonce with request body
   - GET requests: nonce only
   - POST/PUT requests: `nonce + JSON.stringify(body)`

2. **Hash the message**: Compute SHA256 of the encoded message

3. **Concatenate with path**: Combine URL path bytes with SHA256 hash

4. **Sign**: Generate HMAC-SHA512 using base64-decoded secret

5. **Encode**: Base64 encode the signature

### Code Examples

#### Python

```python
import json
import time
import hashlib
import hmac
import base64

def get_payward_signature(urlpath, data, secret, nonce):
    """
    Generate Payward Embed API signature.
    
    Args:
        urlpath: API endpoint (e.g., '/b2b/assets')
        data: Request body dict (None for GET requests)
        secret: Base64-encoded API secret
        nonce: Always-increasing integer
    Returns:
        Base64-encoded signature string
    """
    if data is None:
        encoded = str(nonce).encode('utf-8')
    else:
        encoded = (str(nonce) + json.dumps(data)).encode('utf-8')
    
    message = urlpath.encode() + hashlib.sha256(encoded).digest()
    mac = hmac.new(base64.b64decode(secret), message, hashlib.sha512)
    return base64.b64encode(mac.digest()).decode()

# Example usage
api_secret = "your-api-secret-here"
nonce = time.time_ns()  # Nanoseconds (recommended for high-throughput request bursts)
endpoint = "/b2b/assets"
signature = get_payward_signature(endpoint, None, api_secret, nonce)
print(f"API-Sign: {signature}")
```

#### Go

```go
package main

import (
    "crypto/hmac"
    "crypto/sha256"
    "crypto/sha512"
    "encoding/base64"
    "encoding/json"
    "fmt"
    "strconv"
    "time"
)

// GetPaywardSignature generates the Payward Embed API signature.
func GetPaywardSignature(urlpath string, data interface{}, secret string, nonce int64) (string, error) {
    var encoded string
    if data == nil {
        encoded = strconv.FormatInt(nonce, 10)
    } else {
        jsonData, err := json.Marshal(data)
        if err != nil {
            return "", err
        }
        encoded = strconv.FormatInt(nonce, 10) + string(jsonData)
    }
    
    sha := sha256.New()
    sha.Write([]byte(encoded))
    shaSum := sha.Sum(nil)
    
    message := append([]byte(urlpath), shaSum...)
    
    secretBytes, err := base64.StdEncoding.DecodeString(secret)
    if err != nil {
        return "", err
    }
    
    mac := hmac.New(sha512.New, secretBytes)
    mac.Write(message)
    macSum := mac.Sum(nil)
    
    return base64.StdEncoding.EncodeToString(macSum), nil
}

func main() {
    apiSecret := "your-api-secret-here"
    nonce := time.Now().UnixNano()  // Nanoseconds (recommended for high-throughput request bursts)
    endpoint := "/b2b/assets"
    signature, err := GetPaywardSignature(endpoint, nil, apiSecret, nonce)
    if err != nil {
        fmt.Println("Error:", err)
        return
    }
    fmt.Printf("API-Sign: %s\n", signature)
}
```

#### JavaScript

```javascript
import crypto from 'crypto';

/**
 * Generate Payward Embed API signature.
 * @param {string} urlpath - API endpoint (e.g., '/b2b/assets')
 * @param {Object|null} data - Request body (null for GET requests)
 * @param {string} secret - Base64-encoded API secret
 * @param {bigint|number|string} nonce - Always-increasing integer
 * @returns {string} Base64-encoded signature
 */
function getPaywardSignature(urlpath, data, secret, nonce) {
  const encoded = data === null
     ? String(nonce)
     : String(nonce) + JSON.stringify(data);
  
  const sha256Hash = crypto.createHash('sha256').update(encoded).digest();
  const message = Buffer.concat([Buffer.from(urlpath), sha256Hash]);
  
  const secretBuffer = Buffer.from(secret, 'base64');
  const hmac = crypto.createHmac('sha512', secretBuffer);
  hmac.update(message);
  
  return hmac.digest('base64');
}

// Example usage
const apiSecret = 'your-api-secret-here';
const nonce = process.hrtime.bigint().toString();  // Monotonic nanoseconds (recommended for JS)
const endpoint = '/b2b/assets';
const signature = getPaywardSignature(endpoint, null, apiSecret, nonce);
console.log(`API-Sign: ${signature}`);
```

## Setting the API-Nonce Parameter

The `API-Nonce` header value is an always-increasing, unsigned 64-bit integer for each request using a particular API key.

While a simple counter works, a common approach uses UNIX timestamps in milliseconds. For rapid sequential or parallel request bursts, higher-resolution nonce strategies (nanosecond values) reduce collisions. Maintain format consistency for each API key and ensure each new nonce exceeds the previous value. For JavaScript, `process.hrtime.bigint()` is recommended for its monotonic properties and immunity to wall-clock drift.

**Important**: Issues arise from out-of-order request arrival due to shared API keys across processes or system clock issues. When multiple workers share one API key, coordinate nonces through a centralized generator (Redis atomic counter, etc.). When configuring Domain Management API keys, use the "Custom number only used once window" setting and increase if receiving `Invalid nonce` errors.

### Nonce Examples

#### Python

```python
import time

# Nanosecond nonce (recommended for high-throughput request bursts)
nonce = time.time_ns()
```

#### Go

```go
import "time"

// Nanosecond nonce (recommended for high-throughput request bursts)
nonce := time.Now().UnixNano()
```

#### JavaScript

```javascript
// Monotonic nonce (recommended for JavaScript)
const nonce = process.hrtime.bigint().toString();
```

## Complete Request Example

### Python Implementation

```python
import os
import json
import time
import hashlib
import hmac
import base64
import requests

API_KEY = os.environ.get("PAYWARD_API_KEY")
API_SECRET = os.environ.get("PAYWARD_API_SECRET")
BASE_URL = "https://nexus.kraken.com"

def get_payward_signature(urlpath, data, secret, nonce):
    if data is None:
        encoded = str(nonce).encode("utf-8")
    else:
        encoded = (str(nonce) + json.dumps(data)).encode("utf-8")
    
    message = urlpath.encode() + hashlib.sha256(encoded).digest()
    mac = hmac.new(base64.b64decode(secret), message, hashlib.sha512)
    return base64.b64encode(mac.digest()).decode()

def list_assets():
    endpoint = "/b2b/assets"
    nonce = time.time_ns()  # Nanoseconds (recommended for high-throughput request bursts)
    signature = get_payward_signature(endpoint, None, API_SECRET, nonce)
    
    headers = {
        "API-Key": API_KEY,
        "API-Sign": signature,
        "API-Nonce": str(nonce),
    }
    
    response = requests.get(BASE_URL + endpoint, headers=headers)
    return response.json()

assets = list_assets()
print(assets)
```

### JavaScript Implementation

```javascript
import crypto from 'crypto';

const API_KEY = process.env.PAYWARD_API_KEY;
const API_SECRET = process.env.PAYWARD_API_SECRET;
const BASE_URL = 'https://nexus.kraken.com';

function getPaywardSignature(urlpath, data, secret, nonce) {
  const encoded = data === null
     ? String(nonce)
     : String(nonce) + JSON.stringify(data);
  
  const sha256Hash = crypto.createHash('sha256').update(encoded).digest();
  const message = Buffer.concat([Buffer.from(urlpath), sha256Hash]);
  
  const secretBuffer = Buffer.from(secret, 'base64');
  const hmac = crypto.createHmac('sha512', secretBuffer);
  hmac.update(message);
  
  return hmac.digest('base64');
}

async function listAssets() {
  const endpoint = '/b2b/assets';
  const nonce = process.hrtime.bigint().toString();  // Monotonic nanoseconds (recommended for JS)
  const signature = getPaywardSignature(endpoint, null, API_SECRET, nonce);
  
  const response = await fetch(BASE_URL + endpoint, {
    method: 'GET',
    headers: {
      'API-Key': API_KEY,
      'API-Sign': signature,
      'API-Nonce': String(nonce),
    },
  });
  
  return response.json();
}

const assets = await listAssets();
console.log(assets);
```

## Query Parameters in Signature

When requests include query parameters, they must appear in the URL path used for signature generation:

```javascript
// Include query params in the signature path
const params = { 'page[size]': 10, quote: 'USD' };
const queryString = new URLSearchParams(params).toString();
const signaturePath = `/b2b/assets?${queryString}`;
const signature = getPaywardSignature(signaturePath, null, API_SECRET, nonce);
```

## Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `Invalid signature` | Signature doesn't match | Verify secret encoding, nonce, and body format |
| `Invalid nonce` | Nonce is not increasing | Ensure nonce > previous nonce |
| `Missing API-Key` | Header not set | Check header name is exactly `API-Key` |
