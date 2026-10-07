import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../modelo/caminhada.dart';
import '../widgets/informacao.dart';

class NovaCaminhadaPage extends StatefulWidget {
  final Function(Caminhada) salvarCaminhada;

  const NovaCaminhadaPage({
    super.key,
    required this.salvarCaminhada,
  });

  @override
  State<NovaCaminhadaPage> createState() =>
      _NovaCaminhadaPageState();
}

class _NovaCaminhadaPageState
    extends State<NovaCaminhadaPage> {
  final MapController mapa = MapController();

  LatLng? localizacao;
  LatLng? destino;

  List<LatLng> rota = [];

  double distancia = 0;
  double tempo = 0;
  double calorias = 0;

  bool carregando = true;
  bool calculando = false;

  @override
  void initState() {
    super.initState();
    obterLocalizacao();
  }

  Future<void> obterLocalizacao() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      mensagem('Ative a localização.');
      setState(() => carregando = false);
      return;
    }

    var permissao =
        await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao =
          await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied ||
        permissao ==
            LocationPermission.deniedForever) {
      mensagem('Permissão de localização negada.');
      setState(() => carregando = false);
      return;
    }

    final posicao =
        await Geolocator.getCurrentPosition();

    setState(() {
      localizacao = LatLng(
        posicao.latitude,
        posicao.longitude,
      );
      carregando = false;
    });

    mapa.move(localizacao!, 15);
  }

  Future<void> selecionar(LatLng ponto) async {
    if (localizacao == null) return;

    setState(() {
      destino = ponto;
      calculando = true;
    });

    await calcularRota();

    setState(() {
      calculando = false;
    });
  }

  Future<void> calcularRota() async {
    if (localizacao == null || destino == null) return;

    final origem =
        '${localizacao!.longitude},${localizacao!.latitude}';

    final fim =
        '${destino!.longitude},${destino!.latitude}';

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/foot/'
      '$origem;$fim?overview=full&geometries=geojson',
    );

    try {
      final resposta = await http.get(url);

      if (resposta.statusCode != 200) {
        calcularLinha();
        return;
      }

      final dados = jsonDecode(resposta.body);

      final dadosRota =
          dados['routes'][0]['geometry']['coordinates'];

      final metros =
          dados['routes'][0]['distance'].toDouble();

      rota = dadosRota.map<LatLng>((ponto) {
        return LatLng(
          ponto[1].toDouble(),
          ponto[0].toDouble(),
        );
      }).toList();

      distancia = metros / 1000;
      tempo = distancia / 5 * 60;

      setState(() {});
    } catch (_) {
      calcularLinha();
    }
  }

  void calcularLinha() {
    final metros = Geolocator.distanceBetween(
      localizacao!.latitude,
      localizacao!.longitude,
      destino!.latitude,
      destino!.longitude,
    );

    distancia = metros / 1000;
    tempo = distancia / 5 * 60;

    rota = [
      localizacao!,
      destino!,
    ];

    setState(() {});
  }

  Future<void> salvar() async {
    if (destino == null || distancia == 0) {
      mensagem('Selecione um destino.');
      return;
    }

    final titulo = TextEditingController();
    final peso = TextEditingController(text: '70');

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Salvar caminhada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titulo,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: peso,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titulo.text.trim().isEmpty) return;

              final valor =
                  double.tryParse(peso.text) ?? 70;

              calorias = 0.7 * valor * distancia;

              Navigator.pop(context, true);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final caminhada = Caminhada(
      titulo: titulo.text.trim(),
      distancia: distancia,
      calorias: calorias,
      tempo: tempo,
      latitude: destino!.latitude,
      longitude: destino!.longitude,
      rota: rota,
    );

    await widget.salvarCaminhada(caminhada);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  void mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova caminhada'),
      ),
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapa,
                  options: MapOptions(
                    initialCenter: localizacao ??
                        const LatLng(
                          -23.5505,
                          -46.6333,
                        ),
                    initialZoom: 15,
                    onTap: (_, ponto) {
                      selecionar(ponto);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.caminhada_app',
                    ),

                    if (rota.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: rota,
                            strokeWidth: 5,
                            color: Colors.green,
                          ),
                        ],
                      ),

                    MarkerLayer(
                      markers: [
                        if (localizacao != null)
                          Marker(
                            point: localizacao!,
                            width: 45,
                            height: 45,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),

                        if (destino != null)
                          Marker(
                            point: destino!,
                            width: 45,
                            height: 45,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 38,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                if (calculando)
                  const Positioned(
                    top: 15,
                    left: 15,
                    right: 15,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Calculando trajeto...',
                        ),
                      ),
                    ),
                  ),

                if (destino != null && !calculando)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                Informacao(
                                  icone: Icons.straighten,
                                  titulo: 'Distância',
                                  valor:
                                      '${distancia.toStringAsFixed(2)} km',
                                ),
                                Informacao(
                                  icone: Icons.timer,
                                  titulo: 'Tempo',
                                  valor:
                                      '${tempo.toStringAsFixed(0)} min',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: salvar,
                                child: const Text('Salvar'),
                              ),
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
}