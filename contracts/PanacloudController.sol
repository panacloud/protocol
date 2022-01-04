// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./governance/PanaCoin.sol";
import "./APINFT.sol";
import "./governance/PlatformGovernor.sol";
import "./PanaFactory.sol";
import "./governance/Timelock.sol";

// Central Point for all the contract to initialize
contract PanacloudController is Ownable  {

    function initialize(address _panacoin, address _apiIdeaNFT, address _panacloudPlatform, 
                        address _panaGovernor, address _panaFactory, address _timelock, 
                        address _apiTokenFactoryAddress, address _daoFactoryAddress) public onlyOwner {
        //PanaCoin panacoin = PanaCoin(_panacoin);
        //Timelock timelock = Timelock(_timelock);
        //APIIdeaNFT apiIdeaNFT = APIIdeaNFT(_apiIdeaNFT);
        PlatformGovernor panacloudGovernor = PlatformGovernor(_panaGovernor);
        PanaFactory panaFactory = PanaFactory(_panaFactory);
        panaFactory.initialize(_panacoin, _apiIdeaNFT,_panacloudPlatform, _apiTokenFactoryAddress, _daoFactoryAddress);
        //panacloudGovernor.initialize(_panaFactory, _timelock, _panacoin);
        panacloudGovernor.initialize(_timelock, _panacoin, 1, 17280, 10000000e18);


    }
}