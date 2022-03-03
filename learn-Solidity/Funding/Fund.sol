// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping (address => uint256) public addressToFunding;
    address public owner;
    address[] public funders;

    // executes once during contract creation
    constructor() public {
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10 ** 18;
        require(convertToUSD(msg.value) >= minimumUSD, "You need to spend more ETH!");
        addressToFunding[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }

    function getPrice() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        // Max out to 18 digits / 18 Digits
        return uint256(answer * 10000000000) / 1000000000000000000;
    }

    function convertToUSD(uint256 _value) public view returns(uint) {
       return (_value * getPrice());
    }

    // used to change the behaviour of the function in a declarative way
    modifier onlyOwner {
        require(owner == msg.sender);
        // runs the rest of the code after require
        _; 
    }

    function withdrawSpecific() public payable {
        msg.sender.transfer(addressToFunding[msg.sender]);
        // deduct the full amount an address sent to the amount withdrawn (which is all)
        addressToFunding[msg.sender] -= addressToFunding[msg.sender];
    }

    function withdrawAll() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
        // reset each key (address) with a value of 0
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToFunding[funder] = 0;
        }
        funders = new address[](0);
    }

}