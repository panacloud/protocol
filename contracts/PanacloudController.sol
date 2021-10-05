// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PanaCoin.sol";
import "./APIIdeaNFT.sol";
import "./PlatformGoverner.sol";
import "./PanaFactory.sol";
import "./Timelock.sol";

// Central Point for all the contract to initialize
contract PanacloudController is Ownable  {

    function initialize(address _panacoin, address _apiIdeaNFT, address _panaGoverner, address _panaFactory, address _timelock) public onlyOwner {
        //PanaCoin panacoin = PanaCoin(_panacoin);
        //Timelock timelock = Timelock(_timelock);
        //APIIdeaNFT apiIdeaNFT = APIIdeaNFT(_apiIdeaNFT);
        PlatformGoverner panacloudGoverner = PlatformGoverner(_panaGoverner);
        PanaFactory panaFactory = PanaFactory(_panaFactory);
        panaFactory.initialize(_panacoin, _apiIdeaNFT);
        panacloudGoverner.initialize(_panaFactory, _timelock, _panacoin);


    }
}