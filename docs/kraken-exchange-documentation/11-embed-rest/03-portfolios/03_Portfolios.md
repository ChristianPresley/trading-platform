# Portfolios Overview

## Description

The Portfolios section of the Kraken Embed API provides endpoints for managing and viewing user portfolio information, including summaries, detailed asset holdings, transaction history, and historical balance data.

## Available Endpoints

### Get Portfolio Summary

Get the portfolio summary for a user.

### Get Portfolio History

Gets a portfolio's historical balances and valuations over time.

- See [Get Embed Portfolio History](get-embed-portfolio-history.md)

### List Portfolio Details

Lists owned assets in a user's portfolio.

- See [List Embed Portfolio Details](list-embed-portfolio-details.md)

### List Portfolio Transactions

Lists the user's trades and transactions.

## Authentication

All portfolio endpoints require authenticated API credentials.

## Notes

- Portfolio endpoints provide read-only access to user holdings and transaction data.
- Historical data may have processing delays (see individual endpoint documentation for details).
- For individual endpoint details including parameters, response fields, and error codes, see the linked endpoint documentation pages.

---

*Source: [Kraken API Documentation -- Portfolios](https://docs.kraken.com/api/docs/embed-api/portfolios)*
