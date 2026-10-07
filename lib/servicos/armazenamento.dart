import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelo/caminhada.dart';

class Armazenamento {
  static const String chave = 'caminhadas';

  Future<List<Caminhada>> carregar() async {
    final prefs = SharedPreferencesAsync();

    final dados = await prefs.getString(chave);

    if (dados == null) {
      return [];
    }

    final lista = jsonDecode(dados) as List;

    return lista
        .map((item) => Caminhada.fromJson(item))
        .toList();
  }

  Future<void> salvar(List<Caminhada> caminhadas) async {
    final prefs = SharedPreferencesAsync();

    final dados = jsonEncode(
      caminhadas
          .map((caminhada) => caminhada.toJson())
          .toList(),
    );

    await prefs.setString(chave, dados);
  }
}