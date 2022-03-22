// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IJoeRouter01.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Trade is IJoeRouter01 {
    address public owner;
    IERC20 private token;
    address public router = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        // runs the rest of the code after require
        _;
    }

    // Approve DEX to spend Token that is called from contract address
    // Fund contract

    function approve(address _token) public {
        token = IERC20(_token);
        token.approve(
            router,
            115792089237316195423570985008687907853269984665640564039457584007913129639935
        ); // 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff /
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external onlyOwner returns (uint256[] memory amounts) {
        // 0x22d4002028f537599bE9f666d1c4Fa138522f9c8; // PTP
        // 0x060556209E507d30f2167a101bFC6D256Ed2f3e1; // xPTP

        IJoeRouter01 joe = IJoeRouter01(router);
        joe.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );
    }

    function withdrawToken(address _token, uint256 _balance)
        public
        payable
        onlyOwner
    {
        token = IERC20(_token);
        token.transfer(owner, _balance);
    }
}
