# MetaCrafterToken

MetaCrafterToken is an ERC-20 token smart contract with additional functionalities for managing organizations, stakeholders, and whitelisting. It is implemented in Solidity and utilizes the OpenZeppelin library for ERC-20 functionality.

## Features

- **Organization Registration:** Allows organizations to register themselves by providing their address and the address of their associated token.

- **Stakeholder Management:** Enables organizations to add stakeholders with details such as the amount of tokens, vesting period, and stakeholder type (Founder, Investor, Other).

- **Whitelisting:** Organizations can whitelist addresses for certain stakeholders, allowing whitelisted addresses to claim their tokens after the vesting period.

## Contract Details

- **Contract Name:** MetaCrafterToken

- **Symbol:** MTN

- **Decimals:** 18

### Getting Started

## Clone the repository:

   git clone <repository_url>
   cd MetaCrafterToken


## Install Dependencies:

    npm install

## Compile the contract:

    npx hardhat compile

## Deploy the contract:

    npx hardhat run scripts/deploy.js --network mumbai

## Verify the contract:

    npx hardhat run scripts/verify.js --network mumbai


Running the contract with hardhat:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat compile
npx hardhat run scripts/deploy.js --network mumbai
npx hardhat run scripts/verify.js --network mumbai
```