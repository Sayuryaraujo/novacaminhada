import 'package:flutter/material.dart';

class Informacao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const Informacao({
    super.key,
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icone,
          color: Colors.green,
          size: 28,
        ),
        const SizedBox(height: 5),
        Text(
          titulo,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 3),
        Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}