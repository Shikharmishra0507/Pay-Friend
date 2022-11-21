import 'package:flutter/cupertino.dart';

class InformationPageIndex extends ChangeNotifier {
  int pageIndex = 0;
  void increasePageCounter() {
    pageIndex = pageIndex + 1;
    notifyListeners();
  }

  void decreasePageCounter() {
    pageIndex = pageIndex - 1;
    notifyListeners();
  }
}
