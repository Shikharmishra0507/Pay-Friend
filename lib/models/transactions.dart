class UserTransaction {
  String? senderId;
  String? receiverId;
  double? amount;
  String? status;
  String? expenseCategory;
  UserTransaction(
      {this.senderId,
      this.receiverId,
      this.amount,
      this.status,
      this.expenseCategory});

  Map<String, dynamic> toJson(UserTransaction transaction) {
    return {
      "senderId": transaction.senderId,
      "recieverId": transaction.receiverId,
      "amount": transaction.amount,
      "status": transaction.status,
      "expenseCategory": transaction.expenseCategory == null
          ? "Miscelleanous"
          : transaction.expenseCategory
    };
  }

  factory UserTransaction.fromJson(Map<String, dynamic> json) {
    print(json);
    return UserTransaction(
        senderId: json["senderId"],
        receiverId: json["recieverId"],
        amount: json["amount"],
        status: json["status"],
        expenseCategory:  json["expenseCategory"] == null
            ? "Miscelleanous"
            : json["expenseCategory"]);
  }
}
