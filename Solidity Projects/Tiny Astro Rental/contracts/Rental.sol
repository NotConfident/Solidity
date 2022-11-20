// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Rental {
    address public owner;
    IERC20 private token;
    
    event Received(address, uint256);

    modifier onlyOwner() { // For emergency cases that requires interference
        require(owner == msg.sender);
        // runs the rest of the code after require
        _;
    }

    enum LISTING_INFO {
        OPEN,
        PAUSED,
        COMPLETED,
        CANCELLED
    }

    struct RenterListing { // To Rent
        address tokenAddress; // Contract Address of the Token to used
        uint256 tokenAmount; // Qty of the Token to be used
        uint16 duration;
        address userAddress;
        address delegatedWallet;
        LISTING_INFO status;
    }

    mapping(uint256 => RenterListing) public renterListingsMap;
    uint256 public nextListingID = 0;

    // WRITE
    // Create Listings - Want to Rent (Non TA Holder)
    function createListing(address _token, uint256 tokenQty, uint16 rentDuration, address delegatedWallet) public {
        RenterListing memory listing;

        listing.tokenAddress = _token;
        listing.tokenAmount = tokenQty;
        listing.duration = rentDuration;
        listing.userAddress = msg.sender;
        listing.delegatedWallet = delegatedWallet != address(0) ? delegatedWallet : address(0);
        listing.status = LISTING_INFO.OPEN;

        renterListingsMap[nextListingID] = listing;
        nextListingID += 1;

        token = IERC20(_token);
        token.approve(address(this), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        token.transferFrom(msg.sender, address(this), tokenQty);
        
    }

    // Create Listings - Want to Rent Out (TA Holder)
    


    // Accept Listings - Renting (Non TA Holder)



    // Accept Listings - Renter (TA Holder)
    function acceptListing(uint256 id) public {
        
    }



    // READ
    function viewListings(uint256 id) public view returns(RenterListing memory listing) {
        return renterListingsMap[id];
    }


    // Withdrawal Functions
    function withdraw() public {
        payable(owner).transfer(address(this).balance);
    }

    function withdrawToken(address _token) public payable onlyOwner {
        token = IERC20(_token);
        token.transfer(owner, IERC20(_token).balanceOf(address(this)));
    }


    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable{}
}

// interface RentalInterface {
//     function transferFrom(
//         address from,
//         address to,
//         uint256 tokenId
//     ) external;
// }
