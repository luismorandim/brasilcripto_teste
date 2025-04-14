import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/criptos_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<CriptosModel>> fetchCoins({int page = 1, String? query}) async {
    if (query != null && query.isNotEmpty) {
      final searchUrl = Uri.parse('$_baseUrl/search?query=$query');
      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final List coins = searchData['coins'];

        if (coins.isEmpty) return [];

        // (pegando os 10 primeiros ids)
        final ids = coins.take(10).map((c) => c['id']).join(',');

        final resultUrl =
            Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&ids=$ids');
        print('ids: $ids');
        final resultResponse = await http.get(resultUrl);

        if (resultResponse.statusCode == 200) {
          final List resultData = json.decode(resultResponse.body);
          return resultData.map((coin) => CriptosModel.fromJson(coin)).toList();
        } else {
          throw Exception('Erro ao carregar detalhes da busca');
        }
      } else {
        throw Exception('Erro ao buscar criptomoedas.');
      }
    }

    final url = Uri.parse(
        '$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=$page&sparkline=false');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((coin) => CriptosModel.fromJson(coin)).toList();
    } else {
      throw Exception('Erro ao carregar criptomoedas.');
    }
  }

  Future<List<CriptosModel>> searchCoin(String query) async {
    try {
      final searchUrl = Uri.parse('$_baseUrl/search?query=$query');
      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode == 200) {
        final jsonData = json.decode(searchResponse.body);
        final List coins = jsonData['coins'];

        if (coins.isEmpty) return [];

        // Limita a 10
        final ids = coins.take(10).map((coin) => coin['id']).join(',');

        final resultUrl = Uri.parse(
            '$_baseUrl/coins/markets?vs_currency=usd&ids=$ids&order=market_cap_desc');
        final resultResponse = await http.get(resultUrl);

        if (resultResponse.statusCode == 200) {
          final List resultData = json.decode(resultResponse.body);
          return resultData.map((coin) => CriptosModel.fromJson(coin)).toList();
        } else {
          throw Exception('Erro ao carregar detalhes das criptomoedas');
        }
      } else {
        throw Exception('Erro ao buscar criptomoedas');
      }
    } catch (e) {
      throw Exception('Erro ao realizar a busca: ${e.toString()}');
    }
  }
}
