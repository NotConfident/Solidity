// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IERC20.sol";

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

    struct TenantListing { // To Rent (Non TA Holder)
        uint256[] tokenAmount; // Qty of the Token to be used
        uint16[] rentDuration;
        address userAddress;
        address delegatedWallet;
        LISTING_INFO status;
    }

    struct LandLordListing { // To Rent Out (TA Holder)
        uint256[] tokenAmount; // Qty of the Token to be used / slot
        uint16[] rentDuration; // Duration of the slot to be rented out
        address userAddress;
        uint256 numSlots; // Number of slots to rent out
        LISTING_INFO status;
    }

    mapping(uint256 => LandLordListing) public landlordListingsMap;
    mapping(uint256 => TenantListing) public tenantListingMap;
    mapping(uint256 => bool) landlordListingsActive;
    mapping(uint256 => bool) tenantListingsActive;

    uint256 public landLordListingID = 0;
    uint256 public tenantListingID = 0;

    // WRITE
    // Create Listings - Tenant, Want to Rent (Non TA Holder)
    function createListingTenant(uint256[] calldata tokenQty, uint16[] calldata slotDuration, address delegateWallet) public {
        TenantListing memory listing;

        listing.tokenAmount = tokenQty;
        listing.rentDuration = slotDuration;
        listing.userAddress = msg.sender;
        listing.delegatedWallet = delegateWallet != address(0) ? delegateWallet : address(0);
        listing.status = LISTING_INFO.OPEN;

        tenantListingMap[tenantListingID] = listing;
        tenantListingsActive[tenantListingID] = true;
        tenantListingID += 1;
    }

    // Create Listings - Landlord, Want to Rent Out (TA Holder)
    // 1000000000000000000 - 1 ETH
    function createListingLandlord(uint256[] calldata tokenQty, uint16[] calldata slotDuration, uint256 numSlots) public {
        LandLordListing memory listing;

        listing.tokenAmount = tokenQty;
        listing.rentDuration = slotDuration;
        listing.userAddress = msg.sender;
        listing.numSlots = numSlots;
        listing.status = LISTING_INFO.OPEN;

        landlordListingsMap[landLordListingID] = listing;
        landlordListingsActive[landLordListingID] = true;
        landLordListingID += 1;
    }


    // Accept Listings - Renting (Non TA Holder)



    // Accept Listings - Renter (TA Holder)
    function acceptListing(uint256 id) public {
        
    }



    // READ
    function viewLandLordListings(uint256 id) public view returns(LandLordListing memory listing) {
        return landlordListingsMap[id];
    }

    function viewTenantsListings(uint256 id) public view returns(TenantListing memory listing) {
        return tenantListingMap[id];
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
