import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<dynamic>> fetchTopCoins() async {
    final url = Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=false');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao carregar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }
}
