import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/criptos_model.dart';

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  static const Duration _validityDuration = Duration(minutes: 5);

  _CacheEntry(this.data) : timestamp = DateTime.now();

  bool get isValid => DateTime.now().difference(timestamp) < _validityDuration;
}

class ApiService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);
  static const Duration _updateInterval = Duration(seconds: 15);

  DateTime? _lastRequestTime;
  int _requestCount = 0;
  static const int _maxRequestsPerMinute = 10;
  List<CriptosModel>? _lastUpdateData;

  // Cache para armazenar resultados
  final Map<String, _CacheEntry> _cache = {};

  final _priceUpdateController =
      StreamController<List<CriptosModel>>.broadcast();
  Stream<List<CriptosModel>> get priceUpdates => _priceUpdateController.stream;
  Timer? _updateTimer;
  Timer? _requestResetTimer;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _startRequestRateTimer();
  }

  void _startRequestRateTimer() {
    _requestResetTimer?.cancel();
    _requestResetTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _requestCount = 0;
    });
  }

  void dispose() {
    _updateTimer?.cancel();
    _requestResetTimer?.cancel();
    _priceUpdateController.close();
    _cache.clear();
    _lastUpdateData = null;
  }

  bool _hasSignificantChanges(List<CriptosModel> newData) {
    if (_lastUpdateData == null) return true;

    if (newData.length != _lastUpdateData!.length) return true;

    for (int i = 0; i < newData.length; i++) {
      final newCoin = newData[i];
      final oldCoin = _lastUpdateData![i];

      // Verifica se houve mudança significativa no preço (0.1%)
      final priceChange =
          ((newCoin.currentPrice - oldCoin.currentPrice) / oldCoin.currentPrice)
              .abs();
      if (priceChange > 0.001) return true;

      // Verifica mudanças no volume
      final volumeChange =
          ((newCoin.totalVolume - oldCoin.totalVolume) / oldCoin.totalVolume)
              .abs();
      if (volumeChange > 0.01) return true;

      // Verifica mudanças na variação 24h
      if ((newCoin.priceChangePercentage24h - oldCoin.priceChangePercentage24h)
              .abs() >
          0.1) return true;
    }

    return false;
  }

  String _getCacheKey(String endpoint, Map<String, dynamic> params) {
    final sortedParams = Map.fromEntries(
        params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    return '$endpoint${jsonEncode(sortedParams)}';
  }

  Future<T?> _getFromCache<T>(String cacheKey) async {
    final cacheEntry = _cache[cacheKey];
    if (cacheEntry != null && cacheEntry.isValid) {
      print('Usando dados do cache para: $cacheKey');
      return cacheEntry.data as T;
    }
    return null;
  }

  void _saveToCache(String cacheKey, dynamic data) {
    _cache[cacheKey] = _CacheEntry(data);
  }

  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      return true;
    } catch (e) {
      print('Erro ao verificar conectividade: $e');
      return false;
    }
  }

  Future<bool> _canMakeRequest() async {
    if (_requestCount >= _maxRequestsPerMinute) {
      final now = DateTime.now();
      if (_lastRequestTime != null) {
        final difference = now.difference(_lastRequestTime!);
        if (difference < const Duration(minutes: 1)) {
          return false;
        }
      }
      _requestCount = 0;
    }
    return true;
  }

  Future<T> _makeRequestWithRetry<T>({
    required Future<T> Function() request,
    required String cacheKey,
    int retryCount = 0,
  }) async {
    try {
      // Tenta obter do cache primeiro
      final cachedData = await _getFromCache<T>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      if (!await _canMakeRequest()) {
        throw Exception(
            'Limite de requisições excedido. Aguarde um momento e tente novamente.');
      }

      _requestCount++;
      _lastRequestTime = DateTime.now();

      final result = await request();
      _saveToCache(cacheKey, result);
      return result;
    } catch (e) {
      if (e is SocketException ||
          e is TimeoutException ||
          e.toString().contains('429')) {
        if (retryCount < _maxRetries) {
          print(
              'Tentativa ${retryCount + 1} de $_maxRetries. Aguardando $_retryDelay...');
          await Future.delayed(_retryDelay * (retryCount + 1));
          return _makeRequestWithRetry(
            request: request,
            cacheKey: cacheKey,
            retryCount: retryCount + 1,
          );
        }
      }
      rethrow;
    }
  }

  Future<List<CriptosModel>> fetchCoins({int page = 1, String? query}) async {
    if (!await _checkConnectivity()) {
      throw Exception(
          'Sem conexão com a internet. Verifique sua conexão e tente novamente.');
    }

    if (query != null && query.isNotEmpty) {
      return searchCoins(query);
    }

    final params = {
      'page': page,
      'per_page': 20,
    };
    final cacheKey = _getCacheKey('markets', params);

    return _makeRequestWithRetry(
      cacheKey: cacheKey,
      request: () async {
        final url = Uri.parse(
            '$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=$page&sparkline=false');

        final response = await http.get(
          url,
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'BrasilCripto/1.0',
          },
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          return data.map((coin) => CriptosModel.fromJson(coin)).toList();
        } else if (response.statusCode == 429) {
          throw Exception(
              'Limite de requisições excedido. Aguarde um momento e tente novamente.');
        } else {
          throw Exception(
              'Falha ao carregar criptomoedas. Código: ${response.statusCode}');
        }
      },
    );
  }

  Future<List<CriptosModel>> searchCoins(String query) async {
    final params = {'query': query};
    final cacheKey = _getCacheKey('search', params);

    return _makeRequestWithRetry(
      cacheKey: cacheKey,
      request: () async {
        final searchUrl = Uri.parse('$_baseUrl/search?query=$query');
        final searchResponse = await http.get(
          searchUrl,
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'BrasilCripto/1.0',
          },
        ).timeout(const Duration(seconds: 15));

        if (searchResponse.statusCode == 200) {
          final searchData = json.decode(searchResponse.body);
          final List coins = searchData['coins'];

          if (coins.isEmpty) return [];

          final ids = coins.take(10).map((c) => c['id']).join(',');
          final resultUrl =
              Uri.parse('$_baseUrl/coins/markets?vs_currency=usd&ids=$ids');

          final resultResponse = await http.get(
            resultUrl,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'BrasilCripto/1.0',
            },
          ).timeout(const Duration(seconds: 15));

          if (resultResponse.statusCode == 200) {
            final List resultData = json.decode(resultResponse.body);
            return resultData
                .map((coin) => CriptosModel.fromJson(coin))
                .toList();
          } else if (resultResponse.statusCode == 429) {
            throw Exception(
                'Limite de requisições excedido. Aguarde um momento e tente novamente.');
          } else {
            throw Exception(
                'Erro ao carregar detalhes da busca. Código: ${resultResponse.statusCode}');
          }
        } else {
          throw Exception(
              'Erro ao buscar criptomoedas. Código: ${searchResponse.statusCode}');
        }
      },
    );
  }

  void startRealtimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(_updateInterval, (timer) {
      updatePrices();
    });
  }

  void stopRealtimeUpdates() {
    _updateTimer?.cancel();
  }

  Future<void> updatePrices() async {
    try {
      final newData = await fetchCoins();

      if (_hasSignificantChanges(newData)) {
        _lastUpdateData = newData;
        _priceUpdateController.add(newData);
      }
    } catch (e) {
      _priceUpdateController
          .addError('Erro ao atualizar preços: ${e.toString()}');
    }
  }
}
