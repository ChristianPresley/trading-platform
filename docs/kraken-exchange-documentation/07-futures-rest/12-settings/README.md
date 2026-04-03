# Settings

Account configuration endpoints -- self-trade strategy, subaccount management, and trading capability controls.

## Contents

1. [Get Self Trade Strategy](01_Get-Self-Trade-Strategy.md) -- Retrieve the account-wide self-trade matching strategy configuration.
   - `GET /self-trade-strategy`
2. [Get Subaccount Trading Capability](02_Get-Subaccount-Trading-Capability.md) -- Return whether trading is enabled or disabled for a given subaccount.
   - `GET /subaccount/:subaccountUid/trading-enabled`
3. [List Subaccounts](03_List-Subaccounts.md) -- Return all subaccounts with balances and UIDs under the master account.
   - `GET /subaccounts`
4. [Set Self Trade Strategy](04_Set-Self-Trade-Strategy.md) -- Update the account-wide self-trade matching strategy (cancelNewest, cancelOldest, cancelBoth).
   - `PUT /self-trade-strategy`
5. [Update Subaccount Trading Capability](05_Update-Subaccount-Trading-Capability.md) -- Enable or disable trading for a given subaccount.
   - `PUT /subaccount/:subaccountUid/trading-enabled`
