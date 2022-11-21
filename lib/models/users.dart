import 'package:flutter/cupertino.dart';

import './transactions.dart';

class LocalUser {
  String? userId;
  String? phoneNumber;
  String? name;
  List<UserTransaction>? transactionList = [];
  String? bankId;

  LocalUser(
      {this.userId,
      this.name,
      this.transactionList,
      this.bankId,
      required this.phoneNumber});

  factory LocalUser.fromJson(Map<String, dynamic> json) {
    List<UserTransaction> transaction = [];
    if (json["transactionList"] != null) {
      json["transactionList"].forEach((element) {
        transaction.add(UserTransaction.fromJson(element));
      });
    }
    return LocalUser(
        userId: json["userId"],
        phoneNumber: json["phoneNumber"],
        bankId: json["bankId"],
        name: json["name"],
        transactionList: transaction);
  }

  Map<String, dynamic> toJson(LocalUser user) {
    List<Map<String, dynamic>> transactions = [];
    user.transactionList!.forEach((trans) {
      Map<String, dynamic> transInJson = UserTransaction().toJson(trans);
      transactions.add(transInJson);
    });
    return {
      "userId": user.userId!,
      "name": user.name,
      "transactionList": transactions,
      "bankId": user.bankId,
      "phoneNumber": user.phoneNumber,
    };
  }
}
