import 'package:flutter/material.dart';

Widget loansTopBar(BuildContext context) {
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
        onPressed: () => {},
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
      ),
    ],
  );
}
