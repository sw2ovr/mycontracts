// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SimpleHospital
 * @dev Contract for managing hospital operations.
 */
contract SimpleHospital is ERC721, AccessControl {
    MedicalRecords private medicalRecordsContract;

    uint256 public tokenPrice;
    uint256 public nextTokenId;
    mapping(address => string) private walletToDNI;
    mapping(address => string) private walletToRole;

    constructor(uint256 price, address medicalRecordsAddress) ERC721("SimpleHospitalToken", "SHT") {
        tokenPrice = price;
        nextTokenId = 1;

        medicalRecordsContract = MedicalRecords(medicalRecordsAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Buys a hospital token.
     * @param dni The DNI of the patient.
     */
    function buyToken(string memory dni) external payable {
        require(msg.value == tokenPrice, "Incorrect token price");
        _safeMint(msg.sender, nextTokenId);
        walletToDNI[msg.sender] = dni;
        nextTokenId++;
    }

    /**
     * @dev Retrieves the DNI associated with a wallet address.
     * @param wallet The wallet address.
     * @return The DNI.
     */
    function getDNI(address wallet) external view returns (string memory) {
        return walletToDNI[wallet];
    }

    /**
     * @dev Retrieves a medical record by token ID.
     * @param tokenId The token ID of the medical record.
     * @return The medical record details.
     */
    function getRecord(uint256 tokenId) external view returns (MedicalRecords.MedicalRecord memory) {
        return medicalRecordsContract.getMedicalRecord(tokenId);
    }

    /**
     * @dev Sets the price of a hospital token.
     * @param price The token price.
     */
    function setTokenPrice(uint256 price) external onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenPrice = price;
    }

    /**
     * @dev Withdraws the contract funds.
     */
    function withdrawFunds() external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    /**
     * @dev Adds a medical record to the MedicalRecords contract.
     * @param tokenId The token ID of the medical record.
     * @param timestamp The timestamp of the medical record.
     * @param diagnosis The diagnosis of the medical record.
     * @param treatment The treatment of the medical record.
     * @param price The price of the treatment.
     */
    function addMedicalRecord(
        uint256 tokenId,
        uint256 timestamp,
        string memory diagnosis,
        string memory treatment,
        uint256 price
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        medicalRecordsContract.addMedicalRecord(timestamp, diagnosis, treatment, price);
    }

    /**
     * @dev Pays for medical attention.
     * @param tokenId The token ID of the medical record.
     * @param amount The amount to pay.
     */
    function payMedicalAttention(uint256 tokenId, uint256 amount) external payable {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(SANIT_ROLE, msg.sender) || ownerOf(tokenId) == msg.sender,
            "Only admins, sanit, or token owner can pay for medical attention"
        );
        require(msg.value == amount, "Incorrect payment amount");

        address payable contractOwner = payable(owner());
        contractOwner.transfer(msg.value);

        medicalRecordsContract.updateRemainingPayment(tokenId, amount);
        if (medicalRecordsContract.getMedicalRecord(tokenId).remainingPayment == 0) {
            medicalRecordsContract.setPaymentStatus(tokenId, true);
        }
    }

    /**
     * @dev Adds the SANIT role to a wallet address.
     * @param wallet The wallet address.
     */
    function addSanitRole(address wallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        walletToRole[wallet] = "SANIT";
    }

    /**
     * @dev Adds the ADMIN role to a wallet address.
     * @param wallet The wallet address.
     */
    function addAdminRole(address wallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(DEFAULT_ADMIN_ROLE, wallet);
    }

    /**
     * @dev Revokes the ADMIN role from a wallet address.
     * @param wallet The wallet address.
     */
    function revokeAdminRole(address wallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(DEFAULT_ADMIN_ROLE, wallet);
    }

    /**
     * @dev Revokes the SANIT role from a wallet address.
     * @param wallet The wallet address.
     */
    function revokeSanitRole(address wallet) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || owner() == msg.sender,
            "Only admins or contract owner can revoke sanit role"
        );
        delete walletToRole[wallet];
    }
}
