import 'package:flutter/material.dart';
import 'telas/splash.dart';

void main() {
  runApp(const CaminhadaApp());
}

class CaminhadaApp extends StatefulWidget {
  const CaminhadaApp({super.key});

  @override
  State<CaminhadaApp> createState() => _CaminhadaAppState();
}

class _CaminhadaAppState extends State<CaminhadaApp> {
  bool modoEscuro = false;

  void alterarTema(bool valor) {
    setState(() {
      modoEscuro = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minhas Caminhadas',

      themeMode:
          modoEscuro ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),

      home: SplashPage(
        alterarTema: alterarTema,
        modoEscuro: modoEscuro,
      ),
    );
  }
}