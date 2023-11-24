import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giveback/widgets/all_loans.dart';
import 'package:giveback/widgets/top_bar.dart';
import 'package:giveback/widgets/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Loans();
  }
}

class Loans extends StatefulWidget {
  const Loans({Key? key}) : super(key: key);

  @override
  State<Loans> createState() => _LoansState();
}

class _LoansState extends State<Loans> {
  int _selectedIndex = 0;
  Map<String, dynamic> userData = {};
  List<dynamic> loansData = [];
  bool isLoaded = false;
  List<dynamic> indDayLoans = [];
  List<dynamic> deliveredLoans = [];
  List<dynamic> lateLoans = [];
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredLoans = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void filterLoans() {
    setState(() {
      filteredLoans = loansData
          .where((loan) =>
              loan['loanedto']
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              loan['name']
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              loan['category']
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              loan['observations']
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  void separateLoans(List<dynamic> loansData) {
    indDayLoans.clear();
    deliveredLoans.clear();
    lateLoans.clear();
    for (var loan in loansData) {
      switch (loan['status']) {
        case 'inday':
          indDayLoans.add(loan);
          break;
        case 'returned':
          deliveredLoans.add(loan);
          break;
        case 'late':
          lateLoans.add(loan);
          break;
        default:
      }
    }
  }

  Future getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('userData');
    setState(() {
      userData = userDataJson != null ? jsonDecode(userDataJson) : null;
    });
    getLoans(userData['id']);
  }

  Future getLoans(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    await dotenv.load();

    final dio = Dio();
    dio.options.headers['session_id'] = id;

    final String apiUrl = dotenv.env['API_URL'] ?? '';

    try {
      final response = await dio.get('$apiUrl/loans');
      if (response.statusCode == 200) {
        setState(() {
          loansData = response.data;
          filteredLoans = response.data;
          separateLoans(loansData);
        });
      } else {
        final dynamic errorData = response.data;
        final String errorMessage = errorData['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitação dos empréstimos falhou: $errorMessage'),
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
    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TopBarScreen(
          userData: userData,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF439AE0),
      ),
      body: Container(
        color: Colors.white,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                getFilter(context, filteredLoans),
                Expanded(
                  child: buildListView(context, filteredLoans),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                getFilter(context, indDayLoans),
                Expanded(
                  child: buildListView(context, indDayLoans),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                getFilter(context, deliveredLoans),
                Expanded(
                  child: buildListView(context, deliveredLoans),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                getFilter(context, lateLoans),
                Expanded(
                  child: buildListView(context, lateLoans),
                ),
              ],
            ),
            const Column(
              children: [Expanded(child: UserProfile())],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF439AE0),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
            backgroundColor: Color(0xFF439AE0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_outlined),
            label: 'Em Dia',
            backgroundColor: Color(0xFF439AE0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Devolvidos',
            backgroundColor: Color(0xFF439AE0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarm),
            label: 'Atrasados',
            backgroundColor: Color(0xFF439AE0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Conta',
            backgroundColor: Color(0xFF439AE0),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget getFilter(BuildContext context, List<dynamic> selectedList) {
    return selectedList.isEmpty
        ? Container()
        : Container(
            // decoration: BoxDecoration(border: B),
            width: MediaQuery.of(context).size.width - 20,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    filterLoans();
                  },
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Pesquisar...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF439AE0),
                    ),
                    border: OutlineInputBorder(),
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
              ),
            ),
          );
  }

  Widget notFoundLoansMessage(BuildContext context) {
    return Center(
      child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(30),
          alignment: Alignment.center,
          child: Column(
            children: [
              Image.asset(
                "assets/empty.jpg",
                width: 413,
                height: 457,
              ),
              const Text(
                'Não foram encontrados registros para o status informado!',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              )
            ],
          )),
    );
  }

  Widget buildListView(BuildContext context, List<dynamic> selectedList) {
    return selectedList.isEmpty
        ? !isLoaded
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return notFoundLoansMessage(context);
                })
        : ListView.builder(
            itemCount: selectedList.length,
            itemBuilder: (BuildContext context, int index) {
              return LoansScreen(
                loan: selectedList[index],
              );
            },
          );
  }
}
