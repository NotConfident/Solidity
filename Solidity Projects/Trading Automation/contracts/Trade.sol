// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;

import './IJoeRouter01.sol';

abstract Trade is IJoeRouter01 {
    address public owner;

    constructor() public {
        owner = msg.sender();
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        // runs the rest of the code after require
        _;
    }

    function swap(
        address token0,
        address token1
    ) external payable onlyOwner {
        address[] memory path = new address[](2);
        path[0] = token0; // 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7
        path[1] = token1; // 0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB

        address joeRouter = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4;

        IJoeRouter01 joe = IJoeRouter01(joeRouter);
        joe.swapExactTokensForTokens(
            818941573487780114653,
            759436430963140651977,
            path,
            0x15Fba290645CB27fad9DE41d3b0051CD978e8218,
            1647311374819
        );
    }
}
