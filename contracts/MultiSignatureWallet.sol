// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./SafeMath.sol";
import "./AccessRegistrySig.sol";

contract MultiSignatureWallet is AccessRegistrySig {
    using SafeMath for uint256;

    struct Transaction {
        bool executed;
        address toAddress;
        uint256 value;
        bytes data;
    }

    uint256 public txnCount;
    mapping(uint256 => Transaction) public txns;
    Transaction[] public _validTransactions;

    mapping(uint256 => mapping(address => bool)) public confirmations;


    fallback() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    receive() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    modifier isOwnerModifier(address owner) {
        require(
            isOwner[owner] == true,
            "You are not authorized for this action."
        );
        _;
    }

    modifier isConfirmedModifier(uint256 txnId, address owner) {
        require(
            confirmations[txnId][owner] == false,
            "You have already confirmed this txn."
        );
        _;
    }

    modifier isExecutedModifier(uint256 txnId) {
        require(
            txns[txnId].executed == false,
            "This txn has already been executed."
        );
        _;
    }


    constructor(address[] memory _owners) AccessRegistrySig(_owners) {}

    function submitTransaction(
        address toAddress,
        uint256 value,
        bytes memory data
    ) public isOwnerModifier(msg.sender) returns (uint256 txnId) {

        txnId = txnCount;

        txns[txnId] = Transaction({
            toAddress: toAddress,
            value: value,
            data: data,
            executed: false
        });


        txnCount += 1;


        emit Submission(txnId);

        confirmTransaction(txnId);
    }


    function confirmTransaction(uint256 txnId)
        public
        isOwnerModifier(msg.sender)
        isConfirmedModifier(txnId, msg.sender)
        notNull(txns[txnId].toAddress)
    {
        // update confirmation
        confirmations[txnId][msg.sender] = true;
        emit Confirmation(msg.sender, txnId);

        executeTransaction(txnId);
    }

  
    function executeTransaction(uint256 txnId)
        public
        isOwnerModifier(msg.sender)
        isExecutedModifier(txnId)
    {
        uint256 count = 0;
        bool authorisationReached;


        for (uint256 i = 0; i < owners.length; i++) {

            if (confirmations[txnId][owners[i]]) count += 1;
            if (count >= authorisation) authorisationReached = true;
        }

        if (authorisationReached) {
            Transaction storage txn = txns[txnId];
            txn.executed = true;
            (bool success, ) = txn.toAddress.call{value: txn.value}(txn.data);

            if (success) {
                _validTransactions.push(txn);
                emit Execution(txnId);
            } else {
                emit ExecutionFailure(txnId);
                txn.executed = false;
            }
        }
    }


    function revokeTransaction(uint256 txnId)
        external
        isOwnerModifier(msg.sender)
        isConfirmedModifier(txnId, msg.sender)
        isExecutedModifier(txnId)
        notNull(txns[txnId].toAddress)
    {
        confirmations[txnId][msg.sender] = false;
        emit Revocation(msg.sender, txnId);
    }

   
    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getValidTransactions()
        external
        view
        returns (Transaction[] memory)
    {
        return _validTransactions;
    }

    function getQuorum() external view returns (uint256) {
        return authorisation;
    }
}