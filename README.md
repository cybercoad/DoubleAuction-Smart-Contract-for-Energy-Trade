# DoubleAuction-Smart-Contract-for-Energy-Trade

This repository contains the DoubleAuction smart contract, which implements a decentralized double auction mechanism on the Ethereum blockchain. It allows buyers and sellers to participate in auctions, match bids, and handle payments in a secure, transparent, and automated manner using Solidity.

## Table of Contents
* Overview
* Features
* Prerequisites
* Installation
* Usage
 * Smart Contract Deployment
 * Interacting with the Smart Contract
 * DApp Features
* Smart Contract Functions

### Overview
The DoubleAuction smart contract provides an auction marketplace where buyers and sellers can place bids. The contract matches bids based on predefined rules and facilitates payment transactions between parties.

This contract is part of a decentralized application (DApp) that has three roles:

1. Sellers: Place sell bids for goods or services.
2. Buyers: Place buy bids.
3. Market Operator: Executes the auction and finalizes transactions.
### Features
* Allows sellers to place sell bids and buyers to place buy bids.
* Executes double auctions based on matching bid logic.
* Manages auction history and user roles (seller, buyer, market operator).
* Secure transaction handling with Ethereum’s native cryptocurrency, Ether (ETH).

### Prerequisites
Before you start, ensure you have the following installed:
* Node.js (v16.x.x or above)
* Hardhat (for contract deployment)
* Metamask (for connecting to the Ethereum network)
* Web3.js (for interacting with the smart contract)
* Vite (for frontend development)

### Installation

1. Clone this repository:
'''
git clone https://github.com/YourUsername/DoubleAuction.git
cd DoubleAuction
'''
2. Install the required dependencies:
'''
npm install
...
3. Compile the smart contract using Hardhat:
...
npx hardhat compile
...
### Usage
**Smart Contract Deployment**
1. Deploy the smart contract to a local Hardhat network or a testnet (e.g., Ropsten):
'''
npx hardhat run scripts/deploy.js --network <network-name>
'''
2. After deployment, note down the contract address. Update the frontend code to interact with the contract at this address.
**Interacting with the Smart Contract**
You can interact with the deployed DoubleAuction contract using the DApp built with React and Web3.js.
* Sellers can submit sell bids by specifying the number of units and the price per unit.
* Buyers can submit buy bids similarly.
* Market Operator is responsible for executing the auction to match bids and transfer ETH from buyers to sellers.

**DApp Features**
The DApp provides a user-friendly interface for:
* Sellers to place bids and view past auctions.
* Buyers to place bids and transfer ETH to matched sellers.
* Market operators to execute the auction logic and handle settlements.
The DApp is built with React, Vite, and Web3.js, ensuring smooth interaction with the Ethereum network.

### Smart Contract Functions
Here are some key functions provided in the smart contract:

* 'placeSellBid(uint _amount, uint _price)': Allows a seller to place a bid.
* 'placeBuyBid(uint _amount, uint _price)': Allows a buyer to place a bid.
* 'executeAuction()': Executes the double auction by matching buy and sell bids.
* 'ransferFunds(address _seller, address _buyer, uint _amount)': Transfers ETH between buyer and seller after a successful match.

For more details, please refer to the DoubleAuction.sol smart contract in this repository.

