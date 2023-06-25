// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title MedicalRecords
 * @dev Contract for managing medical records.
 */
contract MedicalRecords is ERC721, AccessControl {
    struct MedicalRecord {
        uint256 tokenId;
        uint256 timestamp;
        string diagnosis;
        string treatment;
        uint256 price;
        uint256 remainingPayment;
        bool isPaid;
    }

    mapping(uint256 => MedicalRecord) private tokenIdToRecord;
    uint256 private nextTokenId;

    constructor() ERC721("MedicalRecords", "MR") {
        nextTokenId = 1;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Adds a new medical record to the contract.
     * @param timestamp The timestamp of the medical record.
     * @param diagnosis The diagnosis of the medical record.
     * @param treatment The treatment of the medical record.
     * @param price The price of the treatment.
     */
    function addMedicalRecord(
        uint256 timestamp,
        string memory diagnosis,
        string memory treatment,
        uint256 price
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 tokenId = nextTokenId;
        _safeMint(msg.sender, tokenId);
        tokenIdToRecord[tokenId] = MedicalRecord(tokenId, timestamp, diagnosis, treatment, price, price, false);
        nextTokenId++;
    }

    /**
     * @dev Retrieves a medical record by token ID.
     * @param tokenId The token ID of the medical record.
     * @return The medical record details.
     */
    function getMedicalRecord(uint256 tokenId) external view returns (MedicalRecord memory) {
        return tokenIdToRecord[tokenId];
    }

    /**
     * @dev Sets the payment status of a medical record.
     * @param tokenId The token ID of the medical record.
     * @param isPaid The payment status to set.
     */
    function setPaymentStatus(uint256 tokenId, bool isPaid) external onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenIdToRecord[tokenId].isPaid = isPaid;
    }

    /**
     * @dev Updates the remaining payment for a medical record.
     * @param tokenId The token ID of the medical record.
     * @param payment The payment amount to deduct.
     */
    function updateRemainingPayment(uint256 tokenId, uint256 payment) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(tokenIdToRecord[tokenId].isPaid == false, "Medical record already paid");
        require(tokenIdToRecord[tokenId].remainingPayment >= payment, "Invalid payment amount");
        tokenIdToRecord[tokenId].remainingPayment -= payment;
    }
}
