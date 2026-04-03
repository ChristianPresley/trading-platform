# Earn

Endpoints for managing Kraken Earn strategies, including allocating and deallocating funds, checking operation status, and listing allocations and available strategies.

## Contents

1. [Allocate Strategy](01_Allocate-Strategy.md) — Allocate funds to an Earn strategy (asynchronous).
   - `POST /0/private/Earn/Allocate`
2. [Deallocate Strategy](02_Deallocate-Strategy.md) — Deallocate (remove) funds from an Earn strategy (asynchronous).
   - `POST /0/private/Earn/Deallocate`
3. [Get Allocate Strategy Status](03_Get-Allocate-Strategy-Status.md) — Poll for the result of an asynchronous allocation request.
   - `POST /0/private/Earn/AllocateStatus`
4. [Get Deallocate Strategy Status](04_Get-Deallocate-Strategy-Status.md) — Poll for the result of an asynchronous deallocation request.
   - `POST /0/private/Earn/DeallocateStatus`
5. [List Allocations](05_List-Allocations.md) — List all current Earn allocations with fund state and reward timing.
   - `POST /0/private/Earn/Allocations`
6. [List Strategies](06_List-Strategies.md) — List available Earn strategies and their parameters for the user's region.
   - `POST /0/private/Earn/Strategies`
