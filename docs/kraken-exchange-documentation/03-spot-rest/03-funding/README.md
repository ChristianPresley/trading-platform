# Funding

Endpoints for deposits, withdrawals, and wallet transfers on the Kraken spot exchange.

## Contents

1. [Cancel Withdrawal](01_Cancel-Withdrawal.md) — Cancel a recently requested withdrawal if not yet processed.
   - `POST /0/private/WithdrawCancel`
2. [Get Deposit Addresses](02_Get-Deposit-Addresses.md) — Retrieve or generate deposit addresses for a particular asset and method.
   - `POST /0/private/DepositAddresses`
3. [Get Deposit Methods](03_Get-Deposit-Methods.md) — Retrieve available methods for depositing a particular asset.
   - `POST /0/private/DepositMethods`
4. [Get Status Recent Deposits](04_Get-Status-Recent-Deposits.md) — Retrieve information about recent deposits, sorted by recency.
   - `POST /0/private/DepositStatus`
5. [Get Status Recent Withdrawals](05_Get-Status-Recent-Withdrawals.md) — Retrieve information about recent withdrawals, sorted by recency.
   - `POST /0/private/WithdrawStatus`
6. [Get Withdrawal Addresses](06_Get-Withdrawal-Addresses.md) — Retrieve a list of withdrawal addresses available for the user.
   - `POST /0/private/WithdrawAddresses`
7. [Get Withdrawal Information](07_Get-Withdrawal-Information.md) — Retrieve fee information about potential withdrawals for a given asset, key, and amount.
   - `POST /0/private/WithdrawInfo`
8. [Get Withdrawal Methods](08_Get-Withdrawal-Methods.md) — Retrieve a list of withdrawal methods available for the user.
   - `POST /0/private/WithdrawMethods`
9. [Wallet Transfer](09_Wallet-Transfer.md) — Transfer funds from a Kraken spot wallet to a Kraken Futures wallet.
   - `POST /0/private/WalletTransfer`
10. [Withdraw Funds](10_Withdraw-Funds.md) — Make a withdrawal request.
    - `POST /0/private/Withdraw`
