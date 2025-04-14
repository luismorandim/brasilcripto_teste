import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/api_service.dart';
import '../view_model/home_state.dart';
import '../view_model/home_view_model.dart';


final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>(
      (ref) => HomeViewModel(ApiService()),
);