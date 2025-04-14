
import 'package:brasilcripto_teste/models/criptos_model.dart';

class HomeState {
  final List<CriptosModel> coins;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final bool hasMore;
  final String searchQuery;
  final bool notFound;

  HomeState({
    required this.coins,
    required this.isLoadingMore,
    this.error,
    required this.page,
    required this.hasMore,
    required this.searchQuery,
    required this.notFound,
  });

  HomeState copyWith({
    List<CriptosModel>? coins,
    bool? isLoadingMore,
    String? error,
    int? page,
    bool? hasMore,
    String? searchQuery,
    bool? notFound,
  }) {
    return HomeState(
      coins: coins ?? this.coins,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      notFound: notFound ?? this.notFound,
    );
  }

  factory HomeState.initial() {
    return HomeState(
      coins: [],
      isLoadingMore: false,
      error: null,
      page: 1,
      hasMore: true,
      searchQuery: '',
      notFound: false,
    );
  }
}
