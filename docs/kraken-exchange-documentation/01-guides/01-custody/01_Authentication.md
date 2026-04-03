# Custody REST Authentication

> Source: https://docs.kraken.com/api/docs/guides/custody-rest-auth

## Overview

The Custody REST API uses API keys to authenticate and authorize API requests through a secure authentication process.

## API Users and Access Control

API users function similarly to human users in that they are assigned roles, permissions, and vault access at the time of creation. However, they cannot log into the Custody application directly -- their interaction is limited strictly to API calls.

## Creating a New API Key

A system administrator must follow these steps:

1. Log in to your Custody environment
2. Navigate to Settings -> Users -> API Users
3. Submit a request for a new API user and complete two-factor authentication (2FA)
4. The request appears under Tasks -> Pending until Admin Quorum approval
5. Once approved, open request details to view API key information
6. The admin who submitted can access the key and secret from the API key details page

**Important:** Only the admin user who created the API user request can view the API key and secret. Store these credentials securely. The credentials will not be viewable again after generation.

## Authentication Parameters

Three parameters authenticate REST API requests to private data endpoints:

- **`API-Key`** HTTP header: your public API key
- **`API-Sign`** HTTP header: encrypted signature of message
- **`nonce`** payload parameter: always increasing unsigned 64-bit integer

## Setting the API-Key Parameter

The value for the `API-Key` HTTP header parameter is your **public** API key. Clearly distinguish between the public key (sent in header) and private key (used only for encoding the signature).

## Setting the API-Sign Parameter

The value for the `API-Sign` HTTP header parameter is a signature generated from encoding your **private** API key, nonce, encoded payload, and URI path.

**Formula:**

```
HMAC-SHA512 of (URI path + SHA256(nonce + POST data)) and base64 decoded secret API key
```

The URI path used for API-Sign should be the part starting with "/0/private" of the API URL.

### Signature Example

| Field | Value |
|-------|-------|
| Private Key | `kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==` |
| Nonce | `1616492376594` |
| Encoded Payload | `nonce=1616492376594` |
| URI Path | `/0/private/GetCustodyTask?id=TGWOJ4JQPOTZT2` |
| **API-Sign** | **`2rM09q8HG7LvjivBitQUybwZ/DSeO8+i0U/at/wclH2Jma6gMaE/0Nw9dyLR+ykMd5eWCngSL4K58i6uJzXDCw==`** |

### Code Examples

#### Python

```python
import urllib.parse
import hashlib
import hmac
import base64

def get_kraken_signature(urlpath, data, secret):
    if isinstance(data, str):
        encoded = (str(json.loads(data)["nonce"]) + data).encode()
    else:
        encoded = (str(data["nonce"]) + urllib.parse.urlencode(data)).encode()
    message = urlpath.encode() + hashlib.sha256(encoded).digest()
    mac = hmac.new(base64.b64decode(secret), message, hashlib.sha512)
    sigdigest = base64.b64encode(mac.digest())
    return sigdigest.decode()

api_sec = "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg=="
payload = {
  "nonce": 1616492376594,
}
signature = get_kraken_signature("/0/private/GetCustodyTask?id=TGWOJ4JQPOTZT2", payload, api_sec)
print("API-Sign: {}".format(signature))
```

#### Go

```go
package main

import (
    "crypto/hmac"
    "crypto/sha256"
    "crypto/sha512"
    "encoding/base64"
    "net/url"
    "fmt"
    "encoding/json"
    "strings"
)

func getKrakenSignature(urlPath string, data interface{}, secret string) (string, error) {
    var encodedData string
    switch v := data.(type) {
    case string:
        var jsonData map[string]interface{}
        if err := json.Unmarshal([]byte(v), &jsonData); err != nil {
            return "", err
        }
        encodedData = jsonData["nonce"].(string) + v
    case map[string]interface{}:
        dataMap := url.Values{}
        for key, value := range v {
            dataMap.Set(key, fmt.Sprintf("%v", value))
        }
        encodedData = v["nonce"].(string) + dataMap.Encode()
    default:
        return "", fmt.Errorf("invalid data type")
    }
    sha := sha256.New()
    sha.Write([]byte(encodedData))
    shasum := sha.Sum(nil)
    message := append([]byte(urlPath), shasum...)
    mac := hmac.New(sha512.New, base64.StdEncoding.DecodeString(secret))
    mac.Write(message)
    macsum := mac.Sum(nil)
    sigDigest := base64.StdEncoding.EncodeToString(macsum)
    return sigDigest, nil
}

func main() {
    apiSecret := "kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg=="
    payload := map[string]interface{}{
        "nonce":     1616492376594,
    }
    signature, err := getKrakenSignature("/0/private/GetCustodyTask?id=TGWOJ4JQPOTZT2", payload, apiSecret)
    if err != nil {
        fmt.Println("Error generating signature:", err)
        return
    }
    fmt.Printf("API-Sign: %s\n", signature)
}
```

#### Node.js

```javascript
const crypto = require('crypto');
const querystring = require('querystring');

function getKrakenSignature(urlPath, data, secret) {
  let encoded;
  if (typeof data === 'string') {
    const jsonData = JSON.parse(data);
    encoded = jsonData.nonce + data;
  } else if (typeof data === 'object') {
    const dataStr = querystring.stringify(data);
    encoded = data.nonce + dataStr;
  } else {
    throw new Error('Invalid data type');
  }
  const sha256Hash = crypto.createHash('sha256').update(encoded).digest();
  const message = urlPath + sha256Hash.toString('binary');
  const secretBuffer = Buffer.from(secret, 'base64');
  const hmac = crypto.createHmac('sha512', secretBuffer);
  hmac.update(message, 'binary');
  const signature = hmac.digest('base64');
  return signature;
}

const apiSec = 'kQH5HW/8p1uGOVjbgWA7FunAmGO8lsSUXNsu3eow76sz84Q18fWxnyRzBHCd3pd5nE9qa99HAZtuZuj6F1huXg==';
const payload = JSON.stringify({
  nonce: 1616492376594,
});
const signature = getKrakenSignature('/0/private/GetCustodyTask?id=TGWOJ4JQPOTZT2', payload, apiSec);
console.log(`API-Sign: ${signature}`);
```

## Setting the nonce Parameter

The value for the `nonce` payload body parameter is an always increasing, unsigned 64-bit integer for each request that is made with a particular API key.

While a simple counter works, UNIX timestamp in milliseconds is more common. There is no way to reset the nonce for an API key to a lower value, so be sure to use a nonce generation method that won't produce numbers less than the previous nonce.

**Important:** Too many requests with invalid nonces (`EAPI:Invalid nonce`) can result in temporary bans.

Problems can arise from out-of-order requests due to shared API keys across processes or system clock drift. An optional "nonce window" can be configured for tolerance between values.

### Nonce Generation Examples

#### Python

```python
import time
api_nonce = time.time_ns()
```

#### JavaScript

```javascript
const api_nonce = Date.now()
```

#### PHP

```php
$api_nonce = explode(' ', microtime());
$api_nonce = $api_nonce[1].substr($api_nonce[0], 2, 3);
```
