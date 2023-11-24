import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giveback/pages/loans.dart';
import 'package:giveback/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const User();
  }
}

class User extends StatefulWidget {
  const User({Key? key}) : super(key: key);
  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  Map<String, dynamic> userData = {};

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  Future getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('userData');
    setState(() {
      userData = userDataJson != null ? jsonDecode(userDataJson) : null;
      String name = userData['name'] ?? '';
      String email = userData['email'] ?? '';
      _nameController.text = name;
      _emailController.text = email;
    });
  }

  Future<void> saveUserLoggedInState(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userDataJson = jsonEncode(userData);
    prefs.setString('userData', userDataJson);
  }

  Future updateUser(String id) async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    await Future.delayed(const Duration(seconds: 1));
    await dotenv.load();

    final dio = Dio();
    dio.options.headers['session_id'] = id;

    final String apiUrl = dotenv.env['API_URL'] ?? '';

    final Map<String, String> data = {
      'name': name,
      'email': email,
      'password': password,
    };

    try {
      final response = await dio.put('$apiUrl/users/$id', data: data);
      if (response.statusCode == 200) {
        setState(() {
          userData['name'] = name;
          userData['email'] = email;
        });
        await saveUserLoggedInState(userData);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoansPage(),
            ));
      } else {
        final dynamic errorData = response.data;
        final String errorMessage = errorData['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Alteração dos datalhes do usuário falhou: $errorMessage'),
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        // Captura um erro específico do Dio
        if (e.response != null) {
          final dynamic errorData = e.response!.data;
          final String errorMessage = errorData['error'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro na solicitação: ${e.message}'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na solicitação: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Text('Configurações',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Container(
            width: MediaQuery.of(context).size.width * 1 - 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Nome',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Color(0xFF837E93)),
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFA0A0A0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFA0A0A0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('E-mail',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.email_outlined, color: Color(0xFF837E93)),
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFA0A0A0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFA0A0A0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Senha',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.password_outlined, color: Color(0xFF837E93)),
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFA0A0A0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        width: 1,
                        color: Color(0xFFA0A0A0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width * 1 - 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ElevatedButton.icon(
                onPressed: () {
                  updateUser(userData['id']);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  backgroundColor: const Color(0xFF439AE0),
                ),
                icon: const Icon(
                  Icons.save_rounded,
                  color: Colors.white,
                  size: 20.0,
                ),
                label: const Text(
                  'Salvar Alterações',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width * 1 - 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ElevatedButton.icon(
                onPressed: () {
                  _logout(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  backgroundColor: const Color(0xFFFE5858),
                ),
                icon: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.white,
                  size: 20.0,
                ),
                label: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
