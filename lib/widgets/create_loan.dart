import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giveback/pages/loans.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateLoanScreen extends StatelessWidget {
  const CreateLoanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CreateLoansBuilder();
  }
}

class CreateLoansBuilder extends StatefulWidget {
  const CreateLoansBuilder({Key? key}) : super(key: key);

  @override
  State<CreateLoansBuilder> createState() => _CreateLoansBuilderState();
}

class _CreateLoansBuilderState extends State<CreateLoansBuilder> {
  Map<String, dynamic> userData = {};
  DateTime? selectedDate;
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemCategoryController = TextEditingController();
  final TextEditingController itemLoanedToController = TextEditingController();
  final TextEditingController itemFinalDateController = TextEditingController();
  final TextEditingController itemObservationsController =
      TextEditingController();

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

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.utc(2000),
      lastDate: DateTime.utc(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future createLoan(String id, DateTime date) async {
    final String name = itemNameController.text;
    final String category = itemCategoryController.text;
    final String loanedTo = itemLoanedToController.text;
    final String observations = itemObservationsController.text;

    await Future.delayed(const Duration(seconds: 1));
    await dotenv.load();

    final dio = Dio();
    dio.options.headers['session_id'] = id;

    final String apiUrl = dotenv.env['API_URL'] ?? '';

    final Map<String, String> data = {
      'borrowedby': id,
      'loanedto': loanedTo,
      'name': name,
      'category': category,
      'observations': observations,
      'finaldate': "$date",
    };

    try {
      final response = await dio.post('$apiUrl/loans', data: data);
      if (response.statusCode == 201) {
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
            content: Text('Registro de empréstimo falhou: $errorMessage'),
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
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registro de Empréstimos',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF439AE0),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          TextField(
            controller: itemNameController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF439AE0),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.text_increase,
                color: Color(0xFF439AE0),
              ),
              labelText: 'Item Emprestado',
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
                  color: Color(0xFF439AE0),
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
            height: 15,
          ),
          TextField(
            controller: itemCategoryController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF439AE0),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.category_outlined,
                color: Color(0xFF439AE0),
              ),
              labelText: 'Categoria',
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
                  color: Color(0xFF439AE0),
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
            height: 15,
          ),
          TextField(
            controller: itemLoanedToController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF439AE0),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.people_outline,
                color: Color(0xFF439AE0),
              ),
              labelText: 'Emprestado Para',
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
                  color: Color(0xFF439AE0),
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
            height: 15,
          ),
          Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: const Color(0xFF439AE0))),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      alignment: AlignmentDirectional.centerStart,
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.date_range_outlined,
                      color: Color(0xFF439AE0),
                      size: 20.0,
                    ),
                    label: Text(
                      selectedDate != null
                          ? formatDate(selectedDate!)
                          : 'Entregar até...',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF439AE0),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => _selectDate(context),
                  ),
                ),
              )),
          const SizedBox(
            height: 15,
          ),
          TextField(
            controller: itemObservationsController,
            maxLines: 3,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF439AE0),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.info_rounded,
                color: Color(0xFF439AE0),
              ),
              labelText: 'Observações',
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
                  color: Color(0xFF439AE0),
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
            height: 15,
          ),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  createLoan(userData['id'], selectedDate ?? DateTime.now());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF439AE0),
                ),
                child: const Text(
                  'Registrar Empréstimo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
        ]);
  }
}
