# DoubleAuction-Smart-Contract-for-Energy-Trade

This repository contains the DoubleAuction smart contract, which implements a decentralized double auction mechanism on the Ethereum blockchain. It allows buyers and sellers to participate in auctions, match bids, and handle payments in a secure, transparent, and automated manner using Solidity.

Table of Contents
Overview
Features
Prerequisites
Installation
Usage
Smart Contract Deployment
Interacting with the Smart Contract
DApp Features
Smart Contract Functions
License
Overview
The DoubleAuction smart contract provides an auction marketplace where buyers and sellers can place bids. The contract matches bids based on predefined rules and facilitates payment transactions between parties.

This contract is part of a decentralized application (DApp) that has three roles:

Sellers: Place sell bids for goods or services.
Buyers: Place buy bids.
Market Operator: Executes the auction and finalizes transactions.
Features
Allows sellers to place sell bids and buyers to place buy bids.
Executes double auctions based on matching bid logic.
Manages auction history and user roles (seller, buyer, market operator).
Secure transaction handling with Ethereum’s native cryptocurrency, Ether (ETH).
Prerequisites
Before you start, ensure you have the following installed:

Node.js (v16.x.x or above)
Hardhat (for contract deployment)
Metamask (for connecting to the Ethereum network)
Web3.js (for interacting with the smart contract)
Vite (for frontend development)
