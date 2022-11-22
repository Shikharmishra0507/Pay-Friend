import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:payment/services/database/user_details.dart';

class UserBankDetails {
  String? id;
  String? amount;
  UserBankDetails({this.id, this.amount});

  Map<String, dynamic> toJson(UserBankDetails details) {
    return {"id": details.id, "amount": details.amount};
  }
}

class UserBankDetailsProvider with ChangeNotifier {
  CollectionReference reference =
      FirebaseFirestore.instance.collection("userBanks");

  Future<void> addUserBankDetail(String? uid, String? amount) async {
    try {
      Map<String, dynamic> userBankDetails = {"id": uid, "amount": amount};
      await reference.doc(uid).set(userBankDetails);
    } on Exception catch (e) {
      // TODO
      print(e);
    }
    return;
  }

  Future<bool> AddTransaction(String senderId, String receieverId,
      String amount, String senderBankId, String recieverBankId) async {
    bool senderSufficientBanBalance =
        await validateTransaction(senderId, senderBankId, amount);
    if (!senderSufficientBanBalance) {
      throw Exception("Insufficient Balance");
      
    }
    double c = double.parse(amount);

    bool error = false;
    try {
      await changeTransactionAmount(senderId, senderBankId, c, true);
      await changeTransactionAmount(receieverId, recieverBankId, c, false);
    } on Exception catch (e) {
      error = true;
      print("error in user bank detail add transaction");
      // TODO
    }
    return !error;
  }

  Future<bool> validateTransaction(
      String senderId, String senderBankId, String amount) async {
    try {
      DocumentSnapshot snapshot =
          await reference.doc(senderId + senderBankId).get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      double amountFromDatabase = double.parse(data["amount"]);
      double amountinINT = double.parse(amount);
      if (amountFromDatabase >= amountinINT) return true;
    } on Exception catch (e) {
      // TODO

      print("Error in user bank provider validate transaction");
      return false;
    }

    return false;
  }

  Future<void> changeTransactionAmount(
      String userId, String bankId, double amount, bool deduct) async {
    DocumentSnapshot snapshot = await reference.doc(userId + bankId).get();
    print("here");
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    double currentAmount = double.parse(data["amount"]);
    
    if (deduct) {
      currentAmount -= amount;
    } else {
      currentAmount += amount;
    }
    
    data["amount"] = currentAmount.toString();
    await reference.doc(userId + bankId).set(data);
  }
}
