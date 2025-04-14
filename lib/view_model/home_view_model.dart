import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/api_service.dart';
import 'home_state.dart';

class HomeViewModel extends StateNotifier<HomeState> {
  final ApiService _apiService;
  Timer? _refreshTimer;

  HomeViewModel(this._apiService) : super(HomeState.initial()) {
    fetchCoins();
    _startAutoRefresh();
  }

  Future<void> fetchCoins({String? query}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final coins = await _apiService.fetchCoins(query: query);
      state = state.copyWith(coins: coins, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchCoins();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
