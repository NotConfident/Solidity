// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IJoeRouter01.sol";
import "./IERC20.sol";

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Trade is IJoeRouter01 {
    address public owner;
    IERC20 private token;
    address private constant router =
        0x60aE616a2155Ee3d9A68541Ba4544862310933d4;
    address private constant WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    address private constant USDTe = 0xc7198437980c041c805A1EDcbA50c1Ce5db95118;

    constructor() {
        owner = msg.sender;
        _approve(WAVAX);
        _approve(USDTe);
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        // runs the rest of the code after require
        _;
    }

    // Approve DEX to spend Token that is called from contract address
    // Fund contract
    function _approve(address _token) public {
        token = IERC20(_token);
        token.approve(
            router,
            115792089237316195423570985008687907853269984665640564039457584007913129639935 // 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) public onlyOwner returns (uint256[] memory amounts) {
        IJoeRouter01 joe = IJoeRouter01(router);
        joe.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );
        return amounts;
    }

    function _getPath_WAVAX_USDTe(bool reverse)
        internal
        pure
        returns (address[] memory)
    {
        address[] memory path = new address[](2);
        if (reverse == true) {
            path[0] = USDTe; // USDTe
            path[1] = WAVAX; // WAVAX
        } else {
            path[0] = WAVAX; // WAVAX
            path[1] = USDTe; // USDTe
        }
        return path;
    }

    function _swapIn() public onlyOwner returns (uint256[] memory amounts) {
        swapExactTokensForTokens(
            IERC20(_getPath_WAVAX_USDTe(false)[0]).balanceOf(address(this)),
            1,
            _getPath_WAVAX_USDTe(false),
            address(this),
            1679899143
        );
        return amounts;
    }

    function _swapOut() public onlyOwner returns (uint256[] memory amounts) {
        swapExactTokensForTokens(
            IERC20(_getPath_WAVAX_USDTe(true)[0]).balanceOf(address(this)),
            1,
            _getPath_WAVAX_USDTe(true),
            address(this),
            1679899143
        );
        return amounts;
    }
}
