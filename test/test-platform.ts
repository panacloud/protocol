import { ethers, waffle } from "hardhat";
import { expect } from "chai";
import { Address } from "cluster";
import { APIToken, APIToken__factory, PanacloudPlatform, PanacloudPlatform__factory } from "../typechain";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber } from "@ethersproject/bignumber";


describe("Panacloud Platform Test", function () {
    
    let panacloudPlatform:PanacloudPlatform;
    let apiTokenAddress:string;
    let apiDAOAddress:string;
    let apiId:string;

    before(async()=>{
        const [owner, addr1, addr2,addr3,addr4,addr5]: SignerWithAddress[] = await ethers.getSigners();
        const PanacloudPlatform:PanacloudPlatform__factory = await ethers.getContractFactory("PanacloudPlatform");
        panacloudPlatform = await PanacloudPlatform.deploy();
        await panacloudPlatform.deployed();
        // This is just for dummy testing, in actual we need contract addresses
        apiTokenAddress = addr3.address;
        apiDAOAddress = addr4.address;
        apiId = "demoapi";
    });

    it("API DAO should be created successfully", async function () {
        const [owner, addr1, addr2]: SignerWithAddress[] = await ethers.getSigners();
        
        expect(await panacloudPlatform.connect(owner).apiDAOCreated(owner.address,apiId,apiTokenAddress,apiDAOAddress)).to.be.ok;

    });


    it("2 Invoice Payment Made successfully", async function () {
        const [owner, addr1, addr2]: SignerWithAddress[] = await ethers.getSigners();
        expect(await panacloudPlatform.connect(addr1).payInvoice(owner.address, apiDAOAddress,{
            apiToken: apiTokenAddress,
            dueDate: Date.now(),
            invoiceMonth: 1,
            invoiceNumber:123,
            totalAmount: 300,
            invoicePayee: owner.address
        })).to.be.ok;

        expect(await panacloudPlatform.connect(addr1).payInvoice(owner.address, apiDAOAddress,{
            apiToken: apiTokenAddress,
            dueDate: Date.now(),
            invoiceMonth: 2,
            invoiceNumber:321,
            totalAmount: 100,
            invoicePayee: owner.address
        })).to.be.ok;
    });

    it("Test API Dev Details", async function () {
        const [owner, addr1]: SignerWithAddress[] = await ethers.getSigners();
        const devEarningDetails = await panacloudPlatform.getDevEarnings(owner.address);
        console.log("Earning details = ",devEarningDetails);
        expect(devEarningDetails[0].toNumber()).to.be.equal(400);
        expect(devEarningDetails[1].toNumber()).to.be.equal(400);
        expect(devEarningDetails[2].toNumber()).to.be.equal(0);
        //expect(devEarningDetails[0].toNumber()).to.be.equal(400);
    });

});