# Portfolios

Custody REST API endpoints for managing vaults, balances, and deposit operations.

## Contents

1. [Deposit Addresses](01_Deposit-Addresses.md) — Retrieve or generate deposit addresses for a specific asset and funding method.
   - `POST /0/private/DepositAddresses`
2. [Deposit Methods](02_Deposit-Methods.md) — Retrieve available deposit funding methods for a specific asset.
   - `POST /0/private/DepositMethods`
3. [Get Custody Balance](03_Get-Custody-Balance.md) — Retrieve the balance for each asset held in a specified vault.
   - `POST /0/private/GetCustodyBalance`
4. [Get Custody Vault](04_Get-Custody-Vault.md) — Retrieve information and balances for a specific vault.
   - `POST /0/private/GetCustodyVault`
5. [List Custody Vaults](05_List-Custody-Vaults.md) — Retrieve all vaults within the custody domain.
   - `POST /0/private/ListCustodyVaults`
6. [Portfolios](06_Portfolios.md) — Overview of all portfolio endpoints and related sections.
