# Admin

Connection management and system events for WebSocket v2.

## Contents

1. [Heartbeat](01_Heartbeat.md) -- Connection verification messages sent approximately every second when no other updates are flowing.
   - Channel: `heartbeat`
2. [Ping](02_Ping.md) -- Application-level ping/pong for verifying an active connection.
   - Method: `ping` / `pong`
3. [Status](03_Status.md) -- Automatic exchange status updates sent on connection and when the trading engine status changes.
   - Channel: `status`
