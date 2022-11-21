import 'package:payment/models/transactions.dart';
import 'package:payment/services/database/user_details.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ExpensePage extends StatefulWidget {
  ExpensePage({Key? key}) : super(key: key);
  List<UserTransaction>? transactionsList;
  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  bool emptyTransaction = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    getAllTransactions();
  }

  bool isLoading = false;
  Map<String, double> dataMap = {};
  List<UserTransaction> transactions = [];
  void getAllTransactions() async {
    setState(() {
      isLoading = true;
    });
    String uid = FirebaseAuth.instance.currentUser!.uid;
    transactions = await UserDetails().getUserTransactions(uid);
    setState(() {
      isLoading = false;
    });

    if (transactions == null || transactions!.length == 0) {
      emptyTransaction = true;
      print("here");
    } else {
      emptyTransaction = false;
      transactions.forEach((UserTransaction transaction) {
        dataMap[transaction.expenseCategory!] = transaction.amount!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("YOUR EXPENSES"),
          leading: IconButton(
            icon: Icon(Icons.arrow_left_sharp),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: emptyTransaction
          ? Center(
              child: Text("No Transactions"),
            )
          : Container(
              child: PieChart(dataMap: dataMap),
            ),
    );
  }
}