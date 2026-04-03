# Spot Websockets (v1) Book Checksum

> Source: https://docs.kraken.com/api/docs/guides/spot-ws-book-v1

## Book Updates

Each book update message includes a CRC32 checksum calculated from the top 10 bids and asks. Checksums will not be sent in book snapshot messages, but rather only in book update messages.

### Example book update with asks, bids and checksum

```json
[
    0,
    {
        "a": [
            ["0.05120", "0.00000500", "1582905486.493008"],
            ["0.05275", "0.00000500", "1582905486.493034"]
        ]
    },
    {
        "b": [
            ["0.04765", "0.00000500", "1582905486.493008"],
            ["0.04940", "0.00000500", "1582905486.493034"]
        ],
        "c": "974947235"
    },
    "book-1000",
    "BTC/USD"
]
```

## Book Checksum Calculation

The checksum combines the top 10 bids and asks, then applies CRC32. Price and volume values must be formatted as strings without decimal points or leading zeros.

### Processing Steps

1. Apply the update to your local book
2. For each of the top 10 asks (sorted low to high):
   - Remove the decimal point: "0.05000" -> "005000"
   - Remove leading zeros: "005000" -> "5000"
   - Concatenate the formatted price and volume strings
3. Repeat for the top 10 bids (sorted high to low)
4. Calculate CRC32 of the concatenated string
5. Cast the result as an unsigned 32-bit integer

### Example Checksum Calculation

For the provided book state with 10 asks and 10 bids, the checksum input concatenates all formatted values without spaces or newlines, producing the result "974947235".
