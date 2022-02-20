// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract SimpleStorage {
    uint256 internal favouriteNumber;
    bool favouriteBool;

    struct People {
        string name;
        uint256 favouriteNumber;
    }

    People[] public people;
    mapping(string => uint256) public nameToFavouriteNumber;

    function store(uint256 _favouriteNumber) public returns (uint256) {
        favouriteNumber = _favouriteNumber;
        return _favouriteNumber;
    }

    function retrieve() public view returns (uint256) {
        return favouriteNumber;
    }

    // memory - stored only during function execution and not written on chain
    // storage - non persistent, data written on chain
    function addPerson(string memory _name, uint256 _favouriteNumber) public {
        people.push(People(_name, _favouriteNumber));
        // uint _id = people.length - 1;
        // store and associate name to number in mapping
        nameToFavouriteNumber[_name] = _favouriteNumber;
        // peopleToAddress[_id] = msg.sender;
    }
}
