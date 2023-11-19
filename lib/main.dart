import 'package:flutter/material.dart';
import 'package:giveback/pages/loans.dart';
import 'package:giveback/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await checkUserLoggedIn();
  runApp(GiveBackApp(isLoggedIn: isLoggedIn));
}

class GiveBackApp extends StatelessWidget {
  final bool isLoggedIn;
  const GiveBackApp({Key? key, required this.isLoggedIn}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GiveBack App',
      debugShowCheckedModeBanner: false,
      home: isLoggedIn
          ? const LoansPage(
              userData: [],
            )
          : const LoginPage(),
    );
  }
}

Future<bool> checkUserLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  return isLoggedIn;
}
