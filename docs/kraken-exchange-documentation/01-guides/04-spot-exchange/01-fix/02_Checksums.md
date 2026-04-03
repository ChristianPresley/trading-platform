# FIX Checksums

> Source: https://docs.kraken.com/api/docs/guides/fix-checksums

## Book Maintenance

All book updates are sent using Market Data Incremental Refresh. All updates in a message should be processed before the book is considered updated and the checksum confirmed. Update messages may contain updates to either the bids and/or asks. Additionally, each market data update entry is set with an update action, that could be New, Update and Delete to easily understand what changed in the book:

- **New** - A new entry level was added to the book
- **Update** - The volume of an entry level was updated
- **Delete** - The entry level was deleted from the book

Each book update message will have a checksum value appended. The checksum is a CRC32 value based on the top 10 bids and 10 asks, and you can use it to verify that your data is correct and up to date by calculating the checksum independently and comparing it against the value provided.

Prices and volumes are sent as floats and so their precision needs to be determined from an InstrumentListRequest call in order to compute the checksum. Detailed instructions can be found in the Calculate Book Checksum section.

## Calculate Book Checksum

The following example was made for BTC/USD book. The following steps should be done before doing any checksum calculations:

### Get the precision needed for the calculation

1. Request the InstrumentListRequest for BTC/USD book:

```
8=FIX.4.4|9=90|35=x|34=3|49=CLIENT|52=20231012-09:54:15.316|56=KRAKEN-MD|55=BTC/USD|320=SLS1000002|559=0|10=026|
```

2. Wait for the InstrumentListRequest answer. When it arrives it should look like this:

```
8=FIX.4.4|9=177|35=y|49=KRAKEN-MD|56=CLIENT|34=3|52=20231012-09:54:15.317|320=SLS1000002|322=1697104455317568799|560=0|146=1|55=BTC/USD|562=0.00000001|5010=8|5011=0.0001|2349=1|5022=0.1|5032=1|10=068|
```

**Note:** The important fields for the book checksum calculation are:

- `2349=1` -> Price precision is 1
- `5010=8` -> Quantity precision is 8

Price precision is 1 and quantity precision is 8; store these values somewhere because it will be needed to assist the checksum calculation on all future Market Data Incremental Refresh messages. It's not necessary to do any additional InstrumentListRequest to calculate the book checksum of this MarketData BTC/USD subscription.

### Calculate the first Checksum

1. Subscribe to Market Data of BTC/USD book:

```
8=FIX.4.4|9=124|35=V|34=6|49=CLIENT|52=20231012-09:54:15.316|56=KRAKEN-MD|146=1|55=BTC/USD|262=0|263=1|264=10|265=1|267=3|269=1|269=0|269=2|10=170|
```

2. Wait for the MarketDataFullRefresh message. When it arrives it should look like this:

```
8=FIX.4.4|9=1253|35=W|34=7|49=KRAKEN-MD|52=20231012-09:54:15.619|56=CLIENT|55=BTC/USD|262=0|268=20|269=1|278=O28013.0|270=28013.0|271=0.001|273=09:51:55.123|269=1|278=O28039.8|270=28039.8|271=0.001|273=09:51:55.247|269=1|278=O28066.5|270=28066.5|271=0.001|273=09:51:55.372|269=1|278=O28093.3|270=28093.3|271=0.001|273=09:51:55.496|269=1|278=O28120.0|270=28120.0|271=0.001|273=09:51:55.620|269=1|278=O28146.7|270=28146.7|271=0.001|273=09:51:55.749|269=1|278=O28173.5|270=28173.5|271=0.001|273=09:51:55.873|269=1|278=O28200.2|270=28200.2|271=0.001|273=09:51:55.998|269=1|278=O28227.0|270=28227.0|271=0.001|273=09:51:56.122|269=1|278=O28253.7|270=28253.7|271=0.001|273=09:51:56.248|269=0|278=B28003.0|270=28003.0|271=0.001|273=09:30:15.313|269=0|278=B27999.9|270=27999.9|271=0.00096375|273=19:02:00.714|269=0|278=B27969.9|270=27969.9|271=0.73860423|273=16:56:16.031|269=0|278=B27700.1|270=27700.1|271=0.0035|273=11:46:55.350|269=0|278=B27573.2|270=27573.2|271=0.0032|273=11:28:53.231|269=0|278=B27137.4|270=27137.4|271=0.01|273=13:14:38.670|269=0|278=B27091.3|270=27091.3|271=0.004|273=14:53:12.265|269=0|278=B26729.4|270=26729.4|271=0.001|273=09:51:29.477|269=0|278=B26702.6|270=26702.6|271=0.001|273=09:51:29.602|269=0|278=B26675.9|270=26675.9|271=0.001|273=09:51:29.729|10=214|
```

