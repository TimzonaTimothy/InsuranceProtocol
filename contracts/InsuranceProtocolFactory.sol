// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./InsuranceProtocolContract.sol";
import "./InsuranceCollateralContract.sol";

contract InsuranceProtocolFactory {
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
    constructor(address _loanToken, address _admin) {
        admin = _admin;
        loanToken = _loanToken;
    }

    // Function to create a new insurance pool
    function createInsurancePool(uint _premium) external {
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
        IERC20(loanToken).transfer(msg.sender, loanAmount);
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