import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/api_service.dart';
import '../models/criptos_model.dart';

class HomeState {
  final List<CriptosModel> coins;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final bool notFound;
  final String searchQuery;

  HomeState({
    this.coins = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.notFound = false,
    this.searchQuery = '',
  });

  HomeState copyWith({
    List<CriptosModel>? coins,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool? notFound,
    String? searchQuery,
  }) {
    return HomeState(
      coins: coins ?? this.coins,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      notFound: notFound ?? this.notFound,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(ApiService());
});

class HomeViewModel extends StateNotifier<HomeState> {
  final ApiService _apiService;
  int _currentPage = 1;
  static const int _pageSize = 20;

  HomeViewModel(this._apiService) : super(HomeState()) {
    loadCoins();
  }

  Future<void> loadCoins() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      notFound: false,
    );

    try {
      final coins = await _apiService.fetchCoins(page: 1);
      _currentPage = 1;
      state = state.copyWith(
        coins: coins,
        isLoading: false,
        hasMore: coins.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreCoins() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = _currentPage + 1;
      final newCoins = await _apiService.fetchCoins(page: nextPage);

      if (newCoins.isNotEmpty) {
        _currentPage = nextPage;
        // Mantém os itens existentes e adiciona os novos
        final updatedCoins = [...state.coins, ...newCoins];
        state = state.copyWith(
          coins: updatedCoins,
          isLoadingMore: false,
          hasMore: newCoins.length >= _pageSize,
        );
      } else {
        state = state.copyWith(
          isLoadingMore: false,
          hasMore: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchCoins(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      notFound: false,
      searchQuery: query,
    );

    try {
      final coins = await _apiService.searchCoins(query);
      state = state.copyWith(
        coins: coins,
        isLoading: false,
        notFound: coins.isEmpty,
        hasMore: false, // Desativa carregamento infinito durante busca
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      notFound: false,
    );
    loadCoins(); // Recarrega a lista inicial
  }
}
