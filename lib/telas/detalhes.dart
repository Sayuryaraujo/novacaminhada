import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../modelo/caminhada.dart';
import '../widgets/informacao.dart';

class DetalhesPage extends StatefulWidget {
  final Caminhada caminhada;
  final Future<void> Function() atualizar;

  const DetalhesPage({
    super.key,
    required this.caminhada,
    required this.atualizar,
  });

  @override
  State<DetalhesPage> createState() =>
      _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  Future<void> tirarFoto() async {
    final picker = ImagePicker();

    final imagem = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (imagem == null) return;

    final pasta =
        await getApplicationDocumentsDirectory();

    final nome =
        'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final arquivo = File(
      '${pasta.path}/$nome',
    );

    await File(imagem.path).copy(arquivo.path);

    setState(() {
      widget.caminhada.foto = arquivo.path;
    });

    await widget.atualizar();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto salva.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final caminhada = widget.caminhada;

    return Scaffold(
      appBar: AppBar(
        title: Text(caminhada.titulo),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 280,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    caminhada.latitude,
                    caminhada.longitude,
                  ),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.caminhada_app',
                  ),

                  if (caminhada.rota.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: caminhada.rota,
                          strokeWidth: 5,
                          color: Colors.green,
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          caminhada.latitude,
                          caminhada.longitude,
                        ),
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
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    caminhada.titulo,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      Informacao(
                        icone: Icons.straighten,
                        titulo: 'Distância',
                        valor:
                            '${caminhada.distancia.toStringAsFixed(2)} km',
                      ),
                      Informacao(
                        icone: Icons.local_fire_department,
                        titulo: 'Calorias',
                        valor:
                            '${caminhada.calorias.toStringAsFixed(0)} kcal',
                      ),
                      Informacao(
                        icone: Icons.timer,
                        titulo: 'Tempo',
                        valor:
                            '${caminhada.tempo.toStringAsFixed(0)} min',
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Foto da caminhada',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (caminhada.foto == null)
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.photo_camera,
                            size: 65,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Nenhuma foto cadastrada.',
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: tirarFoto,
                            icon: const Icon(
                              Icons.camera_alt,
                            ),
                            label: const Text(
                              'Tirar foto',
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12),
                      child: Image.file(
                        File(caminhada.foto!),
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}