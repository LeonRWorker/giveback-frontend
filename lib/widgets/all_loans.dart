import 'package:flutter/material.dart';

Widget allLoansBuilder(BuildContext context, Map<String, dynamic> loan) {
  return Center(
    child: Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Dismissible(
            key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
            direction: DismissDirection.startToEnd,
            background: Container(
              color: Colors.red,
              child: const Align(
                alignment: Alignment(-0.9, 0.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 1 - 30,
              padding: const EdgeInsets.only(
                  top: 10, left: 20, bottom: 10, right: 20),
              color: const Color(0xFF439AE0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loan['name'] + ', para ' + loan['loanedto'],
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
                      Text(loan['category'],
                          style: const TextStyle(
                              color: Color(0xFFF7F7F7), fontSize: 13)),
                      Text(loan['finaldate'],
                          style: const TextStyle(
                              color: Color(0xFFF7F7F7), fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
