/**
 * SPDX-License-Identifier: MIT
 * @author Accubits
 * @title Governance Token
 */

pragma solidity 0.8.21;

import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';

import './Common.sol';
import './StableCoin.sol';

contract GovernanceToken is
  Initializable,
  ERC20Upgradeable,
  ERC20PausableUpgradeable,
  OwnableUpgradeable,
  Common,
  ReentrancyGuardUpgradeable
{

  /**
 * @notice Sub Type of WhiteList Control
 * 0 - REMOVE
 * 1 - ADD
 */
  enum WhiteListControlRequestType {
    REMOVE,
    ADD
  }

  /**
   * @notice Structure of a Whitelist Control Request
   * id - ID of the whitelist Control Request
   * subType - sub-Type of whitelist control(REMOVE/ADD)
   * wallets - list of addresses needs to be whitelisted
   * owner - address of request owner
   * approvals - list of addresses who approved the request
   * status - status of request.
   */
  struct WhiteListControlRequests {
    uint256 id;
    WhiteListControlRequestType subType;
    address[] wallets;
    address owner;
    address[] approvals;
    RequestStatus status;
  }

  /// event for WhiteList Update
  event WhiteListUpdated(
    WhiteListControlRequestType indexed reqType,
    uint256 indexed reqId,
    address[] userAddress
  );

  /// event for when Token Burned for Swap.
  event TokenBurnedForSwap(address indexed receiver, uint256 indexed amount, address indexed token);

  /// Threshold mapping for WhiteList Control.
  mapping(WhiteListControlRequestType => uint256) internal whiteListControlThresholds;
  /// mapping of whiteList Control requests.
  mapping(uint256 => WhiteListControlRequests) internal whiteListControlRequests;

  /// to store decimal.
  uint8 private _decimals;

  /// mapping to get that address is whitelisted or not.
  mapping(address => bool) private isWhiteListed;

  /// List of whiteListed users.
  address[] private whiteListedUsers;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  /**
   * @dev   To initialize Contract.
   * @param name_             ERC20 Token Name.
   * @param symbol_           ERC20 Token Symbol.
   * @param decimals_         ERC20 decimal allows.
   * @param owner_            Address of Contract owner.
   */
  function initialize(
    string memory name_,
    string memory symbol_,
    uint8 decimals_,
    address owner_
  ) public initializer {
    __ERC20_init(name_, symbol_);
    __ERC20Pausable_init();
    __Ownable_init();

    isSignatory[owner_] = true;
    signatoryList.push(owner_);

    isWhiteListed[owner_] = true;
    whiteListedUsers.push(owner_);

    _decimals = decimals_;
    _setRequestTypeCount();
    _setDefaultThresholds();

    _transferOwnership(owner_);
  }

  /**
   * @dev Function to set dafault Thresholds for all operations.
   */
  function _setDefaultThresholds() private {
    tokenSupplyControlThresholds[TokenSupplyControlRequestType.BURN] = 1;
    tokenSupplyControlThresholds[TokenSupplyControlRequestType.MINT] = 1;
    transactionControlThresholds[TransactionControlRequestType.PAUSE] = 1;
    transactionControlThresholds[TransactionControlRequestType.UNPAUSE] = 1;
    signatoryControlThresholds[SignatoryControlRequestType.ADD] = 1;
    signatoryControlThresholds[SignatoryControlRequestType.REMOVE] = 1;
    whiteListControlThresholds[WhiteListControlRequestType.ADD] = 1;
    whiteListControlThresholds[WhiteListControlRequestType.REMOVE] = 1;
    thresholdControlThresholds[ThresholdControlRequestType.UPDATE] = 1;
  }

  /**
   * @dev    override function to modify the decimal support for the Token.
   * @return uint8 number of decimals allowed
   */
  function decimals() public view virtual override returns (uint8) {
    return _decimals;
  }

  /**
   * @dev    Fetching list of all the Signatories.
   * @return Array containing all signatories.
   */
  function getSignatoryList() external view returns (address[] memory) {
    return signatoryList;
  }

  /**
   * @dev    Fetching list of all the whiteListed users.
   * @return address[] containing all whiteListed users.
   */
  function getWhiteListedUsers() external view returns (address[] memory) {
    return whiteListedUsers;
  }

  /**
   * @dev    To get the Threshold value for specified Request Type.
   * @param  reqType_ Type of operation.
   * @return uint256[] array containing Threshold count for the Request Type.
   */
  function getThresholds(RequestType reqType_) external view returns (uint256[] memory) {
    uint256[] memory thresholds = new uint256[](requestTypeCount[reqType_]);
    for (uint256 i; i < requestTypeCount[reqType_]; i++) {
      if (reqType_ == RequestType.TOKEN_SUPPLY_CONTROL) {
        thresholds[i] = tokenSupplyControlThresholds[TokenSupplyControlRequestType(i)];
      } else if (reqType_ == RequestType.TRANSACTION_CONTROL) {
        thresholds[i] = transactionControlThresholds[TransactionControlRequestType(i)];
      } else if (reqType_ == RequestType.SIGNATORY_CONTROL) {
        thresholds[i] = signatoryControlThresholds[SignatoryControlRequestType(i)];
      } else if (reqType_ == RequestType.THRESHOLD_CONTROL) {
        thresholds[i] = thresholdControlThresholds[ThresholdControlRequestType(i)];
      } else {
        thresholds[i] = whiteListControlThresholds[WhiteListControlRequestType(i)];
      }
    }
    return thresholds;
  }

  /**
   * @dev    To see the Requested Object for Token Supply.
   * @param  id_ ID of the request.
   * @return Structure of Token Supply Request of given ID.
   */
  function getTokenSupplyControlRequest(
    uint256 id_
  ) external view returns (TokenSupplyControlRequests memory) {
    require(tokenSupplyControlRequests[id_].owner != address(0), 'INVALID_REQUEST!');
    return tokenSupplyControlRequests[id_];
  }

  /**
   * @dev    To see the Requested Object for Transaction Control.
   * @param  id_ ID of the request.
   * @return Structure of Transaction Control Request of given ID.
   */
  function getTransactionControlRequest(
    uint256 id_
  ) external view returns (TransactionControlRequests memory) {
    require(transactionControlRequests[id_].owner != address(0), 'INVALID_REQUEST!');
    return transactionControlRequests[id_];
  }

  /**
   * @dev    To see the Requested Object for Signatory Control.
   * @param  id_ ID of the request.
   * @return Structure Structure of Signatory Control Request of given ID.
   */
  function getSignatoryControlRequest(
    uint256 id_
  ) external view returns (SignatoryControlRequests memory) {
    require(signatoryControlRequests[id_].owner != address(0), 'INVALID_REQUEST!');
    return signatoryControlRequests[id_];
  }

  /**
   * @dev    To see the Requested Object for Threshold Control.
   * @param  id_ ID of the request.
   * @return Structure Structure of Threshold Control Request of given ID.
   */
  function getThresholdControlRequest(
    uint256 id_
  ) external view returns (ThresholdControlRequests memory) {
    require(thresholdControlRequests[id_].owner != address(0), 'INVALID_REQUEST!');
    return thresholdControlRequests[id_];
  }

  /**
   * @dev    To see the Requested Object for WhiteList Control.
   * @param  id_ ID of the request.
   * @return Structure of WhiteList Control Request of given ID.
   */
  function getWhiteListControlRequest(
    uint256 id_
  ) external view returns (WhiteListControlRequests memory) {
    require(whiteListControlRequests[id_].owner != address(0), 'INVALID_REQUEST!');
    return whiteListControlRequests[id_];
  }

  /**
   * @dev     Overriding the inherited function transfer.
   * @param   to  Address to send token amount.
   * @param   amount  Token amount to be transferred.
   * @return  bool  True, if transfer successful else revert.
   */
  function transfer(address to, uint256 amount) public virtual override returns (bool) {
    require(isWhiteListed[_msgSender()] && isWhiteListed[to], 'NOT_WHITELISTED');
    _transfer(_msgSender(), to, amount);
    return true;
  }

  /**
   * @dev     Overriding the inherited function transferFrom
   * @param   from  Address from which token amount is transfer.
   * @param   to  Address to which token amount is received.
   * @param   amount  Token amount to be transfer.
   * @return  bool  True, if transfer successful else revert.
   */
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public virtual override returns (bool) {
    address spender = _msgSender();
    require(isWhiteListed[_msgSender()] && isWhiteListed[to], 'NOT_WHITELISTED');
    _spendAllowance(from, spender, amount);
    _transfer(from, to, amount);
    return true;
  }

  /**
   * @dev   To create a Token Supply Control Request.
   * @param reqSubType_ Sub Type of the request (Mint/Burn).
   * @param id_         ID for the newly created Request.
   * @param amount_     Ammount of Tokens for minting or burning.
   * @param to_         Address of receiver.
   */
  function createTokenSupplyControlRequest(
    TokenSupplyControlRequestType reqSubType_,
    uint256 id_,
    uint256 amount_,
    address to_
  ) external onlySignatory {
    require(tokenSupplyControlRequests[id_].owner == address(0), 'INVALID_REQUEST!');
    require(isWhiteListed[to_], 'NOT_WHITELISTED');

    tokenSupplyControlRequests[id_].id = id_;
    tokenSupplyControlRequests[id_].subType = reqSubType_;
    tokenSupplyControlRequests[id_].amount = amount_;
    tokenSupplyControlRequests[id_].wallet = to_;
    tokenSupplyControlRequests[id_].owner = msg.sender;
    tokenSupplyControlRequests[id_].status = RequestStatus.IN_PROGRESS;

    emit RequestCreated(RequestType.TOKEN_SUPPLY_CONTROL, uint256(reqSubType_), msg.sender, id_);
  }

  /**
   * @dev   To update a Token Supply Control Request.
   * @param id_         ID of the request needs to be updated.
   * @param amount_     new Ammount of Tokens for minting or burning.
   * @param to_         new Address of receiver.
   */
  function updateTokenSupplyControlRequest(
    uint256 id_,
    uint256 amount_,
    address to_
  ) external onlySignatory {
    require(tokenSupplyControlRequests[id_].owner != address(0), 'INVALID_REQUEST!');
    require(tokenSupplyControlRequests[id_].owner == msg.sender, 'UNAUTHORIZED!');
    require(tokenSupplyControlRequests[id_].status == RequestStatus.IN_PROGRESS, 'NOT_ACTIVE!');
    require(isWhiteListed[to_], 'NOT_WHITELISTED');

    tokenSupplyControlRequests[id_].amount = amount_;
    tokenSupplyControlRequests[id_].wallet = to_;
    tokenSupplyControlRequests[id_].approvals = new address[](0);
    emit RequestUpdated(RequestType.TOKEN_SUPPLY_CONTROL, id_);
  }

  /**
   * @dev   To create a Transaction Control Request.
   * @param reqSubType_ Sub Type of the request (Pause/Unpause).
   * @param id_         ID for the newly created Request.
   */
  function createTransactionControlRequest(
    TransactionControlRequestType reqSubType_,
    uint256 id_
  ) external onlySignatory {
    require(transactionControlRequests[id_].owner == address(0), 'INVALID_REQUEST!');

    transactionControlRequests[id_].id = id_;
    transactionControlRequests[id_].subType = reqSubType_;
    transactionControlRequests[id_].owner = msg.sender;
    transactionControlRequests[id_].status = RequestStatus.IN_PROGRESS;

    emit RequestCreated(RequestType.TRANSACTION_CONTROL, uint256(reqSubType_), msg.sender, id_);
  }

  /**
   * @dev   Request To create a Signatories.
   * @param reqSubType_ Sub Type of the request (ADD/REMOVE).
   * @param id_         ID for the newly created Request.
   * @param users_      list of signatories to add or remove.
   */
  function createSignatoryControlRequest(
    SignatoryControlRequestType reqSubType_,
    uint256 id_,
    address[] memory users_
  ) external onlySignatory {
    require(signatoryControlRequests[id_].owner == address(0), 'INVALID_REQUEST!');

    signatoryControlRequests[id_].id = id_;
    signatoryControlRequests[id_].subType = reqSubType_;
    signatoryControlRequests[id_].wallets = users_;
    signatoryControlRequests[id_].owner = msg.sender;
    signatoryControlRequests[id_].status = RequestStatus.IN_PROGRESS;

    emit RequestCreated(RequestType.SIGNATORY_CONTROL, uint256(reqSubType_), msg.sender, id_);
  }

  /**
   * @dev   To update a Signatory Control Request.
   * @param id_    ID of the request needs to be updated.
   * @param users_ new list of signatories.
   */
  function updateSignatoryControlRequest(
    uint256 id_,
    address[] memory users_
  ) external onlySignatory {
    require(signatoryControlRequests[id_].owner != address(0), 'INVALID_REQUEST!');
    require(signatoryControlRequests[id_].owner == msg.sender, 'UNAUTHORIZED!');
    require(signatoryControlRequests[id_].status == RequestStatus.IN_PROGRESS, 'NOT_ACTIVE!');

    signatoryControlRequests[id_].wallets = users_;
    signatoryControlRequests[id_].approvals = new address[](0);

    emit RequestUpdated(RequestType.SIGNATORY_CONTROL, id_);
  }

  /**
   * @dev   Request To create Threshold Control.
   * @param reqType_    Request Type for which thresholds need to change.
   * @param id_         ID for the newly created Request.
   * @param thresholds_ list of thresholds for the request.
   */
  function createThresholdControlRequest(
    RequestType reqType_,
    uint256 id_,
    uint256[] memory thresholds_
  ) external onlySignatory {
    require(thresholdControlRequests[id_].owner == address(0), 'INVALID_REQUEST!');
    require(thresholds_.length == requestTypeCount[reqType_], 'INVALID_THRESHOLD_COUNTS!');
    for(uint256 i;i < thresholds_.length;i++){
      require(thresholds_[i] > 0, 'INVALID_THRESHOLD!');
    }

    thresholdControlRequests[id_].id = id_;
    thresholdControlRequests[id_].reqType = reqType_;
    thresholdControlRequests[id_].subType = ThresholdControlRequestType.UPDATE;
    thresholdControlRequests[id_].thresholds = thresholds_;
    thresholdControlRequests[id_].owner = msg.sender;
    thresholdControlRequests[id_].status = RequestStatus.IN_PROGRESS;

    emit RequestCreated(RequestType.THRESHOLD_CONTROL, uint256(ThresholdControlRequestType.UPDATE), msg.sender, id_);
  }

  /**
   * @dev   To update a Threshold Control Request.
   * @param id_         ID of the request needs to be updated.
   * @param thresholds_ new list of Thresholds for the request Type.
   */
  function updateThresholdControlRequest(
    uint256 id_,
    uint256[] memory thresholds_
  ) external onlySignatory {
    require(thresholdControlRequests[id_].owner != address(0), 'INVALID_REQUEST!');
    require(thresholdControlRequests[id_].owner == msg.sender, 'UNAUTHORIZED!');
    require(thresholdControlRequests[id_].status == RequestStatus.IN_PROGRESS, 'NOT_ACTIVE!');
    require(
      thresholds_.length == requestTypeCount[thresholdControlRequests[id_].reqType],
      'INVALID_THRESHOLD_COUNTS!'
    );
    for(uint256 i;i < thresholds_.length;i++){
      require(thresholds_[i] > 0, 'INVALID_THRESHOLD!');
    }
    thresholdControlRequests[id_].thresholds = thresholds_;
    thresholdControlRequests[id_].approvals = new address[](0);

    emit RequestUpdated(RequestType.THRESHOLD_CONTROL, id_);
  }

  /**
   * @dev   Request To create WhiteList Control.
   * @param reqSubType_    Sub Request Type of whitelisting(ADD/REMOVE)
   * @param id_         ID for the newly created Request.
   * @param users_ list of users needs to be whitelisted.
   */
  function createWhiteListControlRequest(
    WhiteListControlRequestType reqSubType_,
    uint256 id_,
    address[] memory users_
  ) external onlySignatory {
    require(whiteListControlRequests[id_].owner == address(0), 'INVALID_REQUEST!');

    whiteListControlRequests[id_].id = id_;
    whiteListControlRequests[id_].subType = reqSubType_;
    whiteListControlRequests[id_].wallets = users_;
    whiteListControlRequests[id_].owner = msg.sender;
    whiteListControlRequests[id_].status = RequestStatus.IN_PROGRESS;

    emit RequestCreated(RequestType.WHITELIST_CONTROL, uint256(reqSubType_), msg.sender, id_);
  }

  /**
   * @dev   To update a WhiteList Control Request.
   * @param id_         ID of the request needs to be updated.
   * @param users_ new list of users.
   */
  function updateWhiteListControlRequest(
    uint256 id_,
    address[] memory users_
  ) external onlySignatory {
    require(whiteListControlRequests[id_].owner != address(0), 'INVALID_REQUEST!');
    require(whiteListControlRequests[id_].owner == msg.sender, 'UNAUTHORIZED!');
    require(whiteListControlRequests[id_].status == RequestStatus.IN_PROGRESS, 'NOT_ACTIVE!');

    whiteListControlRequests[id_].wallets = users_;
    whiteListControlRequests[id_].approvals = new address[](0);

    emit RequestUpdated(RequestType.WHITELIST_CONTROL, id_);
  }

  /**
   * @dev To vote for a request of any type.
   * @param reqType_  Request Type of operations.
   * @param id_       ID of the request, which was made previously.
   * @param approval_ true for approval, false for rejection.
   */
  function vote(
    RequestType reqType_,
    uint256 id_,
    bool approval_
  ) external onlySignatory nonReentrant {
    if (reqType_ == RequestType.TOKEN_SUPPLY_CONTROL) {
      _isApprovable(tokenSupplyControlRequests[id_].owner, tokenSupplyControlRequests[id_].status);

      bool isApproved = ArrayOps.isElement(tokenSupplyControlRequests[id_].approvals, msg.sender);
      if (approval_) {
        require(!isApproved, 'APPROVED!');
        tokenSupplyControlRequests[id_].approvals.push(msg.sender);
      } else {
        require(isApproved, 'NOT_APPROVED!');
        address[] memory updatedApprovals = ArrayOps.deleteFromArray(
          tokenSupplyControlRequests[id_].approvals,
          msg.sender
        );
        tokenSupplyControlRequests[id_].approvals = updatedApprovals;
      }

      tokenSupplyControlRequests[id_].status = tokenSupplyControlRequests[id_].approvals.length >=
        tokenSupplyControlThresholds[tokenSupplyControlRequests[id_].subType]
        ? RequestStatus.ACCEPTED
        : RequestStatus.IN_PROGRESS;
    } else if (reqType_ == RequestType.TRANSACTION_CONTROL) {
      _isApprovable(transactionControlRequests[id_].owner, transactionControlRequests[id_].status);

      bool isApproved = ArrayOps.isElement(transactionControlRequests[id_].approvals, msg.sender);
      if (approval_) {
        require(!isApproved, 'APPROVED!');
        transactionControlRequests[id_].approvals.push(msg.sender);
      } else {
        require(isApproved, 'NOT_APPROVED!');
        address[] memory updatedApprovals = ArrayOps.deleteFromArray(
          transactionControlRequests[id_].approvals,
          msg.sender
        );
        transactionControlRequests[id_].approvals = updatedApprovals;
      }

      transactionControlRequests[id_].status = transactionControlRequests[id_].approvals.length >=
        transactionControlThresholds[transactionControlRequests[id_].subType]
        ? RequestStatus.ACCEPTED
        : RequestStatus.IN_PROGRESS;
    } else if (reqType_ == RequestType.SIGNATORY_CONTROL) {
      _isApprovable(signatoryControlRequests[id_].owner, signatoryControlRequests[id_].status);

      bool isApproved = ArrayOps.isElement(signatoryControlRequests[id_].approvals, msg.sender);
      if (approval_) {
        require(!isApproved, 'APPROVED!');
        signatoryControlRequests[id_].approvals.push(msg.sender);
      } else {
        require(isApproved, 'NOT_APPROVED!');
        signatoryControlRequests[id_].approvals = ArrayOps.deleteFromArray(
          signatoryControlRequests[id_].approvals,
          msg.sender
        );
      }

      signatoryControlRequests[id_].status = signatoryControlRequests[id_].approvals.length >=
        signatoryControlThresholds[signatoryControlRequests[id_].subType]
        ? RequestStatus.ACCEPTED
        : RequestStatus.IN_PROGRESS;
    } else if (reqType_ == RequestType.THRESHOLD_CONTROL) {
      _isApprovable(thresholdControlRequests[id_].owner, thresholdControlRequests[id_].status);

      bool isApproved = ArrayOps.isElement(thresholdControlRequests[id_].approvals, msg.sender);
      if (approval_) {
        require(!isApproved, 'APPROVED!');
        thresholdControlRequests[id_].approvals.push(msg.sender);
      } else {
        require(isApproved, 'NOT_APPROVED!');
        thresholdControlRequests[id_].approvals = ArrayOps.deleteFromArray(
          thresholdControlRequests[id_].approvals,
          msg.sender
        );
      }

      thresholdControlRequests[id_].status = thresholdControlRequests[id_].approvals.length >=
        thresholdControlThresholds[thresholdControlRequests[id_].subType]
        ? RequestStatus.ACCEPTED
        : RequestStatus.IN_PROGRESS;
    } else {
      _isApprovable(whiteListControlRequests[id_].owner, whiteListControlRequests[id_].status);

      bool isApproved = ArrayOps.isElement(whiteListControlRequests[id_].approvals, msg.sender);
      if (approval_) {
        require(!isApproved, 'APPROVED!');
        whiteListControlRequests[id_].approvals.push(msg.sender);
      } else {
        require(isApproved, 'NOT_APPROVED!');
        whiteListControlRequests[id_].approvals = ArrayOps.deleteFromArray(
          whiteListControlRequests[id_].approvals,
          msg.sender
        );
      }

      whiteListControlRequests[id_].status = whiteListControlRequests[id_].approvals.length >=
        whiteListControlThresholds[whiteListControlRequests[id_].subType]
        ? RequestStatus.ACCEPTED
        : RequestStatus.IN_PROGRESS;
    }
    emit RequestApproval(reqType_, id_, msg.sender, approval_);
  }

  /**
   * @dev To execute the operation, if thresholds are valid then it will execute else revert.
   * @param reqType_ Type of Request which needs to be executed.
   * @param id_      ID of the request.
   */
  function execute(RequestType reqType_, uint256 id_) external {
    if (reqType_ == RequestType.TOKEN_SUPPLY_CONTROL) {
      _isExecutable(tokenSupplyControlRequests[id_].owner, tokenSupplyControlRequests[id_].status);

      if (TokenSupplyControlRequestType.MINT == tokenSupplyControlRequests[id_].subType) {
        _mint(tokenSupplyControlRequests[id_].wallet, tokenSupplyControlRequests[id_].amount);
      } else {
        if (tokenSupplyControlRequests[id_].wallet == tokenSupplyControlRequests[id_].owner) {
          _burn(tokenSupplyControlRequests[id_].owner, tokenSupplyControlRequests[id_].amount);
        } else if (tokenSupplyControlRequests[id_].wallet == address(this)) {
          _burn(address(this), tokenSupplyControlRequests[id_].amount);
        } else {
          require(
            allowance(
              tokenSupplyControlRequests[id_].wallet,
              tokenSupplyControlRequests[id_].owner
            ) >= tokenSupplyControlRequests[id_].amount,
            'INSUFFICIENT_ALLOWANCE!'
          );
          _spendAllowance(
            tokenSupplyControlRequests[id_].wallet,
            tokenSupplyControlRequests[id_].owner,
            tokenSupplyControlRequests[id_].amount
          );
          _burn(tokenSupplyControlRequests[id_].wallet, tokenSupplyControlRequests[id_].amount);
        }
      }

      tokenSupplyControlRequests[id_].status = RequestStatus.EXECUTED;
    } else if (reqType_ == RequestType.TRANSACTION_CONTROL) {
      _isExecutable(transactionControlRequests[id_].owner, transactionControlRequests[id_].status);

      if (TransactionControlRequestType.PAUSE == transactionControlRequests[id_].subType) {
        _pause();
      } else {
        _unpause();
      }

      transactionControlRequests[id_].status = RequestStatus.EXECUTED;
    } else if (reqType_ == RequestType.SIGNATORY_CONTROL) {
      _isExecutable(signatoryControlRequests[id_].owner, signatoryControlRequests[id_].status);

      for (uint256 i; i < signatoryControlRequests[id_].wallets.length; i++) {
        if (SignatoryControlRequestType.ADD == signatoryControlRequests[id_].subType) {
          require(!isSignatory[signatoryControlRequests[id_].wallets[i]], 'EXISTING!');
          isSignatory[signatoryControlRequests[id_].wallets[i]] = true;
          signatoryList.push(signatoryControlRequests[id_].wallets[i]);
        } else {
          require(signatoryList.length > 1, 'LAST_SIGNATORY!');
          require(isSignatory[signatoryControlRequests[id_].wallets[i]], 'UNKNOWN!');
          isSignatory[signatoryControlRequests[id_].wallets[i]] = false;
          signatoryList = ArrayOps.deleteFromArray(
            signatoryList,
            signatoryControlRequests[id_].wallets[i]
          );
        }
      }

      signatoryControlRequests[id_].status = RequestStatus.EXECUTED;
      emit SignatoriesUpdated(
        signatoryControlRequests[id_].subType,
        id_,
        signatoryControlRequests[id_].wallets
      );
    } else if (reqType_ == RequestType.THRESHOLD_CONTROL) {
      _isExecutable(thresholdControlRequests[id_].owner, thresholdControlRequests[id_].status);

      for (uint256 i; i < requestTypeCount[thresholdControlRequests[id_].reqType]; i++) {
        if (thresholdControlRequests[id_].reqType == RequestType.TOKEN_SUPPLY_CONTROL) {
          tokenSupplyControlThresholds[TokenSupplyControlRequestType(i)] = thresholdControlRequests[
            id_
          ].thresholds[i];
        } else if (thresholdControlRequests[id_].reqType == RequestType.TRANSACTION_CONTROL) {
          transactionControlThresholds[TransactionControlRequestType(i)] = thresholdControlRequests[
            id_
          ].thresholds[i];
        } else if (thresholdControlRequests[id_].reqType == RequestType.SIGNATORY_CONTROL) {
          signatoryControlThresholds[SignatoryControlRequestType(i)] = thresholdControlRequests[id_]
            .thresholds[i];
        } else if (thresholdControlRequests[id_].reqType == RequestType.THRESHOLD_CONTROL) {
          thresholdControlThresholds[ThresholdControlRequestType(i)] = thresholdControlRequests[id_]
            .thresholds[i];
        } else {
          whiteListControlThresholds[WhiteListControlRequestType(i)] = thresholdControlRequests[id_]
            .thresholds[i];
        }
      }

      thresholdControlRequests[id_].status = RequestStatus.EXECUTED;
      emit ThresholdUpdated(thresholdControlRequests[id_].reqType, id_, thresholdControlRequests[id_].thresholds);
    } else {
      _isExecutable(whiteListControlRequests[id_].owner, whiteListControlRequests[id_].status);

      for (uint256 i; i < whiteListControlRequests[id_].wallets.length; i++) {
        if (WhiteListControlRequestType.ADD == whiteListControlRequests[id_].subType) {
          require(!isWhiteListed[whiteListControlRequests[id_].wallets[i]], 'EXISTING!');
          isWhiteListed[whiteListControlRequests[id_].wallets[i]] = true;
          whiteListedUsers.push(whiteListControlRequests[id_].wallets[i]);
        } else {
          require(isWhiteListed[whiteListControlRequests[id_].wallets[i]], 'UNKNOWN!');
          isWhiteListed[whiteListControlRequests[id_].wallets[i]] = false;
          whiteListedUsers = ArrayOps.deleteFromArray(
            whiteListedUsers,
            whiteListControlRequests[id_].wallets[i]
          );
        }
      }

      whiteListControlRequests[id_].status = RequestStatus.EXECUTED;
      emit WhiteListUpdated(
        whiteListControlRequests[id_].subType,
        id_,
        whiteListControlRequests[id_].wallets
      );
    }
  }

  /**
   * @dev To cancel a request which is made previously.
   * @param reqType_ Request Type of operation.
   * @param id_      ID of the pending request.
   */
  function cancelRequest(RequestType reqType_, uint256 id_) external onlySignatory nonReentrant {
    if (reqType_ == RequestType.TOKEN_SUPPLY_CONTROL) {
      _isCancellable(tokenSupplyControlRequests[id_].owner, tokenSupplyControlRequests[id_].status);
      tokenSupplyControlRequests[id_].status = RequestStatus.CANCELLED;
    } else if (reqType_ == RequestType.TRANSACTION_CONTROL) {
      _isCancellable(transactionControlRequests[id_].owner, transactionControlRequests[id_].status);
      transactionControlRequests[id_].status = RequestStatus.CANCELLED;
    } else if (reqType_ == RequestType.SIGNATORY_CONTROL) {
      _isCancellable(signatoryControlRequests[id_].owner, signatoryControlRequests[id_].status);
      signatoryControlRequests[id_].status = RequestStatus.CANCELLED;
    } else if (reqType_ == RequestType.THRESHOLD_CONTROL) {
      _isCancellable(thresholdControlRequests[id_].owner, thresholdControlRequests[id_].status);
      thresholdControlRequests[id_].status = RequestStatus.CANCELLED;
    } else {
      _isCancellable(whiteListControlRequests[id_].owner, whiteListControlRequests[id_].status);
      whiteListControlRequests[id_].status = RequestStatus.CANCELLED;
    }

    emit RequestCancelled(reqType_, id_);
  }

  /**
   * @dev To mint the Token by swaping.
   * @param token_   address of receiver.
   * @param amount_ Amount of token to be minted.
   */
  function swap(address token_, uint256 amount_) external nonReentrant {
    require(isWhiteListed[msg.sender], 'UNAUTHORIZED!');
    _burn(msg.sender, amount_);
    StableCoin(token_).swap(msg.sender, amount_);
    emit TokenBurnedForSwap(msg.sender, amount_, token_);
  }

  /**
   * @dev     Overriding inherited hook
   * @param   from   Address from which token amount is transfer.
   * @param   to     Address to which token amount is received.
   * @param   amount Token amount to be transfer.
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal override(ERC20Upgradeable,ERC20PausableUpgradeable) whenNotPaused {
    super._beforeTokenTransfer(from, to, amount);
  }
}
