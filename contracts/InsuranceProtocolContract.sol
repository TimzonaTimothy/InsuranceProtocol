// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract InsuranceProtocol {
    using SafeMath for uint;
   uint public premiumPrice; // Monthly insurance premium price
    address public client;    // Address of the wallet owner

    // Structure to store client information
    struct Client {
        uint validEnd;     // Timestamp of the end of the current insurance period
        uint lastClaimed;  // Timestamp of the last insurance claim
    }

    // Mapping to store client details based on their address
    mapping(address => Client) public clients;

    // Custom errors
    string constant ERR_ACTIVE_PREMIUM_AVAILABLE = "Active premium already available";
    string constant ERR_Insufficient_Amount = "Insufficient_Amount";
    string constant ERR_LastClaimed = "Last Claim Happened This Year";
    string constant ERR_AmountExceeds = "Amount Exceeds 2Years Premium";
    string constant ERR_InsufficientFunds = "Insufficient Funds To Send The User";
  

    /**
     * @dev Constructor to initialize the insurance protocol with premium price and client address.
     * @param _premiumPrice The monthly insurance premium price.
     * @param _client The address of the wallet owner.
     */
    constructor(uint _premiumPrice, address _client) {
        premiumPrice = _premiumPrice;
        client = _client;
    }

    /**
     * @dev Function for the wallet owner to pay the monthly insurance premium.
     */
    function payMonthlyPremium() external payable {
        // Check if an active premium is already available
        if (block.timestamp < clients[client].validEnd) {
            revert (ERR_ACTIVE_PREMIUM_AVAILABLE);
        }

        // Check if the sent amount is sufficient
        if (msg.value < premiumPrice) {
            revert (ERR_Insufficient_Amount);
        }

        // Set the end of the current insurance period to 30 days from now
        clients[client].validEnd = block.timestamp + 30 days;
    }

    /**
     * @dev Function for the wallet owner to pay the yearly insurance premium.
     */
    function payYearlyPremium() external payable {
        // Check if an active premium is already available
        if (block.timestamp < clients[client].validEnd) {
            revert (ERR_ACTIVE_PREMIUM_AVAILABLE);
        }

        // Check if the sent amount is equal to the yearly premium
        if (msg.value != (premiumPrice * 12 * 10) / 9) {
            revert (ERR_Insufficient_Amount);
        }

        // Set the end of the current insurance period to 365 days from now
        clients[client].validEnd = block.timestamp + 365 days;
    }

    /**
     * @dev Function for the wallet owner to claim insurance.
     * @param _value The amount to be claimed.
     */
    function claimInsurance(uint _value) external {
        // Check if a claim has been made within the last year
        if (block.timestamp <= clients[client].lastClaimed + 365 days) {
            revert (ERR_LastClaimed);
        }

        // Check if the claimed value exceeds twice the yearly premium
        if (_value > premiumPrice * 12 * 2) {
            revert (ERR_AmountExceeds);
        }

        // Check if there are sufficient funds in the contract to send to the user
        if (address(this).balance < _value) {
            revert (ERR_InsufficientFunds);
        }

        // Update the last claimed timestamp and transfer the claimed amount to the user
        clients[client].lastClaimed = block.timestamp;
        payable(client).transfer(_value);
    }

    /**
     * @dev Function to get the current premium price.
     * @return The monthly insurance premium price.
     */
    function getPremiumPrice() external view returns (uint) {
        return premiumPrice;
    }

    /**
     * @dev Function to get the client's insurance details.
     * @return The end timestamp of the current insurance period and the last claimed timestamp.
     */
    function getClientDetails() external view returns (uint, uint) {
        return (clients[client].validEnd, clients[client].lastClaimed);
    }
}