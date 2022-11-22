class UserTransaction {
  String? senderId;
  String? receiverId;
  double? amount;
  String? status;
  List<String>? expenseCategory;
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
          ? ["Miscelleanous"]
          : transaction.expenseCategory
    };
  }

  factory UserTransaction.fromJson(Map<String, dynamic> json) {
    List<String> expenses = [];
    if (json["expenseCategory"] == null) expenses = [];
    else expenses = List<String>.from(json["expenseCategory"]);

    return UserTransaction(
        senderId: json["senderId"],
        receiverId: json["recieverId"],
        amount: json["amount"].toDouble(),
        status: json["status"],
        expenseCategory: expenses);
  }
}
