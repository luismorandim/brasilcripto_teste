import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/crypto_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final allCoins = ref.watch(homeViewModelProvider).coins;
    final favoriteCoins =
        allCoins.where((coin) => favoriteIds.contains(coin.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Criptomoedas'),
        centerTitle: true,
      ),
      body: favoriteCoins.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma criptomoeda favorita',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione moedas aos favoritos para\nacompanhá-las facilmente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(homeViewModelProvider.notifier).loadCoins();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: favoriteCoins.length,
                itemBuilder: (context, index) {
                  return CryptoCard(coin: favoriteCoins[index]);
                },
              ),
            ),
    );
  }
}
