## SWIFT Messaging

**SWIFT** (Society for Worldwide Interbank Financial Telecommunication) provides the messaging infrastructure for post-trade, settlement, and payment processes.

### MT Messages (Legacy)

MT (Message Type) messages use a structured text format with defined field tags:

| Category | Range | Purpose | Key Messages |
|----------|-------|---------|--------------|
| Customer Payments | MT1xx | Payment instructions | MT103 (Single Customer Transfer), MT101 (Request for Transfer) |
| Financial Institution Transfers | MT2xx | Bank-to-bank payments | MT202 (General Financial Institution Transfer), MT210 (Notice to Receive) |
| Treasury | MT3xx | FX and derivatives | MT300 (FX Confirmation), MT320 (Fixed Loan/Deposit), MT360 (Interest Rate Derivative) |
| Collections & Cash Letters | MT4xx | Documentary credits | MT400 (Advice of Payment) |
| Securities | MT5xx | Securities trading and settlement | MT515 (Client Confirmation), MT535 (Statement of Holdings), MT540-543 (Settlement Instructions), MT548 (Settlement Status) |
| Precious Metals | MT6xx | Commodity trades | MT600 (Precious Metal Confirmation) |
| Documentary Credits | MT7xx | Trade finance | MT700 (Issue of Documentary Credit) |
| Statements | MT9xx | Account statements | MT940 (Customer Statement), MT950 (Statement Message) |

### MX Messages (ISO 20022)

MX messages use XML-based ISO 20022 standards. SWIFT's **migration to ISO 20022** is the industry's most significant messaging transition:

| Category | ISO 20022 Domain | Key Messages |
|----------|-------------------|--------------|
| Payments | `pacs`, `pain`, `camt` | `pacs.008` (Customer Credit Transfer), `pacs.009` (Financial Institution Credit Transfer), `camt.053` (Bank-to-Customer Statement) |
| Securities | `sese`, `semt`, `seev` | `sese.023` (Securities Settlement Instruction), `semt.002` (Statement of Holdings), `seev.031` (Corporate Action Notification) |
| Trade Finance | `tsmt`, `tsin` | Various trade finance messages |
| FX | `fxtr` | `fxtr.014` (FX Trade Instruction) |

### ISO 20022 Migration Timeline

- **March 2023**: SWIFT began coexistence period for cross-border payments (MT/MX)
- **November 2025**: Target end of coexistence for payments; full ISO 20022 adoption
- **2024-2025**: Securities messaging migration phases (T2S in Europe already on ISO 20022)
- **Ongoing**: National market infrastructures migrating (Fed, CHAPS, TARGET2 already complete)

### SWIFT Infrastructure

- **SWIFTNet**: Secure IP-based messaging network
- **Alliance Lite2**: Cloud-based SWIFT connectivity for smaller institutions
- **Alliance Access/Gateway**: On-premise SWIFT interface
- **SWIFT gpi** (Global Payments Innovation): End-to-end payment tracking with UETR (Unique End-to-End Transaction Reference)

### Relevance to Trading

For a trading platform, SWIFT connectivity is relevant for:

- **Settlement instructions**: MT540-543 (Receive/Deliver Free/Against Payment) for securities settlement
- **Confirmation matching**: MT515/518 for client confirmation of trades
- **Cash management**: MT940/950 for account statement reconciliation
- **Corporate actions**: MT564/568 for corporate action notifications and instructions
- **Position reconciliation**: MT535 for statement of holdings
