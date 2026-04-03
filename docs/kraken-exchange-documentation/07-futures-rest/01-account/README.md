# Account

Futures account endpoints -- wallet balances, open positions, portfolio margining, and simulation.

## Contents

1. [Get Wallets (Accounts)](01_Get-Accounts.md) -- Return balances, margin requirements, PnL, and portfolio value for all cash and margin accounts.
   - `GET /derivatives/api/v3/accounts`
2. [Get Open Positions](02_Get-Open-Positions.md) -- Return the size and average entry price of all open futures positions.
   - `GET /derivatives/api/v3/openpositions`
3. [Get Portfolio Margin Parameters](03_Get-Portfolio-Margining-Parameters.md) -- Retrieve current portfolio margin calculation parameters and options trading limits (DEMO only).
   - `GET /derivatives/api/v3/portfolio-margining/parameters`
4. [Get Unwind Queue](04_Get-Unwind-Queue.md) -- Return the percentile of an open position in the unwind queue.
   - `GET /derivatives/api/v3/unwindqueue`
5. [Simulate Portfolio](05_Simulate-Portfolio.md) -- Calculate portfolio margin requirements, PnL, and option Greeks for a given set of positions (DEMO only).
   - `POST /derivatives/api/v3/portfolio-margining/simulate`
