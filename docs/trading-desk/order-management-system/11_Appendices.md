## Appendix A: Common FIX Tag Reference

| Tag | Name | Description |
|-----|------|-------------|
| 1 | Account | Trading account |
| 6 | AvgPx | Average fill price |
| 11 | ClOrdID | Client order ID |
| 14 | CumQty | Cumulative filled quantity |
| 15 | Currency | Order currency |
| 17 | ExecID | Execution report ID |
| 18 | ExecInst | Execution instructions |
| 21 | HandlInst | Handling instructions |
| 22 | SecurityIDSource | Security ID type |
| 30 | LastMkt | Last execution venue |
| 31 | LastPx | Last fill price |
| 32 | LastQty | Last fill quantity |
| 34 | MsgSeqNum | Message sequence number |
| 37 | OrderID | Venue-assigned order ID |
| 38 | OrderQty | Order quantity |
| 39 | OrdStatus | Order status |
| 40 | OrdType | Order type |
| 41 | OrigClOrdID | Original client order ID |
| 43 | PossDupFlag | Possible duplicate flag |
| 44 | Price | Limit price |
| 48 | SecurityID | Security identifier |
| 49 | SenderCompID | Sender firm ID |
| 50 | SenderSubID | Sender sub-ID (trader) |
| 52 | SendingTime | Message timestamp |
| 54 | Side | Order side |
| 55 | Symbol | Instrument symbol |
| 56 | TargetCompID | Target firm ID |
| 58 | Text | Free-form text |
| 59 | TimeInForce | Time in force |
| 60 | TransactTime | Transaction timestamp |
| 66 | ListID | List order ID |
| 70 | AllocID | Allocation ID |
| 75 | TradeDate | Trade date |
| 76 | ExecBroker | Executing broker |
| 78 | NoAllocs | Number of allocations |
| 79 | AllocAccount | Allocation account |
| 80 | AllocQty | Allocation quantity |
| 97 | PossResend | Possible resend flag |
| 99 | StopPx | Stop trigger price |
| 100 | ExDestination | Target venue |
| 102 | CxlRejReason | Cancel reject reason |
| 103 | OrdRejReason | Order reject reason |
| 108 | HeartBtInt | Heartbeat interval |
| 110 | MinQty | Minimum fill quantity |
| 111 | MaxFloor | Display quantity (iceberg) |
| 126 | ExpireTime | Order expiration time |
| 141 | ResetSeqNumFlag | Reset sequence numbers |
| 150 | ExecType | Execution report type |
| 151 | LeavesQty | Remaining quantity |
| 167 | SecurityType | Security type |
| 200 | MaturityMonthYear | Derivatives expiry |
| 201 | PutOrCall | Put or call |
| 202 | StrikePrice | Option strike price |
| 207 | SecurityExchange | Primary exchange |
| 211 | PegOffsetValue | Peg offset |
| 231 | ContractMultiplier | Contract multiplier |
| 378 | ExecRestatementReason | Unsolicited state change reason |
| 432 | ExpireDate | Order expiration date |
| 434 | CxlRejResponseTo | Cancel or cancel/replace |
| 447 | PartyIDSource | Party ID source |
| 448 | PartyID | Party identifier |
| 452 | PartyRole | Party role |
| 453 | NoPartyIDs | Number of parties |
| 461 | CFICode | ISO 10962 instrument class |
| 527 | SecondaryExecID | Secondary execution ID |
| 553 | Username | Session username |
| 554 | Password | Session password |
| 583 | ClOrdLinkID | Linked order group ID |
| 626 | AllocType | Allocation type |
| 797 | CopyMsgIndicator | Drop copy flag |
| 836 | PegOffsetType | Peg offset type |
| 847 | TargetStrategy | Algo strategy |
| 848 | TargetStrategyParameters | Algo parameters |
| 851 | LastLiquidityInd | Liquidity add/remove |
| 957 | NoStrategyParameters | Number of algo params |
| 958 | StrategyParameterName | Algo param name |
| 959 | StrategyParameterType | Algo param type |
| 960 | StrategyParameterValue | Algo param value |
| 1084 | DisplayMethod | Display method |
| 1094 | PegPriceType | Peg price type |
| 1133 | ExDestinationIDSource | Venue ID source |
| 1385 | ContingencyType | Contingency type |

---

## Appendix B: OrdRejReason Values (Tag 103)

| Value | Meaning |
|-------|---------|
| 0 | Broker/exchange option |
| 1 | Unknown symbol |
| 2 | Exchange closed |
| 3 | Order exceeds limit |
| 4 | Too late to enter |
| 5 | Unknown order |
| 6 | Duplicate order |
| 7 | Duplicate of a verbally communicated order |
| 8 | Stale order |
| 9 | Trade along required |
| 10 | Invalid investor ID |
| 11 | Unsupported order characteristic |
| 13 | Incorrect quantity |
| 14 | Incorrect allocated quantity |
| 15 | Unknown account(s) |
| 18 | Invalid price increment |
| 99 | Other |

---

## Appendix C: ExecRestatementReason Values (Tag 378)

| Value | Meaning |
|-------|---------|
| 0 | GT corporate action |
| 1 | GT renewal/restatement |
| 2 | Verbal change |
| 3 | Repricing of order |
| 4 | Broker option |
| 5 | Partial decline of OrderQty |
| 6 | Cancel on Trading Halt |
| 7 | Cancel on System Failure |
| 8 | Market (Exchange) Option |
| 9 | Cancelled, not best |
| 10 | Warehouse recap |
| 11 | Peg refresh |
| 99 | Other |
