import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giveback/pages/loans.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateLoanScreen extends StatelessWidget {
  final Map<String, dynamic> loanData;
  const UpdateLoanScreen({Key? key, required this.loanData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UpdateLoansBuilder(
      loanData: loanData,
    );
  }
}

class UpdateLoansBuilder extends StatefulWidget {
  final Map<String, dynamic> loanData;
  const UpdateLoansBuilder({Key? key, required this.loanData})
      : super(key: key);

  @override
  State<UpdateLoansBuilder> createState() => _UpdateLoansBuilderState();
}

class _UpdateLoansBuilderState extends State<UpdateLoansBuilder> {
  Map<String, dynamic> userData = {};
  Map<String, dynamic> loanData = {};
  DateTime? selectedDate;
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemCategoryController = TextEditingController();
  final TextEditingController itemLoanedToController = TextEditingController();
  final TextEditingController itemObservationsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData();
    setState(() {
      itemNameController.text = widget.loanData['name'];
      itemCategoryController.text = widget.loanData['category'];
      itemLoanedToController.text = widget.loanData['loanedto'];
      selectedDate = DateTime.parse(widget.loanData['finaldate']);
      itemObservationsController.text = widget.loanData['observations'];
    });
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

  Future updateLoan(String id, DateTime date) async {
    final String name = itemNameController.text;
    final String category = itemCategoryController.text;
    final String loanedTo = itemLoanedToController.text;
    final String observations = itemObservationsController.text;

    await Future.delayed(const Duration(seconds: 1));
    await dotenv.load();

    final dio = Dio();
    dio.options.headers['session_id'] = userData['id'];

    final String apiUrl = dotenv.env['API_URL'] ?? '';

    final Map<String, String> data = {
      'loanedto': loanedTo,
      'name': name,
      'category': category,
      'observations': observations,
      'finaldate': "$date",
    };

    try {
      final response = await dio.put('$apiUrl/loans/$id', data: data);
      if (response.statusCode == 200) {
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
            content: Text('Atualização do empréstimo falhou: $errorMessage'),
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        // Captura um erro específico do Dio
        if (e.response != null) {
          final dynamic errorData = e.response!.data;
          final String errorMessage = errorData['error'];
          print(errorData);
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

  Future deleteLoan(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    await dotenv.load();

    final dio = Dio();
    dio.options.headers['session_id'] = userData['id'];

    final String apiUrl = dotenv.env['API_URL'] ?? '';

    try {
      final response = await dio.delete('$apiUrl/loans/$id');
      if (response.statusCode == 202) {
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
            content: Text('Remoção do empréstimo falhou: $errorMessage'),
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        // Captura um erro específico do Dio
        if (e.response != null) {
          final dynamic errorData = e.response!.data;
          final String errorMessage = errorData['error'];
          print(errorData);
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

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Você tem certeza de que deseja continuar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog
              },
              child: const Text('Não'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteLoan(widget.loanData['id']);
                Navigator.of(context).pop();
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Atualização das Informações',
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
                  updateLoan(
                      widget.loanData['id'], selectedDate ?? DateTime.now());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF439AE0),
                ),
                child: const Text(
                  'Atualizar Informações',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Remover Empréstimo',
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
