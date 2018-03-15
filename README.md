# Listing checker for crypto exchanges

This is a quick and dirty ruby script to periodically (every 2 minutes right
now) check the API of popular exchanges to see if a new coin has been added.

It polls the exchanges every few minutes, reports how many pairings are listed
now vs. the last time it was polled, and if there are any present now that
weren't last time, alerts them as possible additions.

Note that Kucoin in particular seems to occasionally drop pairings for a minute
or two, so check the most recent pollings for false positives.

Current support:
- Bittrex
- Binance
- Kucoin
- Huobi
- Bitfinex

## Usage:

With ruby installed (no gems needed), clone the repo and run checker.rb.

Ctrl-C to close.
