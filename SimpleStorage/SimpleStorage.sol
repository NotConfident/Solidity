// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 internal favouriteNumber;
    bool favouriteBool;

    struct People {
        uint256 favouriteNumber;
        string name;
    }

    People[] internal people;
    mapping(string => uint256) internal nameToFavouriteNumber;
    mapping(uint256 => address) internal peopleToAddress;
    mapping(address => uint256) internal addressToPeople;

    // function store(uint256 _favouriteNumber) public {
    //     favouriteNumber = _favouriteNumber;
    // }

    function retrieveFavouriteNumber(string memory _name) public view returns(uint256) {
        return nameToFavouriteNumber[_name];
    }

    function retrievePerson(address _user) public view returns(People memory) {
        return people[addressToPeople[_user]];
    }

    // memory - stored only during function execution and not written on chain
    // storage - non persistent, data written on chain
    function addPerson(string memory _name, uint256 _favouriteNumber) public {
        people.push(People(_favouriteNumber, _name));
        uint _id = people.length - 1;
        // store and associate name to number in mapping
        nameToFavouriteNumber[_name] = _favouriteNumber;
        peopleToAddress[_id] = msg.sender;
    }
}