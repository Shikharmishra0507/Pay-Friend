import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({Key? key}) : super(key: key);

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  TextEditingController _nameController = new TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Form(
      key: _formKey,
      child: Column(
        children: [
          Column(
            children: [
              Text("Name"),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                  controller: _nameController,
                  validator: (String? value) {
                    if (value == null || value.isEmpty)
                      return "Name cannot be empty!";
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "Enter your name", icon: Icon(Icons.person))),
            ],
          ),
          SizedBox(height: 50),
          ElevatedButton(
              onPressed: () async{
                if (!_formKey.currentState!.validate()) return;
                _formKey.currentState!.save();
                User? user = FirebaseAuth.instance.currentUser;
                Map<String, dynamic> userData = {
                  'uid': user!.uid,
                  'name': _nameController.text,
                };
                await firestore.collection("users").doc(user!.uid).set(userData);
              },
              child: Text("Submit"))
        ],
      ),
    ));
  }
}
