import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../widgets/crypto_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('BrasilCripto')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                if (value.isEmpty) {
                  viewModel.clearSearch();
                }
              },
              onSubmitted: (value) => viewModel.searchCoins(value.trim()),
              decoration: InputDecoration(
                hintText: 'Pesquisar criptomoeda',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Erro: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (state.notFound)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Nenhuma criptomoeda encontrada',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else if (state.coins.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Nenhuma criptomoeda disponível',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: state.coins.length +
                    (state.hasMore && state.searchQuery.isEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.coins.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: TextButton(
                          onPressed: state.isLoadingMore
                              ? null
                              : () => viewModel.loadMoreCoins(),
                          child: state.isLoadingMore
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  'Carregar mais',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    );
                  }
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
