// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

library ArrayOps {
  /**
   * @dev Function to delete elements from the array.
   * @param addressArray array of addresses.
   * @param elAddress address which to be removed.
   * @return Updated Array.
   */
  function deleteFromArray(
    address[] storage addressArray,
    address elAddress
  ) internal returns (address[] memory) {
    for (uint256 i = 0; i < addressArray.length; i++) {
      if (addressArray[i] == elAddress) {
        addressArray[i] = addressArray[addressArray.length - 1];
        addressArray.pop();
        break;
      }
    }
    return addressArray;
  }

  /**
   * @dev Function to Check if element is present in array.
   * @param addressArray array of addresses.
   * @param elAddress address which to be checked.
   * @return bool true if element is present else false.
   */
  function isElement(
    address[] memory addressArray,
    address elAddress
  ) internal pure returns (bool) {
    bool _isElement;
    for (uint256 i = 0; i < addressArray.length; i++) {
      if (addressArray[i] == elAddress) {
        _isElement = true;
        break;
      }
    }
    return _isElement;
  }
}

/**
 * @title Common
 * @notice Common variable declarations, Request Types, Sub Request Types, Structures, Events from both GovernanceToken and StableCoin.
 */
contract Common {
  /**
 * @notice Status of a request.
 * 0 - IN_PROGRESS, Request created
 * 1 - ACCEPTED, Approved by enough signatories
 * 2 - EXECUTED, Executed by request owner
 * 3 - CANCELLED, Cancelled by request owner
 */
  enum RequestStatus {
    IN_PROGRESS,
    ACCEPTED,
    EXECUTED,
    CANCELLED
  }

  /**
 * @notice Types of Requests.
 * 0 - TOKEN_SUPPLY_CONTROL (Burn,Mint)
 * 1 - TRANSACTION_CONTROL (Pause,Unpause)
 * 2 - SIGNATORY_CONTROL (Remove, Add)
 * 3 - THRESHOLD_CONTROL (Update)
 * 4 - WHITELIST_CONTROL (Remove, Add)
 *     note: Only on Governance Token
 */
  enum RequestType {
    TOKEN_SUPPLY_CONTROL,
    TRANSACTION_CONTROL,
    SIGNATORY_CONTROL,
    THRESHOLD_CONTROL,
    WHITELIST_CONTROL
  }

  /**
 * @notice Sub-Type of Token Supply Control
 * 0 - BURN
 * 1 - MINT
 */
  enum TokenSupplyControlRequestType {
    BURN,
    MINT
  }

  /**
 * @notice Sub-Type of Transaction Control
 * 0 - PAUSE
 * 1 - UNPAUSE
 */
  enum TransactionControlRequestType {
    PAUSE,
    UNPAUSE
  }

  /**
 * @notice Sub-Type of Signatory Control
 * 0 - REMOVE
 * 1 - ADD
 */
  enum SignatoryControlRequestType {
    REMOVE,
    ADD
  }

  /**
 * @notice Sub-Type of Threshold Control
 * 0 - UPDATE
 */
  enum ThresholdControlRequestType {
    UPDATE
  }

  /**
   * @notice Structure of a Token Supply control Request
   * id - ID of the Token Supply Control Request
   * subType - sub-Type of Token Supply control(MINT/BURN)
   * amount - Amount of token need to be minted or burned.
   * wallet - address of the wallet
   * owner - address of request owner
   * approvals - list of addresses who approved the request
   * status - status of request.
   */
  struct TokenSupplyControlRequests {
    uint256 id;
    TokenSupplyControlRequestType subType;
    uint256 amount;
    address wallet;
    address owner;
    address[] approvals;
    RequestStatus status;
  }

    /**
   * @notice Structure of a Transaction Control Request
   * id - ID of the Transaction Control Request
   * subType - sub-Type of Transaction control(PAUSE/UNPAUSE)
   * owner - address of request owner
   * approvals - list of addresses who approved the request
   * status - status of request.
   */
  struct TransactionControlRequests {
    uint256 id;
    TransactionControlRequestType subType;
    address owner;
    address[] approvals;
    RequestStatus status;
  }

  /**
   * @notice Structure of a Signatory Control Request
   * id - ID of the Signatory Control Request
   * subType - sub-Type of Transaction control(ADD/REMOVE)
   * wallets - list of addresses needs to be added or removed
   * owner - address of request owner
   * approvals - list of addresses who approved the request
   * status - status of request.
   */
  struct SignatoryControlRequests {
    uint256 id;
    SignatoryControlRequestType subType;
    address[] wallets;
    address owner;
    address[] approvals;
    RequestStatus status;
  }

  /**
   * @notice Structure of a Threshold Control Request
   * id - ID of the Threshold Control Request
   * reqType - request type for which threshold need to update
   * thresholds - list of threshold values
   * owner - address of request owner
   * approvals - list of addresses who approved the request
   * status - status of request.
   */
  struct ThresholdControlRequests {
    uint256 id;
    RequestType reqType;
    ThresholdControlRequestType subType;
    uint256[] thresholds;
    address owner;
    address[] approvals;
    RequestStatus status;
  }

  /// mapping to check if address is a signatory or not.
  mapping(address => bool) internal isSignatory;
  /// List of all signatories.
  address[] internal signatoryList;

  /// mapping for the count of request types.
  mapping(RequestType => uint256) internal requestTypeCount;

  /// mapping for the threshold count for token supply.
  mapping(TokenSupplyControlRequestType => uint256) internal tokenSupplyControlThresholds;
  /// mapping of all the token supply request.
  mapping(uint256 => TokenSupplyControlRequests) internal tokenSupplyControlRequests;

  /// mapping for the threshold count for Transaction Control.
  mapping(TransactionControlRequestType => uint256) internal transactionControlThresholds;
  /// mapping of all the Transaction control request.
  mapping(uint256 => TransactionControlRequests) internal transactionControlRequests;

  /// mapping for the threshold count for Signatory Control.
  mapping(SignatoryControlRequestType => uint256) internal signatoryControlThresholds;
  /// mapping of all the Signatory control request.
  mapping(uint256 => SignatoryControlRequests) internal signatoryControlRequests;

  /// mapping for the threshold count for Threshold Control.
  mapping(ThresholdControlRequestType => uint256) internal thresholdControlThresholds;
  /// mapping of all the Threshold control request.
  mapping(uint256 => ThresholdControlRequests) internal thresholdControlRequests;

  /// event when a request is created.
  event RequestCreated(
    RequestType indexed reqType,
    uint256 indexed subType,
    address indexed ownerAddress,
    uint256 reqId
  );
  /// event when a request is cancelled.
  event RequestCancelled(RequestType indexed reqType, uint256 indexed reqId);
  /// event when a request is updated.
  event RequestUpdated(RequestType indexed reqType, uint256 indexed reqId);
  /// event when a request is approved.
  event RequestApproval(
    RequestType indexed reqType,
    uint256 indexed reqId,
    address indexed signatoryAddress,
    bool isApproved
  );

  /// event when a signatory is updated.
  event SignatoriesUpdated(
    SignatoryControlRequestType indexed reqType,
    uint256 indexed reqId,
    address[] signatoryAddress
  );
  /// event when a Threshold is updated.
  event ThresholdUpdated(
    RequestType indexed reqType,
    uint256 indexed reqId,
    uint256[] newThresholds
  );

  /**
   * @dev modifier function to allow only to the signatories.
   */
  modifier onlySignatory() {
    require(isSignatory[msg.sender], 'UNAUTHORIZED!');
    _;
  }

  /**
   * @dev setting the count of all request types.
   */
  function _setRequestTypeCount() internal {
    requestTypeCount[RequestType.TOKEN_SUPPLY_CONTROL] = 2;
    requestTypeCount[RequestType.TRANSACTION_CONTROL] = 2;
    requestTypeCount[RequestType.SIGNATORY_CONTROL] = 2;
    requestTypeCount[RequestType.THRESHOLD_CONTROL] = 1;
    requestTypeCount[RequestType.WHITELIST_CONTROL] = 2;
  }

  /**
   * @dev to check that a request can be cancelled or not.
   * @param owner owner of the request.
   * @param status status of the request.
   */
  function _isCancellable(address owner, RequestStatus status) internal view {
    require(owner != address(0), 'INVALID_REQUEST!');
    require(owner == msg.sender, 'UNAUTHORIZED!');
    require(status == RequestStatus.IN_PROGRESS || status == RequestStatus.ACCEPTED, 'NOT_ACTIVE!');
  }

  /**
   * @dev to check that a request can be approved or not.
   * @param owner owner of the request.
   * @param status status of the request.
   */
  function _isApprovable(address owner, RequestStatus status) internal pure {
    require(owner != address(0), 'INVALID_REQUEST!');
    require(status == RequestStatus.IN_PROGRESS || status == RequestStatus.ACCEPTED, 'NOT_ACTIVE!');
  }

  /**
   * @dev to check that a request can be executed or not.
   * @param owner owner of the request.
   * @param status status of the request.
   */
  function _isExecutable(address owner, RequestStatus status) internal view {
    require(owner != address(0), 'INVALID_REQUEST!');
    require(owner == msg.sender, 'UNAUTHORIZED!');
    require(status == RequestStatus.ACCEPTED, 'NOT_APPROVED!');
  }
}
