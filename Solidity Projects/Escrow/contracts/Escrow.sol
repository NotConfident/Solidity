// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    address public owner;
    address public partyA;
    address public partyB;

    constructor() public {
        partyA = msg.sender;
        owner = 0xA04C70cab4129a79936C651107cEE1149fB3B6be;
    }

    enum VAULT_STATE {
        OPEN,
        PAUSED,
        CLOSED
    }

    VAULT_STATE public vault_state;

    modifier onlyOwner() {
        require(owner == msg.sender);
        // runs the rest of the code after require
        _;
    }

    function startVault(
        address _partyB,
        address _token,
        uint256 _amount,
        uint256 _time
    ) public {
        vault_state = VAULT_STATE.OPEN;
    }

    function deposit(address _token, uint256 _amount) public payable {
        // check for vault status
        require(msg.sender == partyA || msg.sender == partyB);
    }

    function withdraw(address _token, uint256 _amount) public payable {
        // check for vault status
        require(msg.sender == partyA || msg.sender == partyB);
    }

    function initiateSwap() internal payable {
        // check for vault status
        // start transferring
        vault_state = VAULT_STATE.CLOSED;
    }

    function pauseVault() private {
        vault_state = VAULT_STATE.PAUSED;
    }
}
