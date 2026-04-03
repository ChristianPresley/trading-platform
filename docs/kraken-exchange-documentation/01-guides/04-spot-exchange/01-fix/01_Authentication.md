# FIX Authentication

> Source: https://docs.kraken.com/api/docs/guides/fix-auth

## Overview

The Kraken FIX API requires authentication through two layers: initial `SenderCompID` (Tag 49) authentication at logon, plus additional credential verification for private endpoints.

## Key Authentication Requirements

### SenderCompID Setup

Both public market data and private trading endpoints require a first layer of authentication with the usage of `SenderCompID` (Tag 49) at the logon and on all subsequent messages.

The platform distinguishes between Spot and Derivative sessions, with Derivatives receiving a `SenderCompID` containing a `DRV` suffix. Kraken support provides these identifiers during onboarding.

### API Key Configuration

Users should generate separate API keys for Spot and Futures trading through their Kraken Pro account settings. You will need to create a SPOT API Key with `FIX` type for both Spot and Futures.

## Authentication Implementation

The provided code demonstrates password generation for private logon:

```python
def get_password(d_msg):
    api_key = "YOUR API_KEY"
    api_secret = "YOUR API_SECRET"
    nonce = str(time.time() * 1000.).split('.')[0]
    message_input = "35=" + "A" + __SOH__ + "34=" + d_msg["34"] + __SOH__ + "49=" + d_msg["49"] + __SOH__ + "56=" + "KRAKEN-TRD" + __SOH__ + "553=" + api_key + __SOH__
    api_sha256 = hashlib.sha256((message_input + nonce).encode("utf-8")).digest()
    api_hmac = hmac.new(base64.b64decode(api_secret), api_sha256, hashlib.sha512)
    fix_password = base64.b64encode(api_hmac.digest())
    return fix_password
```

This implementation uses SHA256 hashing combined with HMAC-SHA512 signing to generate secure authentication passwords.
