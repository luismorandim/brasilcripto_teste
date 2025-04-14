import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../widgets/crypto_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('BrasilCripto')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nome ou símbolo...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) => viewModel.fetchCoins(query: value),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Erro: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (state.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                itemCount: state.coins.length,
                itemBuilder: (context, index) {
                  final coin = state.coins[index];
                  return CryptoCard(coin: coin);
                },
              ),
            ),
        ],
      ),
    );
  }
}
