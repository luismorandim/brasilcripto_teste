import 'dart:async';
import 'package:brasilcripto_teste/models/criptos_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/api_service.dart';
import 'home_state.dart';

class HomeViewModel extends StateNotifier<HomeState> {
  final ApiService _apiService;
  Timer? _refreshTimer;
  List<CriptosModel> _originalCoins = [];

  HomeViewModel(this._apiService) : super(HomeState.initial()) {
    fetchInitialCoins();
    _startAutoRefresh();
  }

  Future<void> fetchInitialCoins() async {
    try {
      state = state.copyWith(isLoadingMore: true);
      final coins = await _apiService.fetchCoins(page: 1);
      _originalCoins = coins;
      state = state.copyWith(
        coins: coins,
        page: 1,
        hasMore: coins.length == 20,
        error: null,
        notFound: false,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingMore: false,
      );
    }
  }

  Future<void> loadMoreCoins() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.page + 1;
      final newCoins = await _apiService.fetchCoins(page: nextPage);
      final updatedCoins = [...state.coins, ...newCoins];
      _originalCoins = updatedCoins;

      state = state.copyWith(
        coins: updatedCoins,
        page: nextPage,
        hasMore: newCoins.length == 20,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void refreshCoinsInPlace() async {
    if (state.searchQuery.isNotEmpty) return;

    try {
      final freshCoins = await _apiService.fetchCoins(page: 1);
      final Map<String, CriptosModel> freshMap = {
        for (var coin in freshCoins) coin.id: coin
      };

      final updated = state.coins.map((c) => freshMap[c.id] ?? c).toList();
      _originalCoins = updated;
      state = state.copyWith(coins: updated);
    } catch (_) {}
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      refreshCoinsInPlace();
    });
  }

  Future<void> searchCoins(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(
      searchQuery: query,
      error: null,
      notFound: false,
      isLoadingMore: true,
    );

    try {
      final results = await _apiService.searchCoins(query);

      state = state.copyWith(
        coins: results,
        notFound: results.isEmpty,
        error: null,
        hasMore: false,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erro ao buscar criptomoedas.',
        notFound: false,
        isLoadingMore: false,
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      notFound: false,
      error: null,
      isLoadingMore: true,
    );

    state = state.copyWith(
      coins: _originalCoins,
      page: 1,
      hasMore: _originalCoins.length == 20,
      isLoadingMore: false,
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
