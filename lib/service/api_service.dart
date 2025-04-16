import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/criptos_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';

  // Stream controller para atualizações em tempo real
  final _priceUpdateController =
      StreamController<List<CriptosModel>>.broadcast();
  Stream<List<CriptosModel>> get priceUpdates => _priceUpdateController.stream;
  Timer? _updateTimer;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  void dispose() {
    _updateTimer?.cancel();
    _priceUpdateController.close();
  }

  // Inicia atualizações em tempo real
  void startRealtimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      updatePrices();
    });
  }

  // Para as atualizações em tempo real
  void stopRealtimeUpdates() {
    _updateTimer?.cancel();
  }

  // Atualiza preços e emite para o stream
  Future<void> updatePrices() async {
    try {
      final coins = await fetchCoins();
      _priceUpdateController.add(coins);
    } catch (e) {
      _priceUpdateController
          .addError('Erro ao atualizar preços: ${e.toString()}');
    }
  }

  Future<List<CriptosModel>> fetchCoins({int page = 1, String? query}) async {
    try {
      if (query != null && query.isNotEmpty) {
        return await _searchCoins(query);
      }

      final url = Uri.parse(
          '$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=$page&sparkline=false');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Tempo limite de conexão excedido');
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((coin) => CriptosModel.fromJson(coin)).toList();
      } else if (response.statusCode == 429) {
        throw Exception(
            'Limite de requisições excedido. Tente novamente em alguns minutos.');
      } else {
        throw Exception(
            'Falha ao carregar criptomoedas. Código: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception(
            'Tempo limite de conexão excedido. Verifique sua internet.');
      }
      throw Exception('Erro ao carregar criptomoedas: ${e.toString()}');
    }
  }

  Future<List<CriptosModel>> _searchCoins(String query) async {
    try {
      final searchUrl = Uri.parse('$_baseUrl/search?query=$query');
      final searchResponse = await http.get(searchUrl).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Tempo limite de conexão excedido');
        },
      );

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final List coins = searchData['coins'];

        if (coins.isEmpty) return [];

        // Pegando os 10 primeiros resultados
        final ids = coins.take(10).map((c) => c['id']).join(',');

        final resultUrl =
            Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&ids=$ids');
        final resultResponse = await http.get(resultUrl).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Tempo limite de conexão excedido');
          },
        );

        if (resultResponse.statusCode == 200) {
          final List resultData = json.decode(resultResponse.body);
          return resultData.map((coin) => CriptosModel.fromJson(coin)).toList();
        } else if (resultResponse.statusCode == 429) {
          throw Exception(
              'Limite de requisições excedido. Tente novamente em alguns minutos.');
        } else {
          throw Exception(
              'Erro ao carregar detalhes da busca. Código: ${resultResponse.statusCode}');
        }
      } else {
        throw Exception(
            'Erro ao buscar criptomoedas. Código: ${searchResponse.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception(
            'Tempo limite de conexão excedido. Verifique sua internet.');
      }
      throw Exception('Erro ao realizar a busca: ${e.toString()}');
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
