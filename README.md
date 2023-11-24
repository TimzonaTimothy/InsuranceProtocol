# INSURANCE AND COLATERAL PROTECTION CONTRACT

This Solidity program is a simple implementation of an "Insurance contract" and a "Colateral protection contract", it impliments the factory contract model to allow individuals create either an insurance contracts or a colateral protection contract for crypto backed loans.

## Description

This program is a simple contract written in Solidity, a programming language used for developing smart contracts on the Ethereum blockchain. The contract is a factory contract that deploys new instances of a child contract depending on the users choice. The factory is able to deploy an insurance contract or a Collateral contract. The insurance contract allows a user to pay his premium monthly or anually depending on the users choice while the Colateral management contract implements a logic that helps check if the value of a user's colateral has droped below 20, of which if it does then the users colatetal is liquidated, the user cal also repay back his loan to receive back his colateral.

## Factory Contract (POLYGON MUMBAI)
    https://mumbai.polygonscan.com/address/0xE82599Bb236C7BD9C219A5dC98297C7ad71Bba37#code


### Getting Started

## Clone the repository:

   git clone <repository_url>
  

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