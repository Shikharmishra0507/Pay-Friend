import 'package:flutter/material.dart';

import 'package:payment/models/userBankDetails.dart';
import 'package:payment/services/database/user_details.dart';
import '../models/transactions.dart';

class PayViaPhoneNumber extends StatefulWidget {
  PayViaPhoneNumber(
      {super.key,
      this.recieverUserId,
      this.senderUserId,
      this.recieverBankId,
      this.senderBankId});
  String? recieverUserId;
  String? senderUserId;
  String? recieverBankId;
  String? senderBankId;
  @override
  State<PayViaPhoneNumber> createState() => _PayViaPhoneNumberState();
}

class _PayViaPhoneNumberState extends State<PayViaPhoneNumber> {
  Map<String, bool> transactionsListStatus = {
    "Grocery": false,
    "Food": false,
    "Shopping": false,
    "Study": false,
    "Business": false,
    "Outing": false,
    "Productive": false,
    "Household": false,
    "Miscelleanous": false
  };
  List<String> transactionsList = [
    "Grocery",
    "Food",
    "Shopping",
    "Study",
    "Business",
    "Outing",
    "Productive",
    "Household",
    "Miscelleanous"
  ];
  bool isLoading = false;
  TextEditingController _phoneNumber = TextEditingController();
  TextEditingController _amount = TextEditingController();
  bool validatedInputFields() {
    return _phoneNumber.text.isEmpty == false && _amount.text.isEmpty == false;
  }

  void submit(BuildContext context) async {
    if (!validatedInputFields()) {
      showSnackbar(context, "Invalid inputs", true);
      return;
    }
    String? recieverId =
        await UserDetails().getUserIdWithphoneNumber(_phoneNumber.text);
    print(recieverId);
    if (recieverId == null) {
      showSnackbar(
          context, "Could not find any user with this phoneNumber", true);
      return;
    }
    setState(() {
      isLoading = true;
    });
    String? recieverBankId =
        await UserDetails().getUserBankAccountIdWithUserId(recieverId);
    if (recieverBankId == null) {
      showSnackbar(context, "Invalid reciever bank Account", true);
      return;
    }
    try {
      await UserBankDetailsProvider().AddTransaction(widget.senderUserId!,
          recieverId, _amount.text, widget.senderBankId!, recieverBankId);
      double amountInDouble = double.parse(_amount.text);
      UserTransaction senderTransaction = UserTransaction(
          senderId: widget.senderBankId,
          receiverId: recieverId,
          amount: amountInDouble,
          status: "Success");
      await UserDetails()
          .setUserTransactionId(senderTransaction, widget.senderUserId!);


UserTransaction receiverTransaction = UserTransaction(
          senderId: widget.senderBankId,
          receiverId: recieverId,
          amount: amountInDouble,
          status: "Success");
      await UserDetails()
          .setUserTransactionId(receiverTransaction, recieverId);

    } on Exception catch (e) {
      showSnackbar(context, e.toString(), true);
      // TODO
    }

    /// add sender transactions list and reciver transactions list
    setState(() {
      isLoading = false;
    });
    showSnackbar(context, "Successfull Transaction", false);
  }

  void showSnackbar(BuildContext context, String text, bool error) {
    var snackBar = SnackBar(
      content: Text(text),
      backgroundColor: error ? Colors.red : Colors.green,
      duration: const Duration(seconds: 10),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("PAY WITH PHONE NUMBER"),
          leading: IconButton(
            icon: Icon(Icons.arrow_left_sharp),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              child: Center(
                  child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _phoneNumber,
                    decoration:
                        InputDecoration(hintText: "Add reciever phone number"),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                      controller: _amount,
                      decoration: InputDecoration(hintText: "Enter Amount")),
                  SizedBox(height: 30),
                  Wrap(
                    spacing: 10.0,
                    runSpacing: 8.0,
                    children: transactionsList.map((element) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            transactionsListStatus[element] =
                                !transactionsListStatus[element]!;
                          });
                        },
                        child: Container(
                            width: 120,
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: transactionsListStatus[element] == false
                                    ? Colors.lightBlue
                                    : Colors.green,
                                border: Border.all(style: BorderStyle.solid)),
                            child: Center(
                                child: Text(
                              element,
                              style: TextStyle(color: Colors.white),
                            ))),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        submit(context);
                      },
                      child: Text("Send"))
                ],
              ),
            ))),
    );
  }
}
