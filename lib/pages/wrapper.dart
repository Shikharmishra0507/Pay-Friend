import 'package:flutter/material.dart';
import 'package:payment/pages/home_page.dart';
import 'package:payment/pages/phone_auth_screen.dart';
import 'package:payment/screen_director/infoToHome.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import './information/name_page.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool permissionGranted = false;
  fetchPermission() async {
    await Permission.contacts.request();
    PermissionStatus permission = await Permission.contacts.status;
    if (permission.isGranted) {
      setState(() {
        permissionGranted = true;
      });
      // permissionGranted = true;
    } else if (permission.isDenied) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<User?>(context);
    
    return auth == null ? const PhoneAuthScreen() :InfoToTest();
  }
}
