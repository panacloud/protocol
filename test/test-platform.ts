import { ethers, waffle } from "hardhat";
import { expect } from "chai";
import { Address } from "cluster";
import { APIToken, APIToken__factory, DAIToken, DAIToken__factory, PanacloudPlatform, PanacloudPlatform__factory } from "../typechain";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber } from "@ethersproject/bignumber";

// DAI rinkeby address
// 0x5592ec0cfb4dbc12d3ab100b257153436a1f0fea

// DAI Mainnet address
// 0x6b175474e89094c44da98b954eedeac495271d0f
interface Invoice {
    apiToken: string; // API Token Address
    invoiceNumber: BigNumber;
    dueDate: BigNumber;
    invoiceMonth: BigNumber; // From 1 to 12
    totalAmount: BigNumber;
    invoicePayee: string; // API Subscriber Address
  }

describe("Panacloud Platform Test", function () {
    
    let panacloudPlatform:PanacloudPlatform;
    let daiToken:DAIToken;
    let apiTokenAddress:string;
    let apiDAOAddress:string;
    let apiId:string;

    before(async()=>{
        const [owner, addr1, addr2, addr3, addr4, addr5]: SignerWithAddress[] = await ethers.getSigners();
        
        const DAIToken:DAIToken__factory = await ethers.getContractFactory("DAIToken");
        daiToken = await DAIToken.deploy();
        await daiToken.deployed();
        
        const PanacloudPlatform:PanacloudPlatform__factory = await ethers.getContractFactory("PanacloudPlatform");
        panacloudPlatform = await PanacloudPlatform.deploy();
        await panacloudPlatform.deployed();

        await panacloudPlatform.initialize(addr5.address,daiToken.address,owner.address);

        await daiToken.mint(addr1.address, ethers.utils.parseEther("10000"));

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

        const addr1DaiBalance = await daiToken.balanceOf(addr1.address);
        //console.log("addr1DaiBalance = ",addr1DaiBalance.toNumber());

        expect(await daiToken.connect(addr1).approve(panacloudPlatform.address, ethers.utils.parseEther("400"))).to.be.ok;

        expect(await panacloudPlatform.connect(addr1).payInvoice(owner.address, apiDAOAddress,{
            apiToken: apiTokenAddress,
            dueDate: Date.now(),
            invoiceMonth: 1,
            invoiceNumber:123,
            totalAmount: ethers.utils.parseEther("300"),
            invoicePayee: owner.address
        })).to.be.ok;

        expect(await panacloudPlatform.connect(addr1).payInvoice(owner.address, apiDAOAddress,{
            apiToken: apiTokenAddress,
            dueDate: Date.now(),
            invoiceMonth: 2,
            invoiceNumber:321,
            totalAmount: ethers.utils.parseEther("100"),
            invoicePayee: owner.address
        })).to.be.ok;
    });

    it("API Dev Earing and Details properly updated", async function () {
        const [owner, addr1]: SignerWithAddress[] = await ethers.getSigners();
        const devEarningDetails = await panacloudPlatform.getDevEarnings(owner.address);
        //console.log("Earning details = ",devEarningDetails);
        expect(devEarningDetails[0].toString()).to.be.equal(ethers.utils.parseEther("380"));
        expect(devEarningDetails[1].toString()).to.be.equal(ethers.utils.parseEther("380"));
        expect(devEarningDetails[2].toString()).to.be.equal(ethers.utils.parseEther("0"));
        expect(devEarningDetails[3][0].apiDao).to.be.equal(apiDAOAddress);
        expect(devEarningDetails[3][0].apiToken).to.be.equal(apiTokenAddress);
    });

    it("API Invoices properly updated for user", async function () {
        const [owner, addr1]: SignerWithAddress[] = await ethers.getSigners();
        const invoices:Invoice[] = await panacloudPlatform.getAPIInvoices(owner.address,apiTokenAddress);
        console.log("invoices = ",invoices);
        expect(invoices.length).to.be.equal(2);
        expect(invoices[0].apiToken).to.be.equal(apiTokenAddress);
        expect(invoices[0].totalAmount).to.be.equal(ethers.utils.parseEther("300"));
        expect(invoices[0].invoiceMonth).to.be.equal(1);

        expect(invoices[1].apiToken).to.be.equal(apiTokenAddress);
        expect(invoices[1].totalAmount).to.be.equal(ethers.utils.parseEther("100"));
        expect(invoices[1].invoiceMonth).to.be.equal(2);
    });

    it("Withdraw should fail when called by Non-Owner account", async function () {
        const [owner, addr1]: SignerWithAddress[] = await ethers.getSigners();
        await expect(panacloudPlatform.connect(addr1).withdraw()).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Withdraw should transfer DAI to owner account", async function () {
        const [owner, addr1]: SignerWithAddress[] = await ethers.getSigners();
        expect(await  panacloudPlatform.connect(owner).withdraw()).to.be.ok;
        const ownerDaiBalance = await daiToken.balanceOf(owner.address);
        //console.log("Owner Dai Balance = ",ownerDaiBalance.toString());
        expect(ownerDaiBalance).to.be.equal(ethers.utils.parseEther("10400"));
    });

});