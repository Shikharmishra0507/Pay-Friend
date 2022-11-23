pragma solidity >=0.4.22 <0.7.0;
contract TransactionList {
    uint256 public transactionCount;

    struct UserTransaction {
        string transactionId;
        string senderId;
        string recieverId;
        string senderBankId;
        string recieverBankId;
        string amount;
    }

    mapping(uint256 => UserTransaction) public transactions;

    event TransactionCreated(string transactionId,string senderId , string senderBankId,string recieverId,string recieverBankId,string amount ,uint256 taskNumber);

    constructor() public {
        transactions[0]=UserTransaction("1","11","112","221","22","100");

        transactionCount = 1;
    }

    function createTransaction(string memory _transactionId  , string memory _senderId,string memory _senderBankId,string memory _recieverId,string memory _recieverBankId,string memory _amount ) public {
       
        transactions[transactionCount++]=UserTransaction(_transactionId,_senderId,_senderBankId,_recieverId,_recieverBankId,_amount);
       
        emit TransactionCreated(_transactionId,_senderId,_senderBankId,_recieverId,_recieverBankId,_amount, transactionCount - 1);
    }
}