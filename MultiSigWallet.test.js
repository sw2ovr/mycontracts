// Importa los módulos necesarios de Hardhat
import { ethers } from "hardhat";
import { Signer } from "ethers";
import { expect } from "chai";

describe("MultisigContract", function () {
  let multisigContract;
  let owner;
  let approver1;
  let approver2;
  let approver3;

  beforeEach(async function () {
    // Obtiene las cuentas de prueba
    [owner, approver1, approver2, approver3] = await ethers.getSigners();

    // Despliega el contrato Multisig
    const MultisigContract = await ethers.getContractFactory("MultisigContract");
    multisigContract = await MultisigContract.deploy([approver1.address, approver2.address], 2);
    await multisigContract.deployed();
  });

  it("should allow transfer of Ether when approved by approvers", async function () {
    const recipient = ethers.utils.getAddress("0x123...");

    // Transfiere Ether desde el contrato
    await multisigContract.transferEther(recipient, ethers.utils.parseEther("1.0"));

    // Verifica el saldo del destinatario
    const recipientBalance = await ethers.provider.getBalance(recipient);
    expect(recipientBalance).to.equal(ethers.utils.parseEther("1.0"));
  });

  it("should allow transfer of ERC20 tokens when approved by approvers", async function () {
    const Token = await ethers.getContractFactory("YourERC20Token");
    const token = await Token.deploy(); // Despliega tu contrato ERC20 de prueba
    await token.deployed();

    const recipient = ethers.utils.getAddress("0x123...");
    const amount = ethers.utils.parseUnits("1000", 18);

    // Transfiere tokens ERC20 desde el contrato
    await token.transfer(multisigContract.address, amount);
    await multisigContract.transferERC20(token.address, recipient, amount);

    // Verifica el saldo del destinatario
    const recipientBalance = await token.balanceOf(recipient);
    expect(recipientBalance).to.equal(amount);
  });

  it("should allow transfer of ERC721 tokens when approved by approvers", async function () {
    const Token = await ethers.getContractFactory("YourERC721Token");
    const token = await Token.deploy(); // Despliega tu contrato ERC721 de prueba
    await token.deployed();

    const recipient = ethers.utils.getAddress("0x123...");
    const tokenId = 1;

    // Transfiere token ERC721 desde el contrato
    await token.transferFrom(owner.address, multisigContract.address, tokenId);
    await multisigContract.transferERC721(token.address, recipient, tokenId);

    // Verifica la propiedad del token por parte del destinatario
    const ownerOfToken = await token.ownerOf(tokenId);
    expect(ownerOfToken).to.equal(recipient);
  });

  it("should not allow transfer when signature threshold is not met", async function () {
    const recipient = ethers.utils.getAddress("0x123...");

    // Transfiere Ether desde el contrato
    await expect(
      multisigContract.connect(approver1).transferEther(recipient, ethers.utils.parseEther("1.0"))
    ).to.be.revertedWith("Transfer not allowed yet.");

    // Transfiere tokens ERC20 desde el contrato
    const Token = await ethers.getContractFactory("YourERC20Token");
    const token = await Token.deploy(); // Despliega tu contrato ERC20 de prueba
    await token.deployed();

    await token.transfer(multisigContract.address, ethers.utils.parseUnits("1000", 18));

    await expect(
      multisigContract.connect(approver1).transferERC20(token.address, recipient, ethers.utils.parseUnits("500", 18))
    ).to.be.revertedWith("Transfer not allowed yet.");

    // Transfiere token ERC721 desde el contrato
    const NFT = await ethers.getContractFactory("YourERC721Token");
    const nft = await NFT.deploy(); // Despliega tu contrato ERC721 de prueba
    await nft.deployed();

    await nft.transferFrom(owner.address, multisigContract.address, 1);

    await expect(
      multisigContract.connect(approver1).transferERC721(nft.address, recipient, 1)
    ).to.be.revertedWith("Transfer not allowed yet.");
  });

  it("should not allow transfer if contract balance or token balance is insufficient", async function () {
    const recipient = ethers.utils.getAddress("0x123...");

    // Transfiere Ether desde el contrato
    await expect(
      multisigContract.transferEther(recipient, ethers.utils.parseEther("1.0"))
    ).to.be.revertedWith("Insufficient contract balance.");

    // Transfiere tokens ERC20 desde el contrato
    const Token = await ethers.getContractFactory("YourERC20Token");
    const token = await Token.deploy(); // Despliega tu contrato ERC20 de prueba
    await token.deployed();

    await expect(
      multisigContract.transferERC20(token.address, recipient, ethers.utils.parseUnits("1000", 18))
    ).to.be.revertedWith("Insufficient token balance.");
  });

  it("should not allow removal of contract owner or violation of signature threshold", async function () {
    // Intenta eliminar al propietario como aprobador
    await expect(
      multisigContract.removeApprover(owner.address)
    ).to.be.revertedWith("Cannot remove contract owner.");

    // Intenta eliminar aprobadores cuando esto viola el umbral de firma
    await expect(
      multisigContract.removeApprover(approver1.address)
    ).to.be.revertedWith("Cannot remove approver. Signature threshold will be violated.");
  });

  it("should allow changing the signature threshold by the contract owner", async function () {
    // Cambia el umbral de firma
    await multisigContract.changeSignatureThreshold(3);

    // Verifica que el umbral de firma se haya actualizado correctamente
    const newThreshold = await multisigContract.signatureThreshold();
    expect(newThreshold).to.equal(3);
  });


});
