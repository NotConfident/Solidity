// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IERC20.sol";

contract Rental {
    address public owner;
    IERC20 private token;
    
    address AstroStakingControllerV3 = 0x1be7aC1d4974C9920E30E2DBC3a57F9e0e1c8EF2;

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
        uint256 tokenAmount; // Qty of the Token to be used
        uint16 rentDuration;
        address userAddress;
        address delegatedWallet;
        LISTING_INFO status;
    }

    struct LandLordListing { // To Rent Out (TA Holder)
        uint256 tokenAmount; // Qty of the Token to be used / slot
        uint16 rentDuration; // Duration of the slot to be rented out
        address userAddress;
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
    function createListingTenant(uint256 ethQty, uint16 slotDuration, address delegateWallet) public payable {
        TenantListing storage listing = tenantListingMap[tenantListingID];

        listing.tokenAmount = ethQty;
        listing.rentDuration = slotDuration;
        listing.userAddress = msg.sender;
        listing.delegatedWallet = delegateWallet;
        // listing.status = LISTING_INFO.OPEN; // Default open upon creation

        // tenantListingMap[tenantListingID] = listing; // Mapped on Line 53
        // tenantListingsActive[tenantListingID] = true;

        tenantListingID += 1;
        require(msg.sender == tx.origin);
        require(msg.value == ethQty, "Not enough ETH");
    }

    // Create Listings - Landlord, Want to Rent Out (TA Holder)
    // 1000000000000000000 - 1 ETH
    function createListingLandlord(uint256 ethQty, uint16 slotDuration) public {
        LandLordListing storage listing = landlordListingsMap[landLordListingID];

        listing.tokenAmount = ethQty;
        listing.rentDuration = slotDuration;
        listing.userAddress = msg.sender;
        // listing.status = LISTING_INFO.OPEN; // Default open upon creation

        // landlordListingsMap[landLordListingID] = listing; // Mapped on Line 71
        // landlordListingsActive[landLordListingID] = true;
        landLordListingID += 1;
    }


    // Accept Listings - Tenant (Non TA Holder)


    // Accept Listings - Landlord (TA Holder) // Use rentalRecipientStatus() to verify
    function acceptListing(uint256 id) public {
        TenantListing memory listing;
        listing = tenantListingMap[id];

        bool isValid;
        address tenantWallet = listing.delegatedWallet;

        // Verify if Landlord has Rented out pass to Tenant on chain
        (isValid, ) = AstroStakingControllerV3.call(abi.encodeWithSignature("rentalRecipientStatus(address)", tenantWallet));
        require(isValid == true);
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

interface IRentalInterface {
    function rentalRecipientStatus(
        address recipient
        ) external;
}