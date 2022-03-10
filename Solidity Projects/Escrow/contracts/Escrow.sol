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

    // DAI is used as POC for both param as LINK Token have some issues
    // Party B - 0xA04C70cab4129a79936C651107cEE1149fB3B6be
    // Token A - 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735 (DAI)
    // Token B - 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735 (DAI)
    // Amount A - 1000000000000000000 ($1)
    // Amount B - 1000000000000000000 ($1)
    // Time - 1000000000000000000 (Random)
    // Party B                                    // DAI                                     // DAI                                    // Amount A         // Amount B         // Time
    // 0xA04C70cab4129a79936C651107cEE1149fB3B6be,0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735,0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735,1000000000000000000,1000000000000000000,1000000000000000000
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

    // 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735,1000000000000000000 (DAI)
    // 0x01BE23585060835E02B77ef475b0Cc51aA1e0709,1000000000000000000 (LINK)
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

        checkDeposits();
    }

    function withdraw(address _token, uint256 _amount) public payable {
        // check for vault status
        // require(msg.sender == partyA || msg.sender == partyB);
    }

    function checkDeposits() internal {
        if (
            party[0].status == STATUS.DEPOSITED &&
            party[1].status == STATUS.DEPOSITED
        ) {
            initiateSwap();
        }
    }

    // POC Done: https://rinkeby.etherscan.io/tx/0xa6234e3bf3d0e7ad16236cbba49762ba666d4a7261b0394c840419630ec4aaf2
    function initiateSwap() public payable {
        // check for vault status
        require(vault_state == VAULT_STATE.OPEN);

        Party storage partyA = party[0];
        Party storage partyB = party[1];

        // start transferring
        // Party A -> Party B
        token = IERC20(partyA.token);
        token.transferFrom(
            address(this),
            partyB.userAddress,
            partyA.amountToDeposit
        );

        // Party B -> Party A
        token = IERC20(partyB.token);
        token.transferFrom(
            address(this),
            partyA.userAddress,
            partyB.amountToDeposit
        );

        vault_state = VAULT_STATE.COMPLETED;
    }

    function pauseVault() private {
        vault_state = VAULT_STATE.PAUSED;
    }
}
