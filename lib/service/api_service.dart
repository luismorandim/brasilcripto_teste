import 'dart:convert';
import 'package:brasilcripto_teste/models/criptos_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<CriptosModel>> fetchCoins({String? query}) async {
    try {
      if (query != null && query.isNotEmpty) {
        // Busca por nome ou símbolo
        final searchUrl = Uri.parse('$_baseUrl/search?query=$query');
        final response = await http.get(searchUrl);

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final coins = decoded['coins'] as List<dynamic>;

          // Pegamos os IDs para depois buscar os dados detalhados
          final ids = coins.map((coin) => coin['id']).join(',');
          return await _fetchDetailsByIds(ids);
        } else {
          throw Exception('Erro ao buscar criptomoedas.');
        }
      } else {
        // Busca padrão (Top 100)
        final url = Uri.parse(
            '$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false');

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData.map((coin) => CriptosModel.fromJson(coin)).toList();
        } else {
          throw Exception('Erro ao carregar criptomoedas.');
        }
      }
    } catch (e) {
      throw Exception('Erro de conexão com a API: $e');
    }
  }

  Future<List<CriptosModel>> _fetchDetailsByIds(String ids) async {
    final url = Uri.parse(
        '$_baseUrl/coins/markets?vs_currency=usd&ids=$ids&order=market_cap_desc&sparkline=false');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((coin) => CriptosModel.fromJson(coin)).toList();
    } else {
      throw Exception('Erro ao buscar detalhes das criptomoedas.');
    }
  }
}
