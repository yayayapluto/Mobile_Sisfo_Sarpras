import 'package:mobile_sisfo_sarpras/models/user.dart';
import 'package:riverpod/riverpod.dart';
import '../services/dio_service.dart';
import '../services/api_services/auth_service.dart';

final dioServiceProvider = Provider<DioService>((ref) {
  return DioService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final dioService = ref.watch(dioServiceProvider);
  return AuthService(dioService);
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final User? userData;
  final String? token;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.userData,
    this.token,
  });

  const AuthState.initial() : this();
  const AuthState.loading() : this(isLoading: true);

  const AuthState.authenticated({
    required User userData,
    required String token,
  }) : this(
          isAuthenticated: true,
          userData: userData,
          token: token,
        );

  const AuthState.error(String errorMessage) : this(error: errorMessage);

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    User? userData,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userData: userData ?? this.userData,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final DioService _dioService;

  AuthNotifier(this._authService, this._dioService) : super(const AuthState.initial());

  Future<bool> login(String username, String password) async {
    state = const AuthState.loading();

    try {
      final result = await _authService.login(username, password);

      if (result['success']) {
        final token = result['content']['token'];
        
        // Set the token in DioService for all future requests
        _dioService.setToken(token);
        
        state = AuthState.authenticated(
          userData: User.fromJson(result['content']['user']),
          token: token,
        );

        return true;
      } else {
        state = AuthState.error(result['message']);
        return false;
      }
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();

    try {
      await _authService.logout();
      // Clear the token from DioService
      _dioService.setToken('');
    } catch (e) {
      // print('Error during logout: $e');
    }

    state = const AuthState.initial();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final dioService = ref.watch(dioServiceProvider);
  return AuthNotifier(authService, dioService);
});
