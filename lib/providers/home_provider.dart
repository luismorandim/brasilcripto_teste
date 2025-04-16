import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/api_service.dart';
import '../models/criptos_model.dart';

class HomeState {
  final List<CriptosModel> coins;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final bool notFound;
  final String searchQuery;
  final bool isLoading;

  HomeState({
    required this.coins,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
    required this.notFound,
    required this.searchQuery,
    required this.isLoading,
  });

  HomeState copyWith({
    List<CriptosModel>? coins,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool? notFound,
    String? searchQuery,
    bool? isLoading,
  }) {
    return HomeState(
      coins: coins ?? this.coins,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      notFound: notFound ?? this.notFound,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(
    apiService: ApiService(),
  );
});

class HomeViewModel extends StateNotifier<HomeState> {
  final ApiService apiService;
  int _currentPage = 1;

  HomeViewModel({required this.apiService})
      : super(HomeState(
          coins: [],
          isLoadingMore: false,
          hasMore: true,
          notFound: false,
          searchQuery: '',
          isLoading: true,
        )) {
    loadCoins();
    _setupRealtimeUpdates();
  }

  void _setupRealtimeUpdates() {
    apiService.priceUpdates.listen(
      (updatedCoins) {
        if (state.searchQuery.isEmpty) {
          state = state.copyWith(
            coins: updatedCoins,
            error: null,
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          error: error.toString(),
        );
      },
    );

    apiService.startRealtimeUpdates();
  }

  @override
  void dispose() {
    apiService.stopRealtimeUpdates();
    super.dispose();
  }

  Future<void> loadCoins() async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        notFound: false,
      );
      _currentPage = 1;
      final coins = await apiService.fetchCoins(page: _currentPage);
      state = state.copyWith(
        coins: coins,
        hasMore: coins.length >= 20,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        coins: [],
        isLoading: false,
      );
    }
  }

  Future<void> loadMoreCoins() async {
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      state = state.copyWith(isLoadingMore: true);
      _currentPage++;
      final newCoins = await apiService.fetchCoins(page: _currentPage);
      state = state.copyWith(
        coins: [...state.coins, ...newCoins],
        isLoadingMore: false,
        hasMore: newCoins.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingMore: false,
      );
    }
  }

  Future<void> searchCoins(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        searchQuery: query,
      );

      final searchResults = await apiService.fetchCoins(query: query);

      state = state.copyWith(
        coins: searchResults,
        isLoading: false,
        hasMore: false,
        notFound: searchResults.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      notFound: false,
    );
    loadCoins();
  }
}
