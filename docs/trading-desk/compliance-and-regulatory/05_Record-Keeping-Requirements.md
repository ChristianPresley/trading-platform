## 5. Record Keeping Requirements

### 5.1 Order and Trade Records

Regulatory record-keeping obligations require firms to capture and retain extensive data about every stage of the order lifecycle.

**MiFID II / RTS 25 requirements:**

- All orders received from clients, including the date and time of receipt (to the granularity of the business clock requirement, at least one millisecond for electronic orders).
- All decisions to deal, including the algorithm identifier and parameters used.
- All orders submitted to venues, including venue identification, order type, limit price, quantity, and any special conditions (e.g., IOC, FOK, iceberg parameters).
- All order modifications, cancellations, expirations, and executions, with timestamps.
- For algorithmic trading, the system must log all parameters of each algorithm instance, including parent-child order relationships.

**SEC and FINRA requirements:**

- SEC Rule 17a-3 and 17a-4 define record creation and retention requirements for broker-dealers.
- Records must include: blotters (purchase/sale, receipt/delivery, cash), customer account records, order tickets (memoranda of orders), confirmations, trial balances, and securities records.
- FINRA Rule 4511 requires members to make and preserve books and records as required under applicable rules.
- Records of customer complaints and their resolution.

**Timestamps and clock synchronization:**

- MiFID II RTS 25: Business clocks must be synchronized to UTC, with granularity depending on the activity: 1 microsecond for high-frequency trading, 1 millisecond for other electronic trading, 1 second for non-electronic methods.
- FINRA/CAT: Clocks must be synchronized within 50 milliseconds of NIST for manual events and within the tolerances specified in the CAT NMS Plan for electronic events.

### 5.2 Communication Records

Firms must record and retain communications related to trading activity.

**Voice recording:**

- MiFID II Article 16(7): Firms must record telephone conversations and electronic communications relating to transactions concluded when dealing on own account and the provision of client order services that relate to the reception, transmission, and execution of client orders.
- Recordings must cover both firm-provided and personal devices if the firm has permitted use of personal devices for business communications.
- Recordings must be provided to clients on request.

**Electronic communications:**

- All electronic communications (email, chat, instant messaging) that relate to order reception, transmission, and execution must be recorded.
- Bloomberg chat (IB), Refinitiv Eikon Messenger, Symphony, ICE Chat, Microsoft Teams, and similar platforms must be archived.
- Under FINRA Rule 3110 and SEC Rule 17a-4, broker-dealers must retain electronic communications in a manner that allows for prompt retrieval and review.
- WhatsApp, WeChat, and other off-channel communication use has been the subject of significant SEC/FINRA enforcement actions and fines (over $2 billion in aggregate industry fines 2021-2024), making off-channel communication monitoring a critical area.

### 5.3 Retention Periods

| Jurisdiction / Regulation | Record Type | Minimum Retention |
|---------------------------|-------------|-------------------|
| MiFID II (Article 16) | Transaction records | 5 years |
| MiFID II (Article 16) | Voice / electronic communications | 5 years (may be extended to 7 by NCA) |
| SEC Rule 17a-4 | Blotters, ledgers, customer records | 6 years (first 2 years readily accessible) |
| SEC Rule 17a-4 | Order tickets, confirmations | 3 years (first 2 years readily accessible) |
| SEC Rule 17a-4 | Communications | 3 years |
| CFTC Rule 1.31 | All required records | 5 years (first 2 years readily accessible) |
| FCA (UK) | MiFID records | 5 years (communication records may be 3-5 years) |
| EMIR | Derivative trade reports | 5 years after termination of contract |
| SFTR | SFT data | 10 years following termination of the SFT |

**Storage requirements:**

- Records must be stored in non-rewritable, non-erasable format (WORM — Write Once Read Many) under SEC Rule 17a-4(f).
- Records must be readily accessible and searchable.
- Firms must maintain backup and disaster recovery capabilities.
- Cloud storage is permitted under SEC guidance, provided the cloud provider meets WORM and accessibility requirements and the firm retains ultimate control.
