// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AirdropToken is ReentrancyGuard {
    // State variables
    address public owner;
    IERC20 public token;
    uint256 public airdropQuantity;

    // Events
    event AirdropExecuted(
        address indexed sender,
        uint256 amount,
        uint256 totalRecipients
    );
    event AirdropAllocation(uint256 newAllocation);

    // Constructor
    constructor(address _token, uint256 _airdropAllocation) {
        owner = msg.sender;
        token = IERC20(_token);
        airdropQuantity = _airdropAllocation;
    }

    // Modifiers
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    // Functions
    function tokensAllocation(uint256 _newAllocation) external onlyOwner {
        airdropQuantity = _newAllocation;
        emit AirdropAllocation(_newAllocation);
    }

    function tokenApproval(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Invalid approval amount");
        token.approve(address(this), _amount);
    }

    function transferTokens(
        address[] memory _recipients,
        uint256 _amount
    ) external onlyOwner nonReentrant {
        require(_recipients.length > 0, "No recipients specified");
        require(_amount > 0, "Invalid amount");

        uint256 totalAmount = airdropQuantity * _recipients.length;
        require(
            token.balanceOf(address(this)) >= totalAmount,
            "Insufficient contract balance"
        );

        for (uint256 i = 0; i < _recipients.length; i++) {
            if (_recipients[i] != address(0)) {
                token.transfer(_recipients[i], airdropQuantity);
            }
        }

        emit AirdropExecuted(msg.sender, airdropQuantity, _recipients.length);
    }
}
