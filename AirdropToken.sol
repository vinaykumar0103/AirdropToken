// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Import ERC20 and safety tools
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AirdropToken is ReentrancyGuard {
    // Contract owner and airdrop token
    address public owner;
    IERC20 public token;

    // Amount airdropped to each recipient
    uint256 public airdropQuantity;

    // Events for airdrop execution and quantity change
    event AirdropExecuted(address sender, uint256 amount, uint256 recipients);
    event AirdropAllocation(uint256 newAllocation);

    // Constructor sets up airdrop
    constructor(address _token, uint256 _airdropAmount) {
        owner = msg.sender;
        token = IERC20(_token);
        airdropQuantity = _airdropAmount;
    }

    // Modifier restricts functions to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Adjust airdrop amount per recipient (owner only)
    function tokensAllocation(uint256 _newAllocation) external onlyOwner {
        airdropQuantity = _newAllocation;
        emit AirdropAllocation(_newAllocation);
    }

    // Approve contract to spend tokens for airdrop (owner only)
    function tokenApproval(uint256 _amount) external onlyOwner {
        token.approve(address(this), _amount);
    }

    // Send airdrop to list of recipients (owner only, secure against reentrancy)
    function transferTokens(address[] memory _recipients) external onlyOwner nonReentrant {
        require(_recipients.length > 0, "No recipients provided");
        uint256 totalAmount = airdropQuantity * _recipients.length;
        require(token.balanceOf(address(this)) >= totalAmount, "Insufficient contract balance");
        for (uint256 i = 0; i < _recipients.length; i++) {
            if (_recipients[i] != address(0)) {
                token.transfer(_recipients[i], airdropQuantity);
            }
        }
        emit AirdropExecuted(msg.sender, airdropQuantity, _recipients.length);
    }
}
