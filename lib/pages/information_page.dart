import 'package:flutter/material.dart';
import './information/name_page.dart';
import './information/bank_selection_page.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({Key? key}) : super(key: key);

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  int pageIndex = 0;
  List<Widget> showPage = [NamePage(), BankSelectionPage()];

  @override
  Widget build(BuildContext context) {
    return Container(
      height:800,
      child: Column(
        children: [

          showPage[pageIndex],

          ElevatedButton(
              onPressed: () {
                pageIndex += 1;
              },
              child: Text("Submit"))
        ],
      ),
    );
  }
}
