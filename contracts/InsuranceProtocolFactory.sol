// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./InsuranceProtocolContract.sol";
import "./InsuranceCollateralContract.sol";

contract InsuranceProtocolFactory is ERC20, Ownable {
    using SafeMath for uint;
        // State variables
    mapping(address => InsuranceProtocol) public insurancePools;
    mapping(address => ColateralProtocol) public collateralPools;
    address public loanToken;
    address public admin;
    

    address[] public insurancePoolAddresses;
    address[] public collateralPoolAddresses;

    // Modifier to check if the provided pool address is valid
    modifier isValidPool(InsuranceProtocol pool) {
        require(address(pool) != address(0), "Invalid pool address");
        _;
    }

    // Custom error
    string constant ERR_ONLY_ADMIN = "Only admin allowed";

    // Constructor to set the admin and loan token address
    constructor()
    ERC20("MetaToken", "MTN"){
        admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        loanToken = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        transferOwnership(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        _mint(msg.sender, 100000 * 10 ** 18);
    }

   

    // Function to create a new insurance pool
    function createInsurancePool(uint _premium) external payable {
        InsuranceProtocol newPool = new InsuranceProtocol(_premium, msg.sender);
        insurancePools[msg.sender] = newPool;
        insurancePoolAddresses.push(address(newPool));
    }

    // Function to create a new collateral pool
    function createCollateralPool() external payable {
        // Calculate the Ether value based on the provided value and current Ether price

        uint ethValue = (msg.value * getEthPrice()) / 10 ** 18;
   
        // Calculate the loan amount based on the collateral value
        uint loanAmount = (ethValue * (1000 * 10 ** 18)) / 1500;

        // Create a new collateral pool
        ColateralProtocol newPool = new ColateralProtocol(
            msg.value,
            loanAmount,
            msg.sender,
            address(this),
            loanToken
        );

        // Store the collateral pool and its address
        collateralPools[msg.sender] = newPool;
        collateralPoolAddresses.push(address(newPool));

        // Transfer the loan amount in tokens to the pool creator
        _transfer(owner(),msg.sender, loanAmount);
        // Transfer the provided Ether value to the collateral pool
        payable(address(newPool)).transfer(msg.value);
        
    }

    // Function to get the list of insurance pool addresses
    function getInsurancePools() external view returns (address[] memory) {
        return insurancePoolAddresses;
    }

    // Function to get the list of collateral pool addresses
    function getCollateralPools() external view returns (address[] memory) {
        return collateralPoolAddresses;
    }

    // Function to get the current Ether price
    function getEthPrice() internal pure returns (uint) {
        // In a real application, an oracle implementation should be used to fetch the current Ether price.
        return 1500;
    }

    // Function to ensure that only the admin can call certain functions
    modifier onlyAdmin() {
        if (msg.sender != admin) revert (ERR_ONLY_ADMIN);
        _;
    }
}