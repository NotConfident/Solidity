pragma solidity >=0.5.0;

import "@truffle/packages/resolver/solidity/Assert.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@truffle/DeployedAddresses.sol";
import "../contracts/Trade.sol";

contract TestTrade {
    Trade public trade;
    IERC20 private token;

    function beforeEach() public {
        trade = new Trade();
    }

    function test_Approval(address _token) public {
        trade.approve(_token);
        Assert.equal(
            token.allowance(trade.owner, trade.joeRouter) ==
                115792089237316195423570985008687907853269984665640564039457584007913129639935,
            "Invalid Allowance!"
        );
    }
}
