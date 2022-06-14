const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting", function () {
  it("test", async function () {
    const [owner] = await ethers.getSigners();

    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.deployed();

    voting.addVoting();

    expect(await voting.ballotInfoGetCandidates(1)).to.deep.equal([owner.address, owner.address, owner.address]);
    expect(await voting.ballotInfoIsOpen(1)).to.equal(true);

    expect(await voting.ballotInfoStartTime(1)).to.not.equal(0);
    expect(await voting.ballotInfoDeposit(1)).to.equal(0);
  });
});
