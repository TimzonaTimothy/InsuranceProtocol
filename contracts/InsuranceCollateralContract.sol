// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Collateral protection for crypto backed loans
 * @author Marcellus Ifeanyi
 * @notice
 */

contract ColateralProtocol {
     // State variables
     using SafeMath for uint;
    address public owner;                   // Owner of the collateral
    address public factory;                 // Factory contract address
    address public loanToken;               // ERC20 token used for the loan
    uint256 public collateralAmount;        // Amount of collateral in Ether
    uint256 public loanAmount;              // Amount of the loan in loanToken
    uint256 public lastCollateralCheckTimestamp; // Timestamp of the last collateral check
    bool public loanLiquidated;             // Flag indicating if the loan has been liquidated
    bool public loanRepaid;                 // Flag indicating if the loan has been repaid

    // Events
    event CollateralCheck(
        address indexed owner,
        uint256 currentCollateralValue
    );

    // Custom errors
    string constant ERR_ONLY_OWNER = "Only owner allowed";

    /**
     * @dev Constructor initializes the contract with collateral and loan details.
     * @param _collateralAmount Amount of collateral in Ether.
     * @param _loanAmount Amount of the loan in loanToken.
     * @param _client Address of the owner/client.
     * @param _factory Address of the factory contract.
     * @param _loanToken Address of the ERC20 token used for the loan.
     */
    constructor(
        uint256 _collateralAmount,
        uint256 _loanAmount,
        address _client,
        address _factory,
        address _loanToken
    ) {
        owner = _client;
        collateralAmount = _collateralAmount;
        loanAmount = _loanAmount;
        lastCollateralCheckTimestamp = block.timestamp;
        factory = _factory;
        loanToken = _loanToken;
    }

    /**
     * @dev Modifier to ensure that only the owner can call a function.
     */
    modifier onlyOwner() {
        if (msg.sender != owner) revert (ERR_ONLY_OWNER);
        _;
    }

    /**
     * @dev Function to check the current collateral value.
     * The collateral value can be checked at most once per month.
     */
    function checkCollateralValue() external onlyOwner {
        require(
            block.timestamp >= lastCollateralCheckTimestamp + 1 days,
            "CollateralValueCanBeCheckedOncePerMonth"
        );

        // Liquidate if the collateral value drops by 20% or more
        bool liquidate = isPriceDropGreaterThan20Percent(getEthPrice());
        if (liquidate) {
            loanLiquidated = true;
        }

        // Update the timestamp of the last collateral check
        lastCollateralCheckTimestamp = block.timestamp;

        // Emit an event to record the collateral check
        emit CollateralCheck(owner, getEthPrice());
    }

    /**
     * @dev Function to get the loan amount.
     * @return The amount of the loan in loanToken.
     */
    function getLoanAmount() external view returns (uint256) {
        return loanAmount;
    }

    /**
     * @dev Function to repay the loan.
     * @param _repaymentAmount The amount to repay.
     */
    function repayLoan(uint256 _repaymentAmount) external {
        require(loanAmount <= _repaymentAmount, "ExcessPaymentAmount");
        require(!loanLiquidated, "LoanAlreadyLiquidated");

        // Transfer the repayment amount to the factory
        IERC20(loanToken).transferFrom(msg.sender, factory, _repaymentAmount);

        // Update the remaining loan amount
        loanAmount -= _repaymentAmount;

        // If the loan is fully repaid, transfer the collateral back to the owner
        if (loanAmount == 0) {
            loanRepaid = true;
            payable(owner).transfer(collateralAmount);
        }
    }

    /**
     * @dev Function to receive Ether payments.
     */
    receive() external payable {}
    
    /**
     * @dev Function to get the current Ether price.
     * @return The current Ether price (for demonstration purposes, a fixed value is returned).
     */
    function getEthPrice() internal pure returns (uint256) {
        // In a real application, an oracle implementation should be used to fetch the current Ether price.
        return 1500;
    }

    /**
     * @dev Function to check if the price has dropped by 20% or more.
     * @param currentPrice The current collateral value.
     * @return True if the price drop is greater than or equal to 20%, false otherwise.
     */
    function isPriceDropGreaterThan20Percent(uint256 currentPrice) public view returns (bool) {
        uint256 initialCollateralPrice = (loanAmount * 1500) / (1000 * 10 ** 18);
        uint256 priceDropPercentage = ((initialCollateralPrice - currentPrice) * 100) / initialCollateralPrice;
        return priceDropPercentage >= 20;
    }
}