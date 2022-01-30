// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract PanacloudPlatform is Ownable {

    struct UserDAODetails {
        address apiDao;
        address apiToken;
    }

    struct Invoice {
        address apiToken;
        uint256 invoiceNumber;
        uint256 dueDate;
        uint256 invoiceMonth;
        uint256 totalAmount;
        address invoicePayee;
    }

    struct APIDevDetails {
        address apiDev;
        uint256 totalEarned;
        uint256 totalClaimable;
        uint256 totalClaimed;
        // key: apiToken , value invoices of apiToken
        mapping(address => Invoice[]) invoices;
        mapping(address => Invoice[]) payeeInvoices;
        // key: userAddress ,  key apiToken value invoices of apiToken
        //mapping(address=> mapping(address=>Invoice[])) userAPIInvoices;
    }
    
    uint256 public panacloudShareInAPI = 5;
    uint256 public apiIdeaProposerShare = 1;

    // Key DAO address value Developer address
    mapping(address => address) private apiDAOToUserMapping;
    
    mapping(address => APIDevDetails) private apiDevDetails;

    // Mapping for developer to list of owned Dao and Tokens
    // key:develper address, value: Array of struct holding Dao and Token address
    mapping(address => UserDAODetails[]) ownedDAOs;

    address public paymentSplitterAddress;

    ERC20 public DAI;
    address public treasuryAddress;

    event APIDAOCreated(address daoCreator, string apiId, address apiToken, address apiDao);
    event InvoicePaid(address daoCreator, address invoicePayee, address apiToken, address apiDao, uint256 invoiceNumber, uint256 invoiceAmount);

    constructor() {
        console.log("Platform Launched");
    }

    function initialize(address _paymentSplitterAddress, address _daiAddress, address _treasuryAddress) public onlyOwner {
        paymentSplitterAddress = _paymentSplitterAddress;
        DAI = ERC20(_daiAddress);
        treasuryAddress = _treasuryAddress;
    }

    function setPanacloudAPIShare(uint256 newShare) public onlyOwner {
        require(newShare > 1, "Platform Share must be greater than 1");
        require(newShare <= 50, "Platform Share cannot be greater than 50");
        panacloudShareInAPI = newShare;
    }

    function setAPIIdeaProposerShare(uint256 newShare) public onlyOwner {
        require(newShare > 0, "Idea Proposer Share must be greater than 0");
        require(newShare <= 10, "Idea Proposer Share cannot be greater than 10");
        apiIdeaProposerShare = newShare;
    }

    function apiDAOCreated(address owner, string memory apiId, address apiToken, address apiDao) public {
        apiDAOToUserMapping[apiDao] = owner;
        ownedDAOs[owner].push(UserDAODetails(apiDao,apiToken));
        APIDevDetails storage _devDetails = apiDevDetails[owner];
        if(_devDetails.apiDev == address(0)) {
            _devDetails.apiDev = owner;
        }
        emit APIDAOCreated(owner, apiId, apiDao, apiToken);
    }

    function getDAOAndTokenForOwner(address owner) public view returns (UserDAODetails[] memory userAllDAOs){
        return ownedDAOs[owner];
    }

    function payInvoice(address _apiDev, address _apiDao, Invoice memory _invoice) public {
        require(apiDAOToUserMapping[_apiDao] == _apiDev, "DAO does not belong to user");
        require(_apiDev != address(0), "API Dev NULL Address Provided");
        require(_invoice.apiToken != address(0), "API Token NULL Address Provided");
        require(_invoice.invoicePayee != address(0), "NULL Payee Address Provided");
        require(_invoice.totalAmount > 0, "Zero Amount Invoice");
        
        // TODO: need to transfer funds to treasure address
        DAI.transferFrom(msg.sender, address(this), _invoice.totalAmount);

        APIDevDetails storage _devDetails = apiDevDetails[_apiDev];
        uint256 devShare = _invoice.totalAmount - (_invoice.totalAmount * panacloudShareInAPI / 100);
        _devDetails.totalEarned += devShare;
        _devDetails.totalClaimable += devShare;
        _devDetails.invoices[_invoice.apiToken].push(_invoice);
        _devDetails.payeeInvoices[msg.sender].push(_invoice);
        emit InvoicePaid(_apiDev, msg.sender, _invoice.apiToken, _apiDao, _invoice.invoiceNumber, _invoice.totalAmount);
    }

    function getDevEarnings(address _apiDev) public view returns(uint256,uint256,uint256,UserDAODetails[] memory) {
        require(apiDevDetails[_apiDev].apiDev != address(0), "Invalid Dev Address");
        APIDevDetails storage _devDetails = apiDevDetails[_apiDev];
        return (_devDetails.totalEarned,_devDetails.totalClaimable,_devDetails.totalClaimed, ownedDAOs[_apiDev] );
    }

    function getAPIInvoices(address _apiDev,address _apiToken) public view returns(Invoice[] memory) {
        require(apiDevDetails[_apiDev].apiDev != address(0), "Invalid Dev Address");
        return apiDevDetails[_apiDev].invoices[_apiToken];
    }

    /*
    function withdraw() public onlyOwner {
        (bool sent, bytes memory data) = treasuryAddress.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw Ether");
    }*/

    function withdraw() public onlyOwner {
        DAI.transfer(msg.sender, DAI.balanceOf(address(this)));
    }

}