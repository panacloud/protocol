import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RS_SFT is ERC1155 {

  //for now it works with only one NFT

    IERC20 dai;
        
    using SafeMath for uint256;
    
    address[] investors;
    address panaCloud;
    address apiDev;
    
    constructor(address _daiAddress,address _panaCloudAdd, address _devAdd ,string memory _baseUri) ERC1155(_baseUri) public{
        dai = IERC20(_daiAddress);
        panaCloud = _panaCloudAdd;
        apiDev = _devAdd;
    }
    
    function radeemNFT(uint amount) public{
        require(amount == 1*10**18,"ERROR: Enter 1 DAI");
        require(dai.balanceOf(_msgSender()) >= amount, "ERROR: not enough balance");
        
        //approve dai contract from front end
        dai.transferFrom(_msgSender(),address(this),amount);
        
        investors.push(msg.sender);
        
        _mint(_msgSender(),0,100,"");
        
        distributeRevenue(amount);
    }
    
    function distributeRevenue(uint256 amount) internal {
        uint256 investorsAmount = amount.mul(10).div(100);
        uint256 panaCloudAmount = amount.mul(5).div(100);
        uint256 apiDevAmount = amount.mul(85).div(100);
        investorsAmount = investorsAmount.div(investors.length);
        
        for(uint256 i=0; i<investors.length; i++) {
            dai.transfer(investors[i],investorsAmount);
        }
        dai.transfer(panaCloud,panaCloudAmount);
        dai.transfer(apiDev,apiDevAmount);

    }
}