import 'package:flutter/material.dart';

import '../modelo/caminhada.dart';
import '../servicos/armazenamento.dart';
import 'detalhes.dart';
import 'nova_caminhada.dart';
import 'splash.dart';

class HomePage extends StatefulWidget {
  final Function(bool) alterarTema;
  final bool modoEscuro;

  const HomePage({
    super.key,
    required this.alterarTema,
    required this.modoEscuro,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Armazenamento armazenamento = Armazenamento();

  List<Caminhada> caminhadas = [];

  late bool modoEscuro;

  @override
  void initState() {
    super.initState();

    modoEscuro = widget.modoEscuro;

    carregar();
  }

  Future<void> carregar() async {
    final dados = await armazenamento.carregar();

    if (!mounted) return;

    setState(() {
      caminhadas = dados;
    });
  }

  Future<void> salvar() async {
    await armazenamento.salvar(caminhadas);
  }

  void trocarTema(bool valor) {
    setState(() {
      modoEscuro = valor;
    });

    widget.alterarTema(valor);
  }

  Future<void> novaCaminhada() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NovaCaminhadaPage(
          salvarCaminhada: (caminhada) async {
            caminhadas.add(caminhada);

            await salvar();

            if (!mounted) return;

            setState(() {});
          },
        ),
      ),
    );

    await carregar();
  }

  void detalhes(Caminhada caminhada) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesPage(
          caminhada: caminhada,
          atualizar: () async {
            await salvar();

            if (!mounted) return;

            setState(() {});
          },
        ),
      ),
    );
  }

  void abrirSplash() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => SplashPage(
          alterarTema: widget.alterarTema,
          modoEscuro: modoEscuro,
        ),
      ),
      (route) => false,
    );
  }

  void sair() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => SplashPage(
          alterarTema: widget.alterarTema,
          modoEscuro: modoEscuro,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Caminhadas'),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.directions_walk,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Minhas Caminhadas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('Splash'),
              onTap: () {
                Navigator.pop(context);
                abrirSplash();
              },
            ),

            SwitchListTile(
              secondary: Icon(
                modoEscuro
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: const Text('Tema escuro'),
              value: modoEscuro,
              onChanged: trocarTema,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pop(context);
                sair();
              },
            ),
          ],
        ),
      ),

      body: caminhadas.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_walk,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Nenhuma caminhada registrada.',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Toque no botão + para começar.',
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: caminhadas.length,
              itemBuilder: (context, index) {
                final caminhada = caminhadas[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.directions_walk,
                      ),
                    ),
                    title: Text(
                      caminhada.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${caminhada.distancia.toStringAsFixed(2)} km',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: () {
                      detalhes(caminhada);
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: novaCaminhada,
        child: const Icon(Icons.add),
      ),
    );
  }
}