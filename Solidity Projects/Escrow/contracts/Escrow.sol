// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    address public owner;

    struct Party {
        address userAddress;
        address token;
        uint256 amount;
    }

    // 0 - Party A
    // 1 - Party B
    Party[2] public party;
    mapping(address => Party) public addressToParty;

    constructor() public {
        party[0].userAddress = msg.sender;
        owner = 0xA04C70cab4129a79936C651107cEE1149fB3B6be;
    }

    enum VAULT_STATE {
        OPEN,
        PAUSED,
        COMPLETED,
        CANCELLED
    }

    enum STATUS {
        DEPOSITED,
        AWAITING_DEPOSIT,
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
        address _tokenA,
        address _tokenB,
        uint256 _amountA,
        uint256 _amountB,
        uint256 _time
    ) public {
        vault_state = VAULT_STATE.OPEN;
        party[0].userAddress = msg.sender;
        party[0].token = _tokenA;
        party[0].amount = _amountA;

        party[1].userAddress = _partyB;
        party[1].token = _tokenB;
        party[1].amount = _amountB;

        addressToParty[msg.sender] = party[0];
        addressToParty[_partyB] = party[1];
    }

    function deposit(
        address _token,
        uint256 _amountA,
        uint256 _amountB
    ) public payable {
        // check for vault status
        // require(msg.sender == partyA || msg.sender == partyB, "Unauthorized");
        // require(tokenAddressToAmount[_token] != 0, "Invalid Token");
        // require(
        //     amountA == _amountA || amountB == _amountB,
        //     "Amount does not match"
        // );
    }

    function withdraw(address _token, uint256 _amount) public payable {
        // check for vault status
        // require(msg.sender == partyA || msg.sender == partyB);
    }

    function initiateSwap() public payable {
        // check for vault status
        // start transferring
        vault_state = VAULT_STATE.COMPLETED;
    }

    function pauseVault() private {
        vault_state = VAULT_STATE.PAUSED;
    }
}
