// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract PaymentSplitter is Context{
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 public _totalShares;
    uint256 public _totalReleased;
    uint256 public _totalRevenue;

    mapping(address => uint256) private _pointOne;
    mapping(address => uint256) private _unclaimedPayment;
    mapping(address => uint256) public _userInvestment;
    mapping(address => uint256) public _shares;
    mapping(address => uint256) public _released;
 
    address private DAIAddress = address(0xaD6D458402F60fD3Bd25163575031ACDce07538D);
    ERC20 private DAI =ERC20(DAIAddress);
   
    function _addPayee(address account, uint256 shares_) public {                        // this should be private making public for dev.
        require(account != address(0), "zero address");
        require(shares_ > 0, "no shares");
        require(_shares[account] == 0, "shares given");
        
        _pointOne[account]=_totalRevenue;
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        
        emit PayeeAdded(account, shares_);
    }

    function sendValue(address recipient, uint256 amount) internal {
        require(DAI.balanceOf(address(this)) >= amount, "insufficient balance");

        DAI.transfer(recipient,amount);
    }
    function release(address  account) public virtual {
        require(_shares[account] > 0 || _unclaimedPayment[account]>0, "no shares");
        require(DAI.balanceOf(address(this))>0,"no funds");

        uint256 totalReceived = _totalRevenue - _pointOne[account];
        uint256 payment = (totalReceived * _shares[account]) / _totalShares - _released[account];
        payment = payment + _unclaimedPayment[account];
    
        require(payment != 0, "payment not due");

        _released[account] = _released[account] + payment;
        _totalReleased = _totalReleased + payment;
        _unclaimedPayment[account]=0;

        sendValue(account, payment);
        
        emit PaymentReleased(account, payment);
    }

    function _subscribe(uint256 amount,uint256 _threshold)public returns(bool){
        require(DAI.allowance(_msgSender(),address(this))>=amount,"No allowance");
        
        _userInvestment[_msgSender()]=_userInvestment[_msgSender()]+amount;
        _totalRevenue = _totalRevenue + amount;
        
        if(_userInvestment[_msgSender()]%_threshold==0 && _shares[_msgSender()]==0){
            _addPayee(_msgSender(),1*10**18+_shares[_msgSender()]);
            DAI.transferFrom(_msgSender(),address(this),amount);
            return true;
        }
        else if(_userInvestment[_msgSender()]%_threshold==0 && _shares[_msgSender()]>0){
            _unclaimedPayment[_msgSender()]=unclaimedPayment(_msgSender());
            _pointOne[_msgSender()]=_totalRevenue;
            _shares[_msgSender()]=_shares[_msgSender()]+1*10**18;
            
            _totalShares=_totalShares+1*10**18;
            DAI.transferFrom(_msgSender(),address(this),amount);
           return true;
        }
        else{
            return false;
        }
        
         
    }

function unclaimedPayment(address account) public view returns(uint256 payment){
        uint256 totalReceived = _totalRevenue - _pointOne[account];
         payment = (totalReceived * _shares[account]) / _totalShares - _released[account];
         payment = payment + _unclaimedPayment[account];
         }

function beforeTransferCheck(address sender,address recipient, uint256 amount)public returns(bool){
        require(_shares[sender]>=amount,"invalid check");
        if(Address.isContract(recipient) && !Address.isContract(sender))
        {
        _unclaimedPayment[sender]=unclaimedPayment(sender);
        _pointOne[sender]=_totalRevenue;
        _shares[sender]=_shares[_msgSender()]-amount;
        _totalShares = _totalShares - amount;
        return true;
        }
        else if(Address.isContract(sender) && !Address.isContract(recipient)){
        _unclaimedPayment[recipient]=unclaimedPayment(recipient);
        _pointOne[recipient]=_totalRevenue;
        _shares[recipient]=_shares[recipient]+amount;
       _totalShares = _totalShares + amount;
        
        return true;
        }
        else if(Address.isContract(sender) && Address.isContract(recipient)){
            
        return true;
        }
        else{
        _unclaimedPayment[sender]=unclaimedPayment(sender);
        _pointOne[sender]=_totalRevenue;
        _shares[sender]=_shares[sender]-amount;

        _unclaimedPayment[recipient]=unclaimedPayment(recipient);
        _pointOne[recipient]=_totalRevenue;
        _shares[recipient]=_shares[recipient]+amount;
        return true;
        }
}
    
    
}