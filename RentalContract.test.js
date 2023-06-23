const { ethers } = require("hardhat");

describe("RentalContract", function () {
  let rentalContract;
  let nftContract;
  let owner;
  let tenant;
  let rentalDuration = 15; // Duración de alquiler de 15 días
  let rentalPrice = ethers.utils.parseEther("0.5"); // Precio de alquiler de 0.5 ETH

  beforeEach(async function () {
    [owner, tenant] = await ethers.getSigners();

    const RentalContract = await ethers.getContractFactory("RentalContract");
    rentalContract = await RentalContract.deploy(
      nftContract.address,
      7 * 24 * 60 * 60, // 1 semana en segundos
      3 // Máximo 3 pagos fuera de plazo permitidos
    );
  });

  it("should rent a property", async function () {
    await nftContract.approve(rentalContract.address, tokenId);
    const rentTx = await rentalContract.rent(rentalDuration, rentalPrice);
    await rentTx.wait();

    const rental = await rentalContract.rentals(tokenId);
    expect(rental.tenant).to.equal(tenant.address);
    expect(rental.rentalDuration).to.equal(rentalDuration);
    expect(rental.rentalPrice).to.equal(rentalPrice);
    expect(rental.rentalStartDate).to.be.above(0);
    expect(rental.lastPaymentTimestamp).to.equal(0);
    expect(rental.extensionCount).to.equal(0);
    expect(rental.latePayments).to.equal(0);
  });

  it("should end a rental", async function () {
    await nftContract.approve(rentalContract.address, tokenId);
    await rentalContract.rent(rentalDuration, rentalPrice);

    const endRentalTx = await rentalContract.endRental(tokenId);
    await endRentalTx.wait();

    const rental = await rentalContract.rentals(tokenId);
    expect(rental.tenant).to.equal(ethers.constants.AddressZero);
  });

  it("should update rental duration", async function () {
    await nftContract.approve(rentalContract.address, tokenId);
    await rentalContract.rent(rentalDuration, rentalPrice);

    const newRentalDuration = 30; // Nueva duración de alquiler de 30 días
    const updateRentalDurationTx = await rentalContract.updateRentalDuration(tokenId, newRentalDuration);
    await updateRentalDurationTx.wait();

    const rental = await rentalContract.rentals(tokenId);
    expect(rental.rentalDuration).to.equal(newRentalDuration);
  });

  it("should update rental price", async function () {
    await nftContract.approve(rentalContract.address, tokenId);
    await rentalContract.rent(rentalDuration, rentalPrice);

    const newRentalPrice = ethers.utils.parseEther("1.0"); // Nuevo precio de alquiler de 1 ETH
    const updateRentalPriceTx = await rentalContract.updateRentalPrice(tokenId, newRentalPrice);
    await updateRentalPriceTx.wait();

    const rental = await rentalContract.rentals(tokenId);
    expect(rental.rentalPrice).to.equal(newRentalPrice);
  });

  it("should update tenant", async function () {
    await nftContract.approve(rentalContract.address, tokenId);
    await rentalContract.rent(rentalDuration, rentalPrice);

    const newTenant = ethers.utils.getAddress("0x1234567890123456789012345678901234567890");
    const updateTenantTx = await rentalContract.connect(tenant).updateTenant(tokenId, newTenant);
    await updateTenantTx.wait();

    const rental = await rentalContract.rentals(tokenId);
    expect(rental.tenant).to.equal(newTenant);
  });

  it("should extend rental", async function () {
    await nftContract.approve(rentalContract.address, tokenId);
    await rentalContract.rent(rentalDuration, rentalPrice);

    const extendRentalTx = await rentalContract.connect(tenant).extendRental(tokenId);
    await extendRentalTx.wait();

    const rental = await rentalContract.rentals(tokenId);
    expect(rental.rentalDuration).to.equal(rentalDuration + 7); // Duración de alquiler extendida en 7 días
    expect(rental.extensionCount).to.equal(1);
  });
});
