import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:payment/models/transaction_block_model.dart';
import 'package:payment/models/users.dart';
import 'package:payment/pages/expense_page.dart';
import 'package:payment/pages/pay_via_phone_number.dart';
import 'package:payment/pages/pay_via_qr.dart';
import 'package:payment/pages/qr_generator.dart';
import 'package:payment/pages/scan_qr.dart';
import 'package:payment/services/authentication.dart';
import '../services/contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/database/user_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void showSnackbar(BuildContext context, String text, bool error) {
    var snackBar = SnackBar(
      content: Text(text),
      backgroundColor: error ? Colors.red : Colors.green,
      duration: const Duration(seconds: 10),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  List<Item>? _contacts;
  bool _contactsLoading = false;

  // Function to get permission from the user

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  _contactsPermissions() async {
    await Permission.contacts.request();
    PermissionStatus permission = await Permission.contacts.status;

    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.limited;
    } else {
      return permission;
    }
  }

  List<LocalUser> users = [];
  //Function to import contacts
  getContacts() async {
    PermissionStatus contactsPermissionsStatus = await _contactsPermissions();
    if (contactsPermissionsStatus == PermissionStatus.granted) {
      List<Item> contacts = await Contacts().requiredPhoneNumbers();

      List<LocalUser> temp = await UserDetails().fetchAllRegisteredUsers();
      setState(() {
        users = temp;
        print(users);
        users.forEach((element) {
          print(element.name!);
        });
      });
    }
  }

  @override
  void didChangeDependencies() {
    getContacts();

    super.didChangeDependencies();
  }

  List<String> options = [
    'Pay via Phone Number',
    'Pay via QR',
    'Manage Expenses',
  ];
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return  Scaffold(
            appBar: AppBar(
              title: Text("Pay-Friend"),
              actions: [
                IconButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await getContacts();
                      setState(() {
                        isLoading = false;
                      });
                    },
                    icon: Icon(Icons.refresh))
              ],
            ),
            drawer: Drawer(
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await Authentication().signOut();
                      },
                      child: Text("Logout")),
                      SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        // Navigator.push(
                        //                             context,
                        //                             MaterialPageRoute(
                        //                                 builder: (context) =>
                        //                                     GenerateQR()),
                        //                           );
                      },
                      child: Text("Generate QR")),
                ],
              )),
            ),
            body: Container(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: size.width,
                            height: size.height * 0.1,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Card(
                                        child: ElevatedButton(
                                            child: Center(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(options[index]),
                                            )),
                                            onPressed: () {
                                              switch (index) {
                                                case 0:
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PayViaPhoneNumber()),
                                                  );
                                                  break;
                                                case 1:
                                                  // Navigator.push(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //       builder: (context) =>
                                                  //           ScanQR()),
                                                  // );
                                                  break;
                                                case 2:
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ExpensePage()),
                                                  );
                                                  break;
                                              }
                                            })));
                              },
                              itemCount: options.length,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Contacts",
                            style: TextStyle(fontSize: 25),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          if (_contactsLoading)
                            Center(child: CircularProgressIndicator()),
                          if (!_contactsLoading &&
                              (users == null || users.length == 0))
                            Center(child: Text("No Contacts")),
                          if (!_contactsLoading && users != null)
                            SingleChildScrollView(
                                child: Column(
                              children: users.map((user) {
                                return GestureDetector(
                                  onTap: () async {
                                    String? senderBankId = await UserDetails()
                                        .getUserBankAccountIdWithUserId(
                                            currentUserId);
                                    if (senderBankId == null) {
                                      showSnackbar(
                                          context,
                                          "No bank account with this user",
                                          true);
                                      return;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PayViaPhoneNumber(
                                                phoneNumber: user.phoneNumber,
                                                senderUserId: currentUserId,
                                                senderBankId: senderBankId,
                                              )),
                                    );
                                  },
                                  child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Card(
                                          elevation: 5,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Text(user.name!),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Text(user.phoneNumber!),
                                              )
                                            ],
                                          ))),
                                );
                              }).toList(),
                            )),
                        ],
                      ),
                    ),
            ));
  }
}
