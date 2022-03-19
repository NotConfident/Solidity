// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IJoeRouter01.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Trade is IJoeRouter01 {
    address public owner;
    IERC20 private token;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        // runs the rest of the code after require
        _;
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external onlyOwner returns (uint256[] memory amounts) {
        address[] memory addressPath = new address[](2);
        addressPath[0] = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7; // To remove as it can be supplied by calls
        addressPath[1] = 0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB; // To remove as it can be supplied by calls

        address joeRouter = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4;

        IJoeRouter01 joe = IJoeRouter01(joeRouter);
        token = IERC20(addressPath[0]);

        joe.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            addressPath,
            to,
            deadline
        );
    }
}
