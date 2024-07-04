// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract RealEstateNFT is ERC721Enumerable {

    mapping(uint256 => Property) public properties;

    event PropertyNFTCreated(uint256 propertyID, address owner);

    struct Property {
        uint256 propertyID;
        string propertyAddress;
        uint256 landArea;
        address ownerAddress;
        uint256 askingPrice;
        address creatorAddress;
    }

    uint256 constant ROYALTY_PERCENTAGE = 5; // Définissez le pourcentage de redevance (ex: 5% pour 0.05)

    constructor() ERC721("RealEstateNFT", "RENFT") {}

    function createPropertyNFT(string memory _propertyAddress, uint256 _landArea, address _ownerAddress, uint256 _askingPrice) public {
        uint256 propertyID = totalSupply();
        properties[propertyID] = Property(propertyID, _propertyAddress, _landArea, _ownerAddress, _askingPrice, msg.sender); // Store property details
        _mint(msg.sender, propertyID);
        emit PropertyNFTCreated(propertyID, msg.sender);
    }

    function listPropertyForSale(uint256 _propertyID, uint256 _askingPrice) public {
        require(ownerOf(_propertyID) == msg.sender, "Only the property owner can list for sale");
        properties[_propertyID].askingPrice = _askingPrice;
        emit PropertyListedForSale(_propertyID, _askingPrice);
    }

    // Function to buy a listed property
    function buyPropertyNFT(uint256 _propertyID, uint256 _amount) public payable {
        require(properties[_propertyID].askingPrice > 0, "Property is not listed for sale");
        require(_amount >= properties[_propertyID].askingPrice, "Offer must be equal to or greater than asking price");

        address seller = ownerOf(_propertyID);
        require(seller != msg.sender, "Cannot buy your own property");

        _transfer(seller, msg.sender, _propertyID);

        properties[_propertyID].askingPrice = 0;
        properties[_propertyID].ownerAddress = msg.sender;

        uint256 royaltyAmount = _amount * ROYALTY_PERCENTAGE / 100;
        if (royaltyAmount > 0) {
            payable(properties[_propertyID].creatorAddress).transfer(royaltyAmount);
        }

        payable(seller).transfer(_amount - royaltyAmount);

        emit PropertyNFTSold(_propertyID, msg.sender, _amount);
    }

    function cancelSale(uint256 _propertyID) public {
        require(ownerOf(_propertyID) == msg.sender, "Only the property owner can cancel sale");
        properties[_propertyID].askingPrice = 0;
        emit PropertySaleCanceled(_propertyID);
    }

    event PropertyListedForSale(uint256 propertyID, uint256 askingPrice);

    event PropertyNFTSold(uint256 propertyID, address buyer, uint256 amount);

    // Event emitted when a property sale is canceled
    event PropertySaleCanceled(uint256 propertyID);
}
