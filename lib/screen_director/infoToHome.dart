import 'package:flutter/material.dart';
import 'package:payment/models/transaction_block_model.dart';
import 'package:payment/pages/home_page.dart';
import 'package:payment/pages/information/name_page.dart';
import 'package:payment/services/database/user_details.dart';
import 'package:provider/provider.dart';

class InfoToTest extends StatefulWidget {
  @override
  _InfoToTestState createState() => _InfoToTestState();
}

class _InfoToTestState extends State<InfoToTest> {
  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<String?>(
            future: UserDetails().userInDatabase(),
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              switch (snapshot.connectionState) {
                case (ConnectionState.waiting):
                  {
                    return CircularProgressIndicator();
                  }
                default:
                  {
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      if (snapshot == null ||
                          snapshot.data == null ||
                          !snapshot.hasData) {
                        return NamePage();
                      } else {
                        return HomePage();
                      }
                    }
                  }
              }
            });
  }
}
