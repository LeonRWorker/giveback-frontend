import 'package:flutter/material.dart';
import 'package:giveback/widgets/all_loans.dart';
import 'package:giveback/widgets/top_bar.dart';
import 'package:giveback/widgets/user_profile.dart';

class LoansPage extends StatelessWidget {
  final dynamic userData;
  const LoansPage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Loans(userData: userData);
  }
}

class Loans extends StatefulWidget {
  final dynamic userData;

  const Loans({Key? key, required this.userData}) : super(key: key);

  @override
  State<Loans> createState() => _LoansState();
}

class _LoansState extends State<Loans> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> loansData = [];
  List<Map<String, dynamic>> deliveredLoans = [];
  List<Map<String, dynamic>> lateLoans = [];
  List<Map<String, dynamic>> droppedOutLoans = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Chame a função para carregar e separar os dados aqui
    loadDataAndSeparateLoans();
  }

  _getLoans() async {}

  Future<void> loadDataAndSeparateLoans() async {
    // Simule uma requisição assíncrona, substitua isso com sua lógica real
    await Future.delayed(const Duration(seconds: 2));

    // Substitua este bloco com a lógica da sua requisição
    final List<Map<String, dynamic>> responseData = [];

    // // Verifique se a resposta não é nula e não está vazia antes de continuar
    // if (responseData != null && responseData.isNotEmpty) {
    //   setState(() {
    //     loansData = responseData;
    //     separateLoans(loansData);
    //   });
    // }

    setState(() {
      loansData = responseData;
      separateLoans(loansData);
    });
  }

  void separateLoans(List<Map<String, dynamic>> loansData) {
    deliveredLoans.clear();
    lateLoans.clear();
    droppedOutLoans.clear();
    for (var loan in loansData) {
      switch (loan['status']) {
        case 'returned':
          deliveredLoans.add(loan);
          break;
        case 'late':
          lateLoans.add(loan);
          break;
        case 'droppedOut':
          droppedOutLoans.add(loan);
          break;
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: loansTopBar(context),
        backgroundColor: const Color(0xFF439AE0),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: buildListView(context, loansData),
              ),
            ],
          ),
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
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
              Expanded(
                child: buildListView(context, lateLoans),
              ),
            ],
          ),
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: buildListView(context, droppedOutLoans),
              ),
            ],
          ),
          const Column(
            children: [Expanded(child: UserProfile())],
          )
        ],
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
            label: 'Devolvidos',
            backgroundColor: Color(0xFF439AE0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarm),
            label: 'Atrasados',
            backgroundColor: Color(0xFF439AE0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cancel),
            label: 'Esquecidos',
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

  Widget notFoundLoansMessage(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.8,
        child: const Text(
          'Não foram encontrados registros para o status informado!',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildListView(
      BuildContext context, List<Map<String, dynamic>> selectedList) {
    return selectedList.length == 0
        ? notFoundLoansMessage(context)
        : ListView.builder(
            itemCount: selectedList.length,
            itemBuilder: (BuildContext context, int index) {
              return allLoansBuilder(context, selectedList[index]);
            },
          );
  }
}
