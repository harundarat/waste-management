import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat"
import { WasteManagement } from "../typechain-types";
import chai from "chai";

const {expect} = chai;

describe("Waste Management Contract", function() {

    let owner: HardhatEthersSigner;
    let notOwner: HardhatEthersSigner;
    let wasteManagement: WasteManagement;
    let dummyAdded = [0, "Purbalingga", 300];

    beforeEach(async () => {
        //get signers
        const accounts = await ethers.getSigners();
        owner = accounts[0];
        notOwner = accounts[1];

        // Deploy Contracts
        wasteManagement = await (await ethers.getContractFactory("WasteManagement"))
        .connect(owner)
        .deploy(owner);

        // Add dummy
        const addDummy = await wasteManagement.connect(owner).addWaste(0, "Purbalingga", 300);
    });

    describe("Read Function", function() {

        it("getWaste(): Return waste data by id",async () => {
            const waste = await wasteManagement.getWaste(0);
            const wasteData = [Number(waste[1]), waste[2], waste[3]];

            expect((wasteData[0], wasteData[1], wasteData[2])).to.be.equals((dummyAdded[0], dummyAdded[1], dummyAdded[2]));
        });

        it("getWasteStorage(): Return waste storage data by waste type",async () => {
            const wasteStorage = await wasteManagement.getWasteStorage(0);
            const storedWaste = wasteStorage[0];

            expect(storedWaste).to.be.equals(dummyAdded[2]);
        });

    });

    describe("Write Function", function() {
        it("addWaste(): except owner can not add waste",async () => {
            await expect(wasteManagement.connect(notOwner).addWaste(1, "Purwokerto", 500)).to.be.reverted;
        });

        it("wasteTreatment(): sent data from owner succesful",async () => {
            const weightTarget = 200;
            const wasteTreatment = await wasteManagement.connect(owner).wasteTreatment(0, weightTarget);
            await wasteTreatment.wait();

            const wasteData = await wasteManagement.getWasteStorage(0);
            const wasteTransformed = wasteData[1];

            expect(wasteTransformed).to.be.equals(weightTarget);
        });

        it("wasteTreatment(): target more than available storage will reverted",async () => {
            await expect(wasteManagement.connect(owner).wasteTreatment(0, 9999)).to.be.revertedWith("Target waste exceed the available waste in the storage");
        });

        it("moveWaste(): owner distributes waste will successful",async () => {
            const wasteTransformed = 200;
            const wasteMoved = 150;

            const wasteTreatment = await wasteManagement.connect(owner).wasteTreatment(0, wasteTransformed);
            await wasteTreatment.wait();
            const moveWaste = await wasteManagement.connect(owner).moveWaste(0, wasteMoved); 
            await moveWaste.wait();

            const wasteStorageData = await wasteManagement.getWasteStorage(0);
            const moved = wasteStorageData[2];

            expect(moved).to.be.equals(wasteMoved);
        });

        it("moveWaste(): target more than available storage will reverted", async () => {
            await expect(wasteManagement.connect(owner).moveWaste(0, 9999)).to.be.revertedWith("Target waste exceed the available waste in the storage");
        })
    });
})