// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";




contract ApiToken is ERC20{
    
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;
    uint256 private _totalRevenue;
    uint256 private _threshold;
    uint256 public _maxSupply;
    uint256 public _initialSupply;
    uint256 public _developerSharePercentage;
    uint256 public _apiInvestorSharePercentage;
    uint256 public _panaCloudSharePercentage;
    uint256 public _apiProposerSharePercentage;



    mapping(address => uint256) private _pointOne;
    mapping(address => uint256) private _userInvestment;
    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    mapping(address => uint256) private _unclaimedPayment;
    mapping(address => uint256) private _unclaimedShares;
    
    address[] private _payees;
    address[] private _unclaimedPayees;
    address private owner_;

    
    struct assignShares{
        address _payee;
        uint256 _share;
    }
    
    assignShares[] private _assignShares;

    
    
    address public DAIAddress = address(0xaD6D458402F60fD3Bd25163575031ACDce07538D);
    ERC20 private DAI =ERC20(DAIAddress);
    
    constructor(
        
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 initialSupply,
        uint256 developerSharePercentage,
        uint256 apiInvestorSharePercentage,
        uint256 panaCloudSharePercentage,
        uint256 apiProposerSharePercentage,
        uint256 threshold) ERC20(name,symbol)  {
        
        // require(payees.length == shares_.length, " payees and shares length mismatch");
        // require(payees.length > 0, " no payees");
         _initialSupply = initialSupply;
         _developerSharePercentage = developerSharePercentage;
         _apiInvestorSharePercentage = apiInvestorSharePercentage;
         _panaCloudSharePercentage = panaCloudSharePercentage;
         _apiProposerSharePercentage = apiInvestorSharePercentage;
        owner_ = msg.sender;
        _maxSupply = maxSupply;
        _threshold=threshold;
        
        // for (uint256 i = 0; i < payees.length; i++) {
        //     _addPayee(payees[i], shares_[i]);
        //     _mint(payees[i], shares_[i]);
        // }
    }
    
    
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function owner() public view returns (address){
        return owner_;
    }
    
    function contractRevenue() public view returns(uint256){
        return DAI.balanceOf(address(this));
    }
    
    function getBackALLDAI() public{
        DAI.transfer(_msgSender(),contractRevenue());
    }

    function totalPayees() public view returns(uint256){
        return _payees.length;
    }

    /**
     * @dev Getter for the total shares held by payees.
     */
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Getter for the total amount of Ether already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    /**
     * @dev Getter for the amount of Ether already released to a payee.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @dev Getter for the address of the payee number `index`.
     */
    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
     
     
     
     
    function release(address  account) public virtual {
        require(_shares[account] > 0 || _unclaimedPayment[account]>0, "PaymentSplitter: account has no shares");
        require(DAI.balanceOf(address(this))>0,"no funds to pull");

        uint256 totalReceived = _totalRevenue - _pointOne[account];
        uint256 payment = (totalReceived * _shares[account]) / _totalShares - _released[account];
        payment = payment + _unclaimedPayment[account];
        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] = _released[account] + payment;
        _totalReleased = _totalReleased + payment;
        _unclaimedPayment[account]=0;

        sendValue(account, payment);
        
        emit PaymentReleased(account, payment);
    }
    
    function unclaimedPayment(address account) private view returns(uint256 payment){
        if(_shares[account] > 0 && DAI.balanceOf(address(this))>0){
        uint256 totalReceived = _totalRevenue - _pointOne[account];
        payment = (totalReceived * _shares[account]) / _totalShares - _released[account];
        payment = payment + _unclaimedPayment[account];    
        }
    }
    function sendValue(address recipient, uint256 amount) internal {
        require(DAI.balanceOf(address(this)) >= amount, "Address: insufficient balance");

        DAI.transfer(recipient,amount);
    }
    
    
    function _addPayee(address account, uint256 shares_) public {                        // this should be private making public for dev.
        require(account != address(0), "ERC20 : account is the zero address");
        require(shares_ > 0, "ERC20 : shares are 0");
        require(_shares[account] == 0, "ERC20 : account already has shares");
        
        
       
        _pointOne[account]=_totalRevenue;
        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        
        emit PayeeAdded(account, shares_);
    }
    
   
    
    
    function subscribe(uint256 amount)public{
        require(DAI.allowance(_msgSender(),address(this))>0,"No allowance found");
        
        _userInvestment[_msgSender()]=_userInvestment[_msgSender()]+amount;
        _totalRevenue = _totalRevenue + amount;
        
        if(_userInvestment[_msgSender()]%_threshold==0 && _shares[_msgSender()]==0){
            _addPayee(_msgSender(),1*10**decimals()+_shares[_msgSender()]);
            _mint(_msgSender(),1*10**decimals());
        }
        else if(_userInvestment[_msgSender()]%_threshold==0 && _shares[_msgSender()]>0){
            _unclaimedPayment[_msgSender()]=unclaimedPayment(_msgSender());
            _pointOne[_msgSender()]=_totalRevenue;
            _shares[_msgSender()]=_shares[_msgSender()]+1*10**decimals();
            _mint(_msgSender(),1*10**decimals());
            _totalShares=_totalShares+1*10**decimals();
           
        }
        
        DAI.transferFrom(_msgSender(),address(this),amount);
    
        
    }
    

    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
       if(isContract(recipient) && !isContract(_msgSender()))
        {
        _unclaimedPayment[_msgSender()]=unclaimedPayment(_msgSender());
        _pointOne[_msgSender()]=_totalRevenue;
        _shares[_msgSender()]=_shares[_msgSender()]-amount;

        _totalShares = _totalShares - amount;

        _transfer(_msgSender(), recipient, amount);
        return true;
        }
        else if(isContract(_msgSender()) && !isContract(recipient)){
        _unclaimedPayment[recipient]=unclaimedPayment(recipient);
        _pointOne[recipient]=_totalRevenue;
        _shares[recipient]=_shares[recipient]+amount;
       _totalShares = _totalShares + amount;
        _transfer(_msgSender(), recipient, amount);
        return true;
        }
        else if(isContract(_msgSender()) && isContract(recipient)){
            _transfer(_msgSender(), recipient, amount);
        return true;
        }
        else{
        _unclaimedPayment[_msgSender()]=unclaimedPayment(_msgSender());
        _pointOne[_msgSender()]=_totalRevenue;
        _shares[_msgSender()]=_shares[_msgSender()]-amount;

        _unclaimedPayment[recipient]=unclaimedPayment(recipient);
        _pointOne[recipient]=_totalRevenue;
        _shares[recipient]=_shares[recipient]+amount;

        _transfer(_msgSender(), recipient, amount);


        return true;
        }
        }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        
        if(isContract(recipient) && !isContract(sender))
        {
        _unclaimedPayment[sender]=unclaimedPayment(sender);
        _pointOne[sender]=_totalRevenue;
        _shares[sender]=_shares[sender]-amount;
        
        _totalShares = _totalShares - amount;
        
        _transfer(sender, recipient, amount);
        return true;
        }
        else if(isContract(sender) && !isContract(recipient)){
        _unclaimedPayment[recipient]=unclaimedPayment(recipient);
        _pointOne[recipient]=_totalRevenue;
        _shares[recipient]=_shares[recipient]+amount;
       _totalShares = _totalShares + amount;
        _transfer(sender, recipient, amount);
        return true;
        }
        else if(isContract(sender) && isContract(recipient)){
            _transfer(sender, recipient, amount);
        return true;
        }
        else{
        _unclaimedPayment[sender]=unclaimedPayment(sender);
        _pointOne[sender]=_totalRevenue;
        _shares[sender]=_shares[sender]-amount;
        
        _unclaimedPayment[recipient]=unclaimedPayment(recipient);
        _pointOne[recipient]=_totalRevenue;
        _shares[recipient]=_shares[recipient]+amount;
       
        _transfer(sender, recipient, amount);
        
        
        return true;
        }
}
    
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = allowance(sender,_msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    
    function mint(address account, uint256 amount) private {
        require(amount+totalSupply()>_maxSupply," total supply reached");
        _mint(account,amount);
    }
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    
    
    
}