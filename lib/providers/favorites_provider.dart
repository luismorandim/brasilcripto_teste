import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]) {
    loadFavorites();
  }

  static const _key = 'favorites';

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_key) ?? [];
    state = favoritesList;
  }

  Future<void> toggleFavorite(String coinId) async {
    final prefs = await SharedPreferences.getInstance();
    if (state.contains(coinId)) {
      state = state.where((id) => id != coinId).toList();
    } else {
      state = [...state, coinId];
    }
    await prefs.setStringList(_key, state);
  }

  bool isFavorite(String coinId) {
    return state.contains(coinId);
  }
}
