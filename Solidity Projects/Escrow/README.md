# Escrow

When swapping for a token with low liquidity, it often leads to high slippage which moves the price drastically in either direction. This is an expected behaviour in DEXs which is undesirable (although its a small price to pay for decentralisation, there should be a reliable alternative for those who wish to trade via this method), as we are not able to buy / sell these tokens at its 'true price' - similar to an CEX.

This project experiments with the idea of creating a time-based contract that locks in both party's assets at the 'true price' agreed outside of this contract, and allows for a trustless (via smart contracts) swap (transferring tokens) without any slippage.

Inspired from an attempted swap with that resulted in a high slippage. P2P attempts are unreliable as its solely based on trust (high risk, including untrusted middleman) 🥲

An actual implementation of such feature by 1inch DEX - https://cointelegraph.com/news/1inch-network-adds-a-p2p-feature-to-facilitate-secure-crypto-swaps/amp
