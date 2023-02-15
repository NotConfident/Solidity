// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./IERC721.sol";
import "./IERC20.sol";

contract Rental {
    address public owner;
    IERC20 private token;

    address AstroStakingControllerV3 =
        0xf3133E0aBfbb8D4Ee97858006D29fFf6a1F66733;

    event Received(address, uint256);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        // For emergency cases that requires interference
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

    struct TenantListing {
        // To Rent (Non TA Holder)
        uint256 tokenAmount; // Qty of the Token to be used
        uint16 rentDuration;
        address userAddress;
        address delegatedWallet;
        address landlordAddress;
        uint256 reserveTimestamp;
        bool refunded;
        bool rentStatus; // True - Rented Successfully
        LISTING_INFO status;
    }

    struct LandLordListing {
        // To Rent Out (TA Holder)
        uint256 tokenAmount; // Qty of the Token to be used / slot
        uint16 rentDuration; // Duration of the slot to be rented out
        address userAddress;
        address callerAddress;
        address delegatedWallet;
        uint256 highestBid;
        bool rentStatus;
        uint256 reserveTimestamp;
        LISTING_INFO status;
    }

    mapping(uint256 => LandLordListing) public landlordListingsMap;
    mapping(uint256 => TenantListing) public tenantListingMap;
    mapping(uint256 => bool) landlordListingsActive;
    mapping(uint256 => bool) tenantListingsActive;

    uint256 public landLordListingID = 0;
    uint256 public tenantListingID = 0;

    // **************************************
    // *                                    *
    // *               TENANT               *
    // *                                    *
    // **************************************
    // Create Listings - Tenant, Want to Rent (Non TA Holder)
    function createListingTenant(
        uint256 ethQty,
        uint16 slotDuration,
        address delegateWallet
    ) public payable {
        TenantListing storage listing = tenantListingMap[tenantListingID];

        listing.tokenAmount = ethQty;
        listing.rentDuration = slotDuration;
        listing.userAddress = msg.sender;
        listing.delegatedWallet = delegateWallet;

        // tenantListingsActive[tenantListingID] = true;

        require(msg.sender == tx.origin);
        require(msg.value == ethQty, "Ensure exact ETH is sent");
        ++tenantListingID;
    }

    // Cancel Tenant Listings - Tenant, Want to Rent (Non TA Holder)
    function cancelTenantListings(uint256 id) public {
        TenantListing memory listing = tenantListingMap[id];

        require(listing.userAddress == msg.sender, "Unauthorized user");
        require(listing.status == LISTING_INFO.OPEN, "Invalid listing");

        // (bool success, bytes memory result) = AstroStakingControllerV3.call(abi.encodeWithSignature("rentalRecipientStatus(address)", listing.delegatedWallet));
        // (
        //     bool isValid,
        //     uint32 expiration
        // ) = abi.decode(result, (bool, uint32));
        // require(isValid == false, "Already rented");

        // require (listing.status == LISTING_INFO.OPEN || listing.status == LISTING_INFO.PAUSED, "Listing is not active");
        // require(listing.refunded == false);
        verifyNotRentedTenant(listing.delegatedWallet, listing);

        payable(listing.userAddress).transfer(listing.tokenAmount);
        listing.status = LISTING_INFO.CANCELLED;
        listing.refunded = true;
    }

    // Bid for Landlord Listings - Tenant, Want to Rent (Non TA Holder)
    function bid(
        uint256 id,
        uint256 ethQty,
        address delegateWallet
    ) public payable {
        LandLordListing storage listing = landlordListingsMap[id];

        require(listing.status == LISTING_INFO.OPEN, "Listing not active");
        require(listing.userAddress != address(0), "Listing not active");
        require(
            ethQty > listing.highestBid,
            "Bid must be higher than current bid"
        );

        // Verify if Landlord has Rented out pass to Tenant on chain
        // Its not the Landlord interest to not collect deposit after renting out pass, no need to verify for it
        // (bool success, bytes memory result) = AstroStakingControllerV3.call(abi.encodeWithSignature("rentalRecipientStatus(address)", listing.delegatedWallet));
        // (
        //     bool isValid,
        //     uint32 expiration
        // ) = abi.decode(result, (bool, uint32));
        // require(isValid == false, "Already rented");

        verifyNotRentedLandlord(delegateWallet, listing);

        // Set current highest bidder address and ETH
        require(msg.value == ethQty, "Ensure exact ETH is sent");

        // Return ETH to the previous highest bidder
        if (listing.callerAddress != address(0)) {
            payable(listing.callerAddress).transfer(listing.highestBid);
        }

        listing.highestBid = ethQty;
        listing.callerAddress = msg.sender;
        listing.delegatedWallet = delegateWallet;
    }

    // Cancel Bids made by Tenant - Tenant, Want to Rent (Non TA Holder)
    function cancelBids(uint256[] calldata ids) public payable {
        for (uint256 i = 0; i < ids.length; ++i) {
            LandLordListing storage listing = landlordListingsMap[ids[i]];
            require(listing.status == LISTING_INFO.OPEN, "Listing not active");
            require(msg.sender == listing.callerAddress);
            payable(listing.callerAddress).transfer(listing.highestBid);
        }
    }

    // **************************************
    // *                                    *
    // *              Landlord              *
    // *                                    *
    // **************************************
    // Create Listings - Landlord, Want to Rent Out (TA Holder)
    function createListingLandlord(uint256 ethQty, uint16 slotDuration) public {
        LandLordListing storage listing = landlordListingsMap[
            landLordListingID
        ];

        listing.tokenAmount = ethQty;
        listing.rentDuration = slotDuration;
        listing.userAddress = msg.sender;
        listing.rentStatus = false;

        ++landLordListingID;
    }

    // Reserve Tenant Listing
    // Due to technical limitations, its impossible to retrieve the address of the Landlord that
    // rented their pass to the Tenant. Hence a workaround is to reserve a spot for 5 mins, in which no other
    // Landlords can attempt to rent out to the tenants

    // Prevent another user from claiming the deposit of the landlord. Bots are able to snipe deposit of
    // tenant without this function
    function reserveTenantListing(uint256 id) public {
        TenantListing storage listing = tenantListingMap[id];

        // Verify if Landlord has Rented out pass to Tenant on chain
        // Its not the Landlord interest to not collect deposit after renting out pass, no need to verify for it
        // Prevent bots from monitoring mempool and calling reserveTenantListing
        verifyNotRentedTenant(listing.delegatedWallet, listing);

        // If current block timestamp is more than reserveTimestamp - Reservation expired.
        require(block.timestamp >= listing.reserveTimestamp, "Reserved");
        listing.landlordAddress = msg.sender;
        listing.reserveTimestamp = block.timestamp + 600; // 600 seconds = 10 mins
    }

    // Accept Bid placed on Landlord listing by Tenants - Landlord (TA Holder) ✅
    function acceptTenantBid(uint256 id) public {
        LandLordListing storage listing = landlordListingsMap[id];
        require(listing.status == LISTING_INFO.OPEN, "Invalid listing");
        require(listing.userAddress == msg.sender, "Unauthorized");

        // Verify if Landlord has Rented out pass to Tenant on chain
        // Its not the Landlord interest to not collect deposit after renting out pass, no need to verify for it
        verifyRentedLandlordBid(listing.delegatedWallet, listing);

        require(listing.rentStatus == false, "Listing has already settled");

        payable(listing.userAddress).transfer(listing.highestBid);

        listing.rentStatus = true;
        listing.status = LISTING_INFO.COMPLETED;
    }

    // Accept Listings - Landlord (TA Holder)
    // Use rentalRecipientStatus() to verify
    // Delegated wallet cannot have an active pass, TA have a check on that ✅
    function acceptTenantListing(uint256 id) public payable {
        TenantListing storage listing = tenantListingMap[id];

        require(listing.status == LISTING_INFO.OPEN, "Invalid listing");
        require(listing.landlordAddress == msg.sender, "Unauthorized");

        // Verify if Landlord has Rented out pass to Tenant on chain
        // Its not the Landlord interest to not collect deposit after renting out pass, no need to verify for it
        verifyRentedLandlord(listing.delegatedWallet, listing);

        require(listing.reserveTimestamp < block.timestamp + 600, "Expired"); // 600 seconds = 10 mins

        payable(listing.landlordAddress).transfer(listing.tokenAmount);
        listing.rentStatus = true;
        listing.status = LISTING_INFO.COMPLETED;
    }

    // Anyone can call this function to release funds to respective parties ✅
    function forceCloseSuccessfulRent(uint256 id) public payable {
        // Forfeit 10% of the deposit by having another user to close out a successful trade if the
        // landlord refuse to close order to save gas
        TenantListing storage listing = tenantListingMap[id];

        // Verify if Landlord has Rented out pass to Tenant on chain
        // Its not the Landlord interest to not collect deposit after renting out pass, no need to verify for it
        // Prevent bots from monitoring mempool and calling reserveTenantListing
        verifyRentedLandlord(listing.delegatedWallet, listing);

        require(listing.landlordAddress != address(0));
        require(block.timestamp > listing.reserveTimestamp + 3600); // 3600 - 1 Hour

        payable(msg.sender).transfer((listing.tokenAmount / 100) * 10);
        payable(listing.landlordAddress).transfer(
            (listing.tokenAmount / 100) * 90
        );
    }

    // **************************************
    // *                                    *
    // *               Helper               *
    // *                                    *
    // **************************************
    function verifyNotRentedTenant(
        address delegatedWallet,
        TenantListing memory listing
    ) internal {
        (bool success, bytes memory result) = AstroStakingControllerV3.call(
            abi.encodeWithSignature(
                "rentalRecipientStatus(address)",
                listing.delegatedWallet
            )
        );
        (bool isValid, uint32 expiration) = abi.decode(result, (bool, uint32));
        require(isValid == false, "Already rented");

        require(
            listing.status == LISTING_INFO.OPEN ||
                listing.status == LISTING_INFO.PAUSED,
            "Listing is not active"
        );
        require(listing.refunded == false);
    }

    function verifyNotRentedLandlord(
        address delegatedWallet,
        LandLordListing memory listing
    ) internal {
        (bool success, bytes memory result) = AstroStakingControllerV3.call(
            abi.encodeWithSignature(
                "rentalRecipientStatus(address)",
                delegatedWallet
            )
        );
        (bool isValid, uint32 expiration) = abi.decode(result, (bool, uint32));
        require(isValid == false, "Already rented");
    }

    function verifyRentedLandlord(
        address delegatedWallet,
        TenantListing memory listing
    ) internal {
        (bool success, bytes memory result) = AstroStakingControllerV3.call(
            abi.encodeWithSignature(
                "rentalRecipientStatus(address)",
                listing.delegatedWallet
            )
        );
        (bool isValid, uint32 expiration) = abi.decode(result, (bool, uint32));
        require(isValid == true, "Pass isnt rented out yet");
    }

    function verifyRentedLandlordBid(
        address delegatedWallet,
        LandLordListing memory listing
    ) internal {
        (bool success, bytes memory result) = AstroStakingControllerV3.call(
            abi.encodeWithSignature(
                "rentalRecipientStatus(address)",
                listing.delegatedWallet
            )
        );
        (bool isValid, uint32 expiration) = abi.decode(result, (bool, uint32));
        require(isValid == true, "Pass isnt rented out yet");
    }

    // **************************************
    // *                                    *
    // *              Read Only             *
    // *                                    *
    // **************************************
    function viewLandLordListings(uint256 id)
        public
        view
        returns (LandLordListing memory listing)
    {
        return landlordListingsMap[id];
    }

    function viewTenantsListings(uint256 id)
        public
        view
        returns (TenantListing memory listing)
    {
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

    fallback() external payable {}
}

interface IRentalInterface {
    function rentalRecipientStatus(address recipient)
        external
        view
        returns (bool, uint256);
}
