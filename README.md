# mycontracts list

This repository contains Solidity smart contracts along with their corresponding Hardhat tests.



- **MultiSigWallet**

The MultisigContract is a smart contract that facilitates multi-signature transfers of Ether, ERC20 tokens, and ERC721 tokens. It requires a predefined number of approved addresses to collectively authorize a transfer.

Features:
- Multi-signature transfers: Requires a specified number of approved addresses to sign off on transfers.
- Transfer locking: Implements a transfer lock time period to restrict frequent transfers.
- Ether transfers: Allows approved addresses to transfer Ether from the contract to a specified recipient.
- ERC20 token transfers: Allows approved addresses to transfer ERC20 tokens from the contract to a specified recipient.
- ERC721 token transfers: Allows approved addresses to transfer ERC721 tokens from the contract to a specified recipient.
- Signature threshold modification: Allows the contract owner to change the required signature threshold.
- Approver management: Allows the contract owner to add or remove approved addresses.

This contract is built on the Ethereum blockchain using Solidity and follows the ERC20 and ERC721 token standards. It utilizes the OpenZeppelin library for the token interfaces.


- **Rental Contract**

The RentalContract is a smart contract that enables the rental of ERC721 tokens representing properties or assets. It allows tenants to rent properties from the contract owner, with features such as rental duration, rental price, rental extension, and late payment tracking.

Features:
- Property rental: Allows tenants to rent ERC721 tokens representing properties from the contract owner.
- Rental duration and price: Sets the duration and price of the rental period for each property.
- Rental extension: Allows tenants to extend the rental period within a specified limit.
- Late payment tracking: Tracks the number of late payments made by the tenant.
- Property transfer: Transfers the ERC721 token to the tenant when a rental is initiated and back to the owner when the rental period ends.
- Rental updates: Enables the contract owner to update the rental duration, rental price, and tenant address.
- Withdrawal of funds: Allows the contract owner to withdraw the contract's accumulated rental funds.

This contract follows the ERC721 token standard and uses the OpenZeppelin library for safe transfers. It implements the IERC721Receiver interface to handle ERC721 token reception.

-

TODO:

- MyEscrow
- ERC-20
- ERC-721 (w/ royalties & paymentsplitter)
- Oranges