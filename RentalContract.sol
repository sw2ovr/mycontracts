//SPDX-License-Identifier: Paco
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract RentalContract is IERC721Receiver {
    using Address for address;

    address public owner;
    IERC721 public nftContract;
    uint public tokenIdCounter;
    uint public extensionPeriod; // Período de extensión en segundos (por ejemplo, 1 semana: 7 * 24 * 60 * 60)
    uint public maxLatePayments; // Número máximo de pagos fuera de plazo permitidos antes de anular el contrato
    mapping(uint => Rental) public rentals;

    struct Rental {
        address tenant;
        uint rentalDuration;
        uint rentalPrice;
        uint rentalStartDate;
        uint lastPaymentTimestamp; // Último momento en que se realizó el pago
        uint extensionCount; // Número de veces que se ha extendido el alquiler
        uint tokenId;
        uint latePayments; // Contador de pagos fuera de plazo
    }

    event NFTTransferred(address indexed from, address indexed to, uint indexed tokenId);
    event RentalDurationUpdated(uint indexed tokenId, uint rentalDuration);
    event NFTBurned(uint indexed tokenId);
    event RentalExtended(uint indexed tokenId, uint extensionCount);
    event RentalPriceUpdated(uint indexed tokenId, uint rentalPrice);
    event TenantUpdated(uint indexed tokenId, address oldTenant, address newTenant);

    constructor(address _nftContract, uint _extensionPeriod, uint _maxLatePayments) {
        owner = msg.sender;
        nftContract = IERC721(_nftContract);
        tokenIdCounter = 1;
        extensionPeriod = _extensionPeriod;
        maxLatePayments = _maxLatePayments;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function.");
        _;
    }

    modifier onlyCurrentTenant(uint _tokenId) {
        require(rentals[_tokenId].tenant == msg.sender, "Only the current tenant can call this function.");
        _;
    }

    function rent(uint _rentalDuration, uint _rentalPrice) external {
        require(_rentalDuration > 0, "Rental duration should be greater than zero.");
        require(_rentalPrice > 0, "Rental price should be greater than zero.");

        uint newTokenId = tokenIdCounter;
        tokenIdCounter++;

        nftContract.safeTransferFrom(owner, msg.sender, newTokenId);

        rentals[newTokenId] = Rental(
            msg.sender,
            _rentalDuration,
            _rentalPrice,
            block.timestamp,
            0,
            0,
            newTokenId,
            0
        );

        emit NFTTransferred(owner, msg.sender, newTokenId);
    }

    function endRental(uint _tokenId) external onlyOwner {
        Rental storage rental = rentals[_tokenId];
        require(rental.tenant != address(0), "The property is not currently rented.");

        uint rentalDurationInSeconds = rental.rentalDuration * 1 days;
        require(block.timestamp >= rental.rentalStartDate + rentalDurationInSeconds, "The rental period has not ended yet.");

        nftContract.safeTransferFrom(rental.tenant, owner, rental.tokenId);
        delete rentals[_tokenId];

        emit NFTTransferred(rental.tenant, owner, rental.tokenId);
    }

    function updateRentalDuration(uint _tokenId, uint _rentalDuration) external onlyOwner {
        require(_rentalDuration > 0, "Rental duration should be greater than zero.");

        Rental storage rental = rentals[_tokenId];
        require(rental.tenant != address(0), "Invalid tokenId or the property is not currently rented.");

        rental.rentalDuration = _rentalDuration;

        emit RentalDurationUpdated(_tokenId, _rentalDuration);
    }

    function updateRentalPrice(uint _tokenId, uint _rentalPrice) external onlyOwner {
        require(_rentalPrice > 0, "Rental price should be greater than zero.");

        Rental storage rental = rentals[_tokenId];
        require(rental.tenant != address(0), "Invalid tokenId or the property is not currently rented.");

        rental.rentalPrice = _rentalPrice;

        emit RentalPriceUpdated(_tokenId, _rentalPrice);
    }

    function updateTenant(uint _tokenId, address _newTenant) external onlyCurrentTenant(_tokenId) {
        Rental storage rental = rentals[_tokenId];
        require(_newTenant != address(0), "Invalid tenant address.");

        rental.tenant = _newTenant;

        emit TenantUpdated(_tokenId, msg.sender, _newTenant);
    }

    function extendRental(uint _tokenId) external {
        Rental storage rental = rentals[_tokenId];
        require(rental.tenant == msg.sender, "Only the tenant can extend the rental.");

        uint rentalDurationInSeconds = rental.rentalDuration * 1 days;
        uint rentalEndDate = rental.rentalStartDate + rentalDurationInSeconds;
        require(block.timestamp < rentalEndDate, "The rental period has already ended.");

        require(rental.extensionCount < 3, "Maximum number of rental extensions reached.");

        rental.rentalDuration += extensionPeriod / (1 days);
        rental.extensionCount++;

        emit RentalExtended(_tokenId, rental.extensionCount);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function withdrawFunds() external onlyOwner {
        uint contractBalance = address(this).balance;
        require(contractBalance > 0, "Contract balance is zero.");
        
        payable(owner).transfer(contractBalance);
    }
}
