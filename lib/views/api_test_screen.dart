import 'package:flutter/material.dart';
import '../service/api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _coins = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    try {
      final data = await _apiService.fetchTopCoins();
      setState(() {
        _coins = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print('Erro ao carregar moedas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Test')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _coins.length,
              itemBuilder: (context, index) {
                final coin = _coins[index];
                return ListTile(
                  leading: Image.network(coin['image'], width: 32),
                  title: Text(coin['name']),
                  subtitle: Text('\$${coin['current_price']}'),
                );
              },
            ),
    );
  }
}
