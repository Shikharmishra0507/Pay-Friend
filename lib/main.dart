import 'package:flutter/material.dart';
import 'pages/phone_auth_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  final Map<int, Color> _yellow700Map = {
    50: Color.fromARGB(255, 19, 94, 181),
    100: Colors.blue[100]!,
    200: Colors.blue[200]!,
    300: Colors.blue[300]!,
    400: Colors.blue[400]!,
    500: Colors.blue[500]!,
    600: Colors.blue[600]!,
    700: Colors.blue[800]!,
    800: Colors.blue[900]!,
    900: Colors.blue[700]!,
  };

  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MaterialColor(Colors.blue[600]!.value, _yellow700Map),
      ),
      home: PhoneAuthScreen(),
    );
  }
}
