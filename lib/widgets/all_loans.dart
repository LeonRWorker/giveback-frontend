import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giveback/pages/loans.dart';
import 'package:giveback/widgets/update_loan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoansScreen extends StatelessWidget {
  final Map<String, dynamic> loan;
  const LoansScreen({Key? key, required this.loan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoansBuilder(loan: loan);
  }
}

class LoansBuilder extends StatefulWidget {
  final Map<String, dynamic> loan;

  const LoansBuilder({Key? key, required this.loan}) : super(key: key);

  @override
  State<LoansBuilder> createState() => _LoansBuilderState();
}

class _LoansBuilderState extends State<LoansBuilder> {
  Map<String, dynamic> userData = {};
  late String formattedDate;
  late String statusText;

  String _formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDateMessage() {
    switch (widget.loan['status']) {
      case 'inday':
        return 'Entregar até $formattedDate';
      case 'returned':
        return 'Entregue em $formattedDate';
      case 'late':
        return 'Atrasado desde $formattedDate';
      default:
        return 'Data desconhecida';
    }
  }

  String _getMessageOnDimissed(Map<String, dynamic> loan) {
    return loan['status'] == 'inday'
        ? 'Finalizar'
        : loan['status'] == 'returned'
            ? 'Atrasar'
            : 'Aguardar';
  }

  void getBackgroundAndDate() {
    setState(() {
      formattedDate = _formatDate(widget.loan['finaldate']);
      statusText = _getDateMessage();
    });
  }

  @override
  void initState() {
    super.initState();
    getBackgroundAndDate();
    getUserData();
  }

  Future getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('userData');
    setState(() {
      userData = userDataJson != null ? jsonDecode(userDataJson) : null;
    });
  }

  Future onChangeLoanStatus(
      BuildContext context, String loanId, String statusText) async {
    await dotenv.load();

    final dio = Dio();
    dio.options.headers['session_id'] = userData['id'];

    final String apiUrl = dotenv.env['API_URL'] ?? '';

    try {
      final response = await dio
          .put('$apiUrl/loans/$loanId/status', data: {'status': statusText});
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusText != widget.loan['status']
                ? 'Status de "${widget.loan['name']}" atualizado com sucesso!'
                : 'O status "${widget.loan['name']}" voltou para o anterior!'),
            action: statusText != widget.loan['status']
                ? SnackBarAction(
                    label: "Desfazer",
                    onPressed: () {
                      onChangeLoanStatus(
                          context, loanId, widget.loan['status']);
                    },
                  )
                : null,
            duration: const Duration(seconds: 4),
          ),
        );
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
            content: Text(errorMessage),
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
        children: [
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onDoubleTap: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => Dialog(
                  child: updateLoan(context, widget.loan),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Dismissible(
                key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
                background: Container(
                  color: Color(widget.loan['status'] == 'inday'
                      ? 0xFF43E091
                      : widget.loan['status'] == 'returned'
                          ? 0xFFE04343
                          : 0xFF43E091),
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          getIcon(widget.loan['status']),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(_getMessageOnDimissed(widget.loan),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))
                        ],
                      )),
                ),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  String updatedStatus = widget.loan['status'] == 'inday'
                      ? 'returned'
                      : widget.loan['status'] == 'returned'
                          ? 'late'
                          : 'inday';
                  onChangeLoanStatus(context, widget.loan['id'], updatedStatus);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 1 - 30,
                  padding: const EdgeInsets.only(
                      top: 10, left: 20, bottom: 10, right: 20),
                  color: Color(widget.loan['status'] == 'inday'
                      ? 0xFF439AE0
                      : widget.loan['status'] == 'returned'
                          ? 0xFF43E091
                          : 0xFFE04343),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.loan['name'] +
                            ', para ' +
                            widget.loan['loanedto'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.loan['category'],
                              style: const TextStyle(
                                  color: Color(0xFFF7F7F7), fontSize: 13)),
                          Text(_getDateMessage(),
                              style: const TextStyle(
                                  color: Color(0xFFF7F7F7), fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getIcon(String status) {
    return status == 'inday'
        ? const Icon(
            Icons.check_outlined,
            color: Colors.white,
          )
        : status == 'returned'
            ? const Icon(
                Icons.delete,
                color: Colors.white,
              )
            : const Icon(
                Icons.assignment_turned_in,
                color: Colors.white,
              );
  }

  Widget updateLoan(BuildContext context, Map<String, dynamic> selectedLoan) {
    return Container(
        height: 560,
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: UpdateLoanScreen(
          loanData: selectedLoan,
        ));
  }
}
