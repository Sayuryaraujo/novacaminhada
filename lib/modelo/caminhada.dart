import 'package:latlong2/latlong.dart';

class Caminhada {
  String titulo;
  double distancia;
  double calorias;
  double tempo;
  double latitude;
  double longitude;
  List<LatLng> rota;
  String? foto;

  Caminhada({
    required this.titulo,
    required this.distancia,
    required this.calorias,
    required this.tempo,
    required this.latitude,
    required this.longitude,
    required this.rota,
    this.foto,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'distancia': distancia,
      'calorias': calorias,
      'tempo': tempo,
      'latitude': latitude,
      'longitude': longitude,
      'rota': rota
          .map((ponto) => {
                'latitude': ponto.latitude,
                'longitude': ponto.longitude,
              })
          .toList(),
      'foto': foto,
    };
  }

  factory Caminhada.fromJson(Map<String, dynamic> json) {
    final pontos = (json['rota'] as List)
        .map(
          (ponto) => LatLng(
            pointToDouble(ponto['latitude']),
            pointToDouble(ponto['longitude']),
          ),
        )
        .toList();

    return Caminhada(
      titulo: json['titulo'],
      distancia: pointToDouble(json['distancia']),
      calorias: pointToDouble(json['calorias']),
      tempo: pointToDouble(json['tempo']),
      latitude: pointToDouble(json['latitude']),
      longitude: pointToDouble(json['longitude']),
      rota: pontos,
      foto: json['foto'],
    );
  }

  static double pointToDouble(dynamic valor) {
    return (valor as num).toDouble();
  }
}