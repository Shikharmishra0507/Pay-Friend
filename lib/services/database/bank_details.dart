import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payment/models/bank.dart';

class BankDetails {
  static List<Bank> banks = [];
  CollectionReference reference =
      FirebaseFirestore.instance.collection("banks");
  // Future<List<String>>getBankNames()async{

  // }
  List<String> getBankIds() {
    List<String> ids = [];
    banks.forEach((bank) {
      ids.add(bank.id!);
    });
    return ids;
  }

  Future<void> addUserToBank(String bankId, String userId) async {
    //fetch local data and then update in database
    try {
      DocumentReference docReference = reference.doc(bankId);
      DocumentSnapshot snapshot = await docReference.get();
      Map<String, dynamic> bankData = snapshot.data() as Map<String, dynamic>;
      Bank bankDataFromDatabase = Bank.fromJson(bankData);
      bankDataFromDatabase.registeredUsersIds.add(userId);
      Map<String, dynamic> bankJsonData = Bank.toJson(bankDataFromDatabase);

      await reference.doc(bankId).set(bankJsonData);

      updateBankWithId(bankId, bankDataFromDatabase);
    } catch (e) {
      print(e);
    }
  }

  void updateBankWithId(String bankId, Bank updatedBank) {
    int index = getBankIndexWithId(bankId);
    banks[index] = updatedBank;
  }

  int getBankIndexWithId(String id) {
    return banks.indexWhere((bank) {
      return bank.id == id;
    });
  }

  String getBankNameWithId(String id) {
    return banks.firstWhere((bank) {
      return bank.id == id;
    }).name!;
  }

  String getBankIdWithName(String name) {
    return banks.firstWhere((bank) {
      return bank.name == name;
    }).id!;
  }

  Future<void> fetchAllBanks() async {
    QuerySnapshot snapshot = await reference.get();
    List<DocumentSnapshot> documents = snapshot.docs;
    List<Bank> banksFromDatabase = [];
    documents.forEach((bank) {
      Map<String, dynamic> bankDataInJson =
          Map<String, dynamic>.from(bank.data() as Map<String, dynamic>);

      Bank bankData = Bank.fromJson(bankDataInJson);
      banksFromDatabase.add(bankData);
    });

    banks = banksFromDatabase;
  }

  List<String> getBanksNames() {
    List<String> bankNames = [];

    banks.forEach((bank) {
      bankNames.add(bank.name!);
    });
    return bankNames;
  }

  Future<void> addBankToDatabase(Bank bank) async {}
}
