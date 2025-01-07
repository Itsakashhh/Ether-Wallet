// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Ownable } from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import { IERC20, SafeERC20 } from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import { Strings } from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract EthWallet is Ownable {
    using SafeERC20 for IERC20;

    constructor(address initialOwner) Ownable(initialOwner) {}

    // Events
    event DepositLogged(address indexed sender, uint256 amount);
    event WithdrawalLogged(address indexed receiver, uint256 amount);
    event TokenTransfer(address indexed token, address indexed to, uint256 amount);

    // Core Functions
    function deposit() external payable {
        emit DepositLogged(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, 
        string(abi.encodePacked("Insufficient balance. Current balance: ", Strings.toString(address(this).balance))));
        payable(owner()).transfer(amount);
        emit WithdrawalLogged(owner(), amount);
    }

    function transfer(address token, address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Recipient address cannot be zero");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (token == address(0)) {
            // ETH transfer
            require(address(this).balance >= amount, "Insufficient ETH balance");
            payable(to).transfer(amount);
        } else {
            // ERC-20 transfer
            IERC20(token).safeTransfer(to, amount);
        }
        emit TokenTransfer(token, to, amount);
    }

    // Fallback function to accept ETH directly
    receive() external payable {
        emit DepositLogged(msg.sender, msg.value);
    }

    // Fallback function to handle unexpected calldata
    fallback() external payable {
        emit DepositLogged(msg.sender, msg.value);
    }

    function getETHBalance() external view returns (uint256) {
        return address(this).balance;
    }

}
