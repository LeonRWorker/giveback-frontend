import 'package:flutter/material.dart';
import 'package:giveback/pages/loans.dart';
import 'package:giveback/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool userData = await checkUserLoggedIn();
  runApp(GiveBackApp(userData: userData));
}

class GiveBackApp extends StatelessWidget {
  final dynamic userData;
  const GiveBackApp({Key? key, required this.userData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GiveBack App',
      debugShowCheckedModeBanner: false,
      home: userData
          ? const LoansPage(
              userData: [],
            )
          : const LoginPage(),
    );
  }
}

Future<bool> checkUserLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userData = prefs.getString('userData');
  return userData != null ? true : false;
}
