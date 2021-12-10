// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./PaymentSplitter.sol";


contract APIToken is ERC20{
    
    
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

//variable defining
   
    address private _paymentSplitterAddress;
    uint256 public _threshold;
    uint256 public _initialSupply;
    uint256 public _maxSupply;
    uint256 public _developerSharePercentage;
    uint256 public _apiInvestorSharePercentage;
    uint256 public _panaCloudSharePercentage;
    uint256 public _apiProposerSharePercentage;
    address private owner;
    address private DAIAddress = address(0xaD6D458402F60fD3Bd25163575031ACDce07538D);

    
    PaymentSplitter private paymentSplitter;
    ERC20 private DAI =ERC20(DAIAddress);
    
    mapping(address => uint) private nonces;
    mapping(address => mapping (uint32 => Checkpoint)) private checkpoints;
    mapping(address => uint32) private numCheckpoints;
    mapping(address => address) public delegates;

   // The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    // The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");



    
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }


    constructor(
        
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 initialSupply,
        uint256 developerSharePercentage,
        uint256 apiInvestorSharePercentage,
        uint256 panaCloudSharePercentage,
        uint256 apiProposerSharePercentage,
        uint256 threshold,
        address paymentSplitterAddress) ERC20(name,symbol)  {
        
        // require(payees.length == shares_.length, " payees and shares length mismatch");
        // require(payees.length > 0, " no payees");
         _initialSupply = initialSupply;
         _developerSharePercentage = developerSharePercentage;
         _apiInvestorSharePercentage = apiInvestorSharePercentage;
         _panaCloudSharePercentage = panaCloudSharePercentage;
         _apiProposerSharePercentage = apiProposerSharePercentage;
         _paymentSplitterAddress = paymentSplitterAddress;
         paymentSplitter = PaymentSplitter(paymentSplitterAddress);
    
        _maxSupply = maxSupply;
        _threshold=threshold;
          owner = msg.sender;
        
        // for (uint256 i = 0; i < payees.length; i++) {
        //     _addPayee(payees[i], shares_[i]);
        //     _mint(payees[i], shares_[i]);
        // }
    }

    

   function mint(address account, uint256 amount) public  {
        require(amount+totalSupply()>_maxSupply,"total supply reached");
        _mint(account,amount);
    }

   
    function subscribe(uint amount)public {
        bool out = paymentSplitter._subscribe(amount,_threshold);
        if(out)
        mint(_msgSender(),1*10**decimals());
    }

    function transfer(address recipient, uint256 amount) public override returns (bool){
        address sender = _msgSender();
        bool out = paymentSplitter.beforeTransferCheck(sender,recipient,amount);
        if(out)
        _transfer(_msgSender(), recipient, amount);
        return out;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        bool out = paymentSplitter.beforeTransferCheck(sender,recipient,amount);
        if(out){
            _transfer(sender, recipient, amount);

        uint256 currentAllowance = allowance(sender,_msgSender());
        require(currentAllowance >= amount, "allowance exceeds");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        }
        return out;
    
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20){
        _moveDelegates(delegates[from], delegates[to], amount);
    }


    // Functions related to voting power delegation -- Start

    function delegate(address delegatee) public {
        return _delegate(msg.sender, delegatee);
    }
    
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "delegateBySig:invalid sig.");
        require(nonce == nonces[signatory]++, "delegateBySig:invalid nonce");
        require(block.timestamp <= expiry, "delegateBySig:sig. expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "getPriorVotes:not determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator);
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld- amount;
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld+amount;
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {
      uint32 blockNumber = safe32(block.number, "block no. exceeds 32b");

      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[delegatee] = nCheckpoints + 1;
      }

      emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    //Functions related to voting power delegation -- End

    
function safe32(uint n, string memory errorMessage) public pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }




    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}
    
    
