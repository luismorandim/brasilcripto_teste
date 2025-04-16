import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../widgets/crypto_card.dart';
import 'favorites_screen.dart';

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
      appBar: AppBar(
        title: const Text('BrasilCripto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
        ],
      ),
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await viewModel.loadCoins();
              },
              child: state.isLoading && state.coins.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : state.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => viewModel.loadCoins(),
                                child: const Text('Tentar Novamente'),
                              ),
                            ],
                          ),
                        )
                      : state.notFound
                          ? const Center(
                              child: Text(
                                'Nenhuma criptomoeda encontrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : state.coins.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhuma criptomoeda disponível',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: state.coins.length +
                                      (state.hasMore &&
                                              state.searchQuery.isEmpty
                                          ? 1
                                          : 0),
                                  itemBuilder: (context, index) {
                                    if (index == state.coins.length) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: Center(
                                          child: state.isLoadingMore
                                              ? const CircularProgressIndicator()
                                              : TextButton(
                                                  onPressed: () =>
                                                      viewModel.loadMoreCoins(),
                                                  child: const Text(
                                                    'Carregar mais',
                                                    style:
                                                        TextStyle(fontSize: 16),
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
          ),
          if (state.error != null && state.coins.isNotEmpty)
            Container(
              color: Colors.red.shade50,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => viewModel.loadCoins(),
                    color: Colors.red.shade700,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
