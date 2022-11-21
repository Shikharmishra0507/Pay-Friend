import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payment/pages/home_page.dart';
import 'package:payment/services/database/bank_details.dart';
import 'package:payment/models/bank.dart';
import 'package:payment/models/users.dart';
import 'package:payment/services/database/user_details.dart';

class NamePage extends StatefulWidget {
  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    initialiseBanksFromFirebase();

    super.didChangeDependencies();
  }

  initialiseBanksFromFirebase() {
    BankDetails().fetchAllBanks().then((value) {
      banksIds = BankDetails().getBankIds();
      setState(() {
        loading = false;
      });
    });
  }

  TextEditingController _nameController = new TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String dropdownValue = "ICCI";
  List<String> banksIds = [];
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: loading
            ? Center(child: CircularProgressIndicator())
            : Stack(children: [
                Positioned.fill(
                    top: 0,
                    left: 0,
                    bottom: 200,
                    child: Container(
                        color: Colors.blueAccent,
                        child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Column(
                                children: [
                                  Text("Welcome!",
                                      style: TextStyle(fontSize: 30)),
                                  SizedBox(
                                    height: 60,
                                  ),
                                ],
                              ),
                            )))),
                Positioned.fill(
                  bottom: 50,
                  top: 120,
                  left: 30,
                  right: 30,
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 500,
                      width: 400,
                      child: Card(
                        color: Colors.blueGrey[100],
                        elevation: 8.0,
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                            "Enter Your Name or Your Shop Name!",
                                            style: TextStyle(fontSize: 14)),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: TextFormField(
                                              controller: _nameController,
                                              validator: (String? value) {
                                                if (value == null ||
                                                    value.isEmpty ||
                                                    value.trim().isEmpty)
                                                  return "Name cannot be empty!";
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                  hintText: "Name..",
                                                  icon: Icon(Icons.person))),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Column(children: [
                                        Text("Select your Bank"),
                                        Center(
                                          child: DropdownButton<String>(
                                            value: dropdownValue,
                                            elevation: 16,
                                            style: const TextStyle(
                                                color: Colors.deepPurple),
                                            underline: Container(
                                              height: 2,
                                              color: Colors.deepPurpleAccent,
                                            ),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                dropdownValue = newValue!;
                                              });
                                            },
                                            items: banksIds
                                                .map<DropdownMenuItem<String>>(
                                                    (String id) {
                                              String name = BankDetails()
                                                  .getBankNameWithId(id);
                                              return DropdownMenuItem<String>(
                                                value: name,
                                                child: Text(name),
                                              );
                                            }).toList(),
                                          ),
                                        )
                                      ]),
                                    )
                                  ],
                                ),
                                SizedBox(height: 50),
                                ElevatedButton(
                                    onPressed: () async {
                                      setState(() {});

                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      _formKey.currentState!.save();
                                      String userBankId = BankDetails()
                                          .getBankIdWithName(dropdownValue);
                                      String userUID = FirebaseAuth
                                          .instance.currentUser!.uid;
                                      String? userPhoneNumber = FirebaseAuth
                                          .instance.currentUser!.phoneNumber;
                                      LocalUser newUser = LocalUser(
                                          userId: userUID,
                                          name: _nameController.text,
                                          bankId: userBankId,
                                          phoneNumber: userPhoneNumber,
                                          transactionList: []);
                                      UserDetails.authorisedUser = newUser;
                                      await UserDetails()
                                          .addUserToDatabase(newUser);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                      );
                                    },
                                    child: Text("Submit"))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]));
  }
}
