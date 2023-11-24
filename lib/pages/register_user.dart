import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:giveback/pages/loans.dart';
import 'package:giveback/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 0),
              child: Image.asset(
                "assets/cadastrese.jpg",
                width: 413,
                height: 457,
              ),
            ),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registre-se',
                        style: TextStyle(
                          color: Color(0xFF439AE0),
                          fontSize: 27,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      RegisterForm()
                    ]))
          ]),
        ));
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _register() async {
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;

    final BuildContext currentContext = context;

    final Map<String, String> data = {
      'name': name,
      'email': email,
      'password': password,
    };

    final dio = Dio();
    const apiUrl = 'https://unifametro-giveback-backend.vercel.app';

    try {
      final response = await dio.post('$apiUrl/users',
          data: data,
          options: Options(headers: {
            'session_id': 's_Zo35Ri6wnbRMfoe2-rFg9D-_HSOT_at6mEKiRerJw'
          }));

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data;
        await saveUserLoggedInState(responseData);

        Navigator.of(currentContext).push(MaterialPageRoute(
          builder: (context) => LoansPage(),
        ));
      } else {
        final dynamic errorData = response.data;
        final String errorMessage = errorData['message'];
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Login falhou: $errorMessage'),
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        // Captura um erro específico do Dio
        if (e.response != null) {
          final dynamic errorData = e.response!.data;
          final String errorMessage = errorData['error'];
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
            ),
          );
        } else {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Text('Erro na solicitação: ${e.message}'),
            ),
          );
        }
      } else {
        // Lidar com outros erros de solicitação, como conexão perdida
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Erro na solicitação: $e'),
          ),
        );
      }
    }
  }

  void _moveToLoginPage() {
    final BuildContext currentContext = context;
    Navigator.of(currentContext).push(MaterialPageRoute(
      builder: (context) => const LoginPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: nameController,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF393939),
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
          decoration: const InputDecoration(
            labelText: 'Nome',
            prefixIcon: Icon(Icons.person, color: Color(0xFF837E93)),
            labelStyle: TextStyle(
              color: Color(0xFF439AE0),
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xFF837E93),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xFF439AE0),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          controller: emailController,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF393939),
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
          decoration: const InputDecoration(
            labelText: 'E-mail',
            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF837E93)),
            labelStyle: TextStyle(
              color: Color(0xFF439AE0),
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xFF837E93),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xFF439AE0),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          controller: passwordController,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF393939),
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
          decoration: const InputDecoration(
            labelText: 'Senha',
            prefixIcon: Icon(Icons.password_outlined, color: Color(0xFF837E93)),
            labelStyle: TextStyle(
              color: Color(0xFF439AE0),
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xFF837E93),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xFF439AE0),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 56,
            child: ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF439AE0),
              ),
              child: const Text(
                'Registre-se',
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
        const SizedBox(
          height: 15,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Já tem uma conta?',
              style: TextStyle(
                color: Color(0xFF837E93),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              width: 2.5,
            ),
            InkWell(
              onTap: () {
                _moveToLoginPage();
              },
              child: const Text(
                'Entrar',
                style: TextStyle(
                  color: Color(0xFF439AE0),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> saveUserLoggedInState(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userDataJson = jsonEncode(userData);
    prefs.setString('userData', userDataJson);
  }
}
