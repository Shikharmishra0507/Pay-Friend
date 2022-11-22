import 'package:firebase_auth/firebase_auth.dart';
import 'package:payment/models/transactions.dart';
import 'package:payment/models/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payment/services/database/bank_details.dart';
import '../contacts.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:payment/models/userBankDetails.dart';

class UserDetails {
  CollectionReference reference =
      FirebaseFirestore.instance.collection("users");
  List<LocalUser> _allConnectedUsers = [];
  static LocalUser? authorisedUser = null;
  LocalUser get getCurrentUser {
    return authorisedUser!;
  }

  List<LocalUser> get getAllConnectedUsers {
    return _allConnectedUsers;
  }

  void setCurrentUser(LocalUser user) {
    authorisedUser = user;
  }

  Future<String?>? userInDatabase() async {
    String id = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot snapshot = await reference.doc(id).get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    if (data == null) return null;

    return data["phoneNumber"];
  }

  void registerCurrentUserId() {}

  Future<String?> getUserBankAccountIdWithUserId(String id) async {
    try {
      DocumentSnapshot snapshot = await reference.doc(id).get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data["bankId"];
    } on Exception catch (e) {
      // TODO
      print("error in user dteail fetching bank id with id");
    }
    return null;
  }

  Future<String> getUserPhoneNumberIdWithUserId(String id) async {
    DocumentSnapshot snapshot = await reference.doc(id).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return data["phoneNumber"];
  }

  Future<String?> getUserIdWithphoneNumber(String phoneNumber) async {
    // String phoneNumberWithoutSTDCodes=phoneNumber.substring(3)
    print(phoneNumber);
    QuerySnapshot snapshot = await reference.get();
    List<DocumentSnapshot> documents = snapshot.docs;
    String? uid;
    documents.forEach((user) {
      Map<String, dynamic> userDataInJson =
          Map<String, dynamic>.from(user.data() as Map<String, dynamic>);
      String numberFromFirebase = userDataInJson['phoneNumber'];

      String numberFromFirebaseWithoutSTD = numberFromFirebase.substring(3);
      if (phoneNumber.compareTo(numberFromFirebase) == 0 ||
          phoneNumber.compareTo(numberFromFirebaseWithoutSTD) == 0) {
        uid = userDataInJson["userId"];
      }
    });
    print("uid");
    return uid;
  }

  Future<void> setUserTransactionId(
      UserTransaction transaction, String id) async {
    DocumentSnapshot snapshot = await reference.doc(id).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    List<dynamic> transactionsList =
        data["transactionList"] == null ? [] : data["transactionList"];

    Map<String, dynamic> transactionInJson =
        UserTransaction().toJson(transaction);
    transactionsList.add(transactionInJson);
    data["transactionList"] = transactionsList;
    await reference.doc(id).set(data);
  }

  Future<void> addUserToDatabase(LocalUser user) async {
    try {
      Map<String, dynamic> userData = authorisedUser!.toJson(user);
      await reference.doc(user.userId).set(userData);
      await BankDetails().addUserToBank(user.bankId!, user.userId!);
      String userBankDetailsId = user.userId! + user.bankId!;
      await UserBankDetailsProvider()
          .addUserBankDetail(userBankDetailsId, "20000");
    } on Exception catch (e) {
      // TODO
      print(e);
    }
    return;
  }

  Future<List<UserTransaction>> getUserTransactions(String id) async {
    DocumentSnapshot snapshot = await reference.doc(id).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    List<UserTransaction> transactionList = [];

    data["transactionList"].forEach((element) {
      Map<String, dynamic> curr = element as Map<String, dynamic>;
      UserTransaction transaction = UserTransaction.fromJson(curr);
      transactionList.add(transaction);
    });
    return transactionList;
  }

  Future<List<LocalUser>> fetchAllRegisteredUsers() async {
    Set<String> _phonesSet = {};
    try {
      List<Item> _phones = await Contacts().requiredPhoneNumbers();

      for (int i = 0; i < _phones.length; i++) {
        _phonesSet.add(_phones[i].value.toString());
      }
    } on Exception catch (e) {
      // TODO
      throw e;
    }
    QuerySnapshot snapshot = await reference.get();
    List<DocumentSnapshot> documents = snapshot.docs;
    List<LocalUser> usersFromDatabase = [];
    documents.forEach((user) {
      Map<String, dynamic> userDataInJson =
          Map<String, dynamic>.from(user.data() as Map<String, dynamic>);
      LocalUser userData = LocalUser.fromJson(userDataInJson);

      usersFromDatabase.add(userData);
    });
    _allConnectedUsers = usersFromDatabase;
    return usersFromDatabase;
  }
}
