**Contract MedicalRecords**

The `MedicalRecords` contract is a smart contract that allows storing and managing patients' medical records. It utilizes the functionality of the ERC721 standard to represent each medical record as a non-fungible token. Each token is associated with a specific patient and contains detailed information about the diagnosis, treatment, and payment status.

The contract provides the following functions:

- `addMedicalRecord`: Allows the contract owner to add a new medical record. Each record is associated with a patient and a unique token is generated.
- `getMedicalRecord`: Allows retrieving detailed information about a medical record based on its token ID.
- `setPaymentStatus`: Allows updating the payment status of a medical record.
- Other auxiliary methods for interacting with the medical records.

**Contract SimpleHospital**

The `SimpleHospital` contract is a smart contract that acts as a management system for a hospital. It utilizes the functionality of the ERC721 standard to represent non-fungible tokens that represent the medical attention provided to patients. Each token is associated with a patient and contains basic information about the received medical attention.

The contract provides the following functions:

- `buyToken`: Allows patients to purchase a medical attention token by paying a specified price.
- `getDNI`: Allows retrieving the DNI associated with a wallet address.
- `getRecord`: Allows obtaining basic information about a medical record based on its token ID.
- `setTokenPrice`: Allows the contract owner to set the price of medical attention tokens.
- `withdrawFunds`: Allows the contract owner to withdraw accumulated funds from the contract.
- `addMedicalRecord`: Allows adding new medical records by calling the corresponding function in the MedicalRecords contract.
- `payMedicalAttention`: Allows making a payment for received medical attention and updating the payment status of the corresponding medical record.
- Methods for assigning and revoking administrator and sanitarian roles.

These contracts provide a robust and secure solution for storing and managing medical records in a decentralized environment, offering transparency and reliability in the handling of patients' medical information.