Now on each MarketDataIncrementalRefresh is possible to do the checksum calculation. The checksum is a CRC32 value based on the top 10 bids and 10 asks. It can be used to verify that your data is correct and up to date by calculating the checksum independently and comparing it against the value provided. The checksum is computed by concatenating the top 10 bids and asks in the current book in a particular format and then taking the CRC32 checksum of that string.

The following results are based on the previous example BTC/USD book.

1. Wait for the MarketDataIncrementalRefresh. When it arrives, should be like:

```
8=FIX.4.4|9=167|35=X|34=12|49=KRAKEN-MD|52=20231012-09:55:14.934|56=CLIENT|55=BTC/USD|262=0|268=1|279=1|269=1|278=O28013.0|270=28013.0|271=0.00096506|273=09:55:15.071|5041=3341325816|10=090|
```

2. Apply the MarketDataIncrementalRefresh updates on the book.

3. Sort the asks by price from low to high: 28013.0, 28039.8, ..., 28253.7

4. For each of the top ten asks:

   a. Convert the price-quantity pair to a string by:

   b. Change price using the price precision (1) to a string: 28013.0 -> "28013.0". NOTE: In this case the precision was already set as 1, but doesn't mean all future cases will be like this.

   c. Remove the decimal point (.) from the price: "28013.0" -> "280130"

   d. Remove all leading zero (0) characters from the price: "280130" -> "280130". NOTE: In this case we don't have any, but for instance if the string was "0280130", the outcome of this step is "280130".

   e. Change quantity using the quantity precision (8) to a string 0.00096506 -> "0.00096506". NOTE: In this case the quantity precision was already set as 8, but doesn't mean all future cases will be like this.

   f. Remove the decimal point (.) from the quantity: "0.00096506" -> "000096506"

   g. Remove all leading zero (0) characters from the quantity: "000096506" -> "96506"

   h. Combine converted price ("280130") and quantity ("96506"): "28013096506"

   Combine the converted top 10 asks price-quantity strings: "28013096506280398100000280665100000280933100000281200100000281467100000281735100000282002100000282270100000282537100000"

5. Sort the bids by price from high to low: 28003.0, 27999.9, ..., 26675.9

6. For each of the top ten bids:

   a. Convert the price-quantity pair to a string by:

   b. Change price using the price precision (1) to a string: 28003.0 -> "28003.0"

   c. Remove the decimal point (.) from the price: "28003.0" -> "280030"

   d. Remove all leading zero (0) characters from the price: "280030" -> "280030"

   e. Change quantity using the quantity precision (8) to a string 0.001 -> "0.00100000"

   f. Remove the decimal point (.) from the quantity: "0.00100000" -> "000100000"

   g. Remove all leading zero (0) characters from the quantity: "000100000" -> "100000"

   h. Combine converted price ("280030") and quantity ("100000"): "280030100000"

7. Combine the converted top 10 bids price-quantity strings: "28003010000027999996375279699738604232770013500002757323200002713741000000270913400000267294100000267026100000266759100000"

8. Combine the asks and bids results:

```
2801309650628039810000028066510000028093310000028120010000028146710000028173510000028200210000028227010000028253710000028003010000027999996375279699738604232770013500002757323200002713741000000270913400000267294100000267026100000266759100000
```

9. Use the combined asks-and-bids value as input to a CRC32 checksum function

10. Feed the concatenated string to a CRC32 checksum function. In this example the outcome is 3341325816

11. Every MarketDataIncrementalRefresh message has a checksum element (tag 5041); in this example it was: `5041=3341325816`. We just need now to confirm both values match: the one calculated against the one present in the MarketDataIncrementalRefresh message.

**Note:** If needed, cast the result (comprising 32 bits) as an unsigned 32-bit integer.
