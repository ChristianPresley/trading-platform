# Admin

Connection management and system events for WebSocket v1.

## Contents

1. [Heartbeat](01_Heartbeat.md) -- Server-originated keepalive event sent when no subscription traffic occurs within ~1 second.
   - Event: `heartbeat`
2. [Ping](02_Ping.md) -- Application-level ping/pong for verifying connection liveness.
   - Event: `ping` / `pong`
3. [Subscription Status](03_Subscription-Status.md) -- Response message confirming subscription, unsubscription, or exchange-initiated unsubscribe actions.
   - Event: `subscriptionStatus`
4. [System Status](04_System-Status.md) -- Server-initiated event reporting the current state of Kraken's trading engine.
   - Event: `systemStatus`
5. [Unsubscribe](05_Unsubscribe.md) -- Terminates subscriptions to WebSocket channels by pair or wildcard.
   - Event: `unsubscribe`
