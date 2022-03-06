// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Escrow {
    address public owner;

    struct Party {
        address userAddress;
        address token;
        uint256 amountToDeposit;
        uint256 depositedAmount;
        STATUS status;
    }

    // 0 - Party A
    // 1 - Party B
    Party[2] public party;
    mapping(address => uint256) public addressToPartyIndex;
    mapping(address => Party) public addressToParty;

    constructor() public {
        party[0].userAddress = msg.sender;
        owner = 0xA04C70cab4129a79936C651107cEE1149fB3B6be;
    }

    IERC20 private token;

    enum VAULT_STATE {
        OPEN,
        PAUSED,
        COMPLETED,
        CANCELLED
    }

    enum STATUS {
        AWAITING_DEPOSIT,
        PARTIALLY_DEPOSITED,
        DEPOSITED,
        CLOSED
    }

    VAULT_STATE public vault_state;

    modifier onlyOwner() {
        require(owner == msg.sender);
        // runs the rest of the code after require
        _;
    }

    // Party B - 0xA04C70cab4129a79936C651107cEE1149fB3B6be
    // Token A - 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735 (DAI)
    // Token B - 0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b (USDC)
    // Amount A - 1000000000000000000 ($1)
    // Amount B - 1000000000000000000 ($1)
    // Time - 1000000000000000000 (Random)
    // Party B                                    // DAI                                     // USDC                                    // Amount A         // Amount B         // Time
    // 0x59CD8252063DeEa2eaF539645F697A58F9Bebe39,0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735,0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b,1000000000000000000,1000000000000000000,1000000000000000000
    function startVault(
        address _partyB,
        address _tokenA,
        address _tokenB,
        uint256 _amountA,
        uint256 _amountB,
        uint256 _time
    ) public {
        vault_state = VAULT_STATE.OPEN;
        Party storage first = party[0];
        Party storage second = party[1];

        first.userAddress = msg.sender;
        first.token = _tokenA;
        first.amountToDeposit = _amountA;

        second.userAddress = _partyB;
        second.token = _tokenB;
        second.amountToDeposit = _amountB;

        addressToParty[msg.sender] = first;
        addressToParty[_partyB] = second;
        addressToPartyIndex[msg.sender] = 0;
        addressToPartyIndex[msg.sender] = 1;
    }

    // // Approve manually on token sc instead of via this sc
    // function approve(address _token, uint256 amount) public {
    //     token = IERC20(_token);
    //     token.approve(address(this), amount);
    // }

    // 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735,1000000000000000000
    function deposit(address _token, uint256 _amount) public payable {
        // check for vault status
        require(
            msg.sender == addressToParty[msg.sender].userAddress ||
                msg.sender == addressToParty[msg.sender].userAddress,
            "Unauthorized"
        );
        require(_token == addressToParty[msg.sender].token, "Invalid Token");

        token = IERC20(_token);
        // Approve on DAI with Contract Address and 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        token.transferFrom(msg.sender, address(this), _amount);

        Party storage userMappings = party[
            msg.sender == party[0].userAddress ? 0 : 1
        ];
        userMappings.depositedAmount += _amount;

        if (
            _amount + userMappings.depositedAmount <
            userMappings.amountToDeposit
        ) {
            userMappings.status = STATUS.PARTIALLY_DEPOSITED;
        } else {
            userMappings.status = STATUS.DEPOSITED;
        }
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
