import 'package:brasilcripto_teste/models/criptos_model.dart';


class HomeState {
  final List<CriptosModel> coins;
  final bool isLoading;
  final String? error;

  HomeState({
    required this.coins,
    required this.isLoading,
    this.error,
  });

  HomeState copyWith({
    List<CriptosModel>? coins,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      coins: coins ?? this.coins,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory HomeState.initial() {
    return HomeState(coins: [], isLoading: false, error: null);
  }
}
