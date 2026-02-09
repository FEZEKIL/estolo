import 'package:flutter/foundation.dart';
import '../../core/services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _authState = AuthState.initial;
  String? _errorMessage;

  AuthState get authState => _authState;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  String? get errorMessage => _errorMessage;

  AuthController() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _authService.initialize();
    _authService.authState.listen((state) {
      _authState = state;
      notifyListeners();
    });
  }

  Map<String, dynamic>? get userData => _authService.userData;

  Future<bool> login(String email, String password) async {
    try {
      _errorMessage = null;
      final success = await _authService.login(email, password);
      if (!success) {
        _errorMessage = 'Invalid credentials';
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _authState = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  // Registration
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _errorMessage = null;
      _authState = AuthState.loading;
      notifyListeners();

      final success = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      if (!success) {
        _errorMessage = 'Registration failed. Please try again.';
        _authState = AuthState.error;
        notifyListeners();
        return false;
      }

      // Registration successful, but user is not logged in yet
      // Auth state will be updated by the auth service listener
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _authState = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
