import 'package:flutter/material.dart';
import 'home.dart';

class SplashPage extends StatefulWidget {
  final Function(bool) alterarTema;
  final bool modoEscuro;

  const SplashPage({
    super.key,
    required this.alterarTema,
    required this.modoEscuro,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState
    extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animacao;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    animacao = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            alterarTema: widget.alterarTema,
            modoEscuro: widget.modoEscuro,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: animacao,
          child: ScaleTransition(
            scale: animacao,
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.directions_walk,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Minhas Caminhadas',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Caminhe. Registre. Acompanhe.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}