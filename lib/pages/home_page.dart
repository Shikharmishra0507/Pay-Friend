import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import '../services/contacts.dart';
import 'package:permission_handler/permission_handler.dart';

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

  //Function to import contacts
  getContacts() async {
    PermissionStatus contactsPermissionsStatus = await _contactsPermissions();
    if (contactsPermissionsStatus == PermissionStatus.granted) {
      List<Item> contacts = await Contacts().requiredPhoneNumbers();
      setState(() {
        _contacts = contacts;
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(title: Text("Pay-Friend"),),
        drawer: Drawer(
          child: SingleChildScrollView(
              child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: (){}, child: Text("Profile")),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: (){}, child: Text("My Expenses")),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: (){}, child: Text("My QR")),
            ],
          )),
        ),
        body: Container(
          child: Column(
            children: [
              Container(
                width: size.width,
                height: size.height * 0.1,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding:EdgeInsets.all(10.0),
                        child: Card(
                      child: Center(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(options[index]),
                      )),
                    ));
                  },
                  itemCount: options.length,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text("Contacts",style: TextStyle(fontSize: 25),),
              SizedBox(height:30,),
              if (_contactsLoading) Center(child: CircularProgressIndicator()),
              if (!_contactsLoading &&
                  (_contacts == null || _contacts!.length == 0))
                Center(child: Text("No Contacts")),
              if (!_contactsLoading && _contacts != null)
                SingleChildScrollView(
                    child: Column(
                  children: _contacts!.map((phone) {
                    return Padding(padding:EdgeInsets.all(16) ,child:Card(elevation:5,child:Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(phone.value.toString()),
                    )));
                  }).toList(),
                ))
            ],
          ),
        ));
  }
}
