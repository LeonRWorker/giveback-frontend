import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:giveback/widgets/create_loan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopBarScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const TopBarScreen({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TopBarBuilder(userData: userData);
  }
}

class TopBarBuilder extends StatefulWidget {
  final Map<String, dynamic> userData;

  const TopBarBuilder({Key? key, required this.userData}) : super(key: key);

  @override
  State<TopBarBuilder> createState() => _TopBarBuilderState();
}

class _TopBarBuilderState extends State<TopBarBuilder> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('userData');
    setState(() {
      userData = userDataJson != null ? jsonDecode(userDataJson) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Devolva-me',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFFFFF),
          ),
          icon: const Icon(
            Icons.add_to_photos,
            color: Color(0xFF439AE0),
            size: 20.0,
          ),
          label: const Text(
            'Registrar',
            style: TextStyle(
              color: Color(0xFF439AE0),
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () => {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => Dialog(
                child: createLoan(context),
              ),
            ),
          },
        ),
      ],
    );
  }

  Widget createLoan(BuildContext context) {
    return Container(
        height: 500,
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: const CreateLoanScreen());
  }
}
