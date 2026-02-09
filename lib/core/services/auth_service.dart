import 'dart:async';
import 'storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/auth_controller.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StorageService _storageService = StorageService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authStateSubscription;

  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();
  Stream<AuthState> get authState => _authStateController.stream;

  bool _isLoggedIn = false;
  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  Map<String, dynamic>? _userData;

  Future<void> initialize() async {
    // Check for existing tokens
    _accessToken = await _storageService.getAuthToken();
    _refreshToken = await _storageService.getRefreshToken();
    _userData = await _storageService.getUserData();

    _authStateSubscription ??= _firebaseAuth.authStateChanges().listen(
      _handleAuthStateChange,
    );

    _handleAuthStateChange(_firebaseAuth.currentUser);
  }

  Future<bool> login(String email, String password) async {
    try {
      _authStateController.add(AuthState.loading);

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        _accessToken = await user.getIdToken();

        await _storageService.saveAuthToken(_accessToken ?? '');

        // Update user data from Firebase
        _userData = {
          'id': user.uid,
          'email': user.email,
          'name': user.displayName ?? email.split('@')[0],
          'provider': 'firebase',
          'verified': user.emailVerified,
          'auth_service_enabled': true,
        };
        await _storageService.saveUserData(_userData!);

        _isLoggedIn = true;
        _authStateController.add(AuthState.authenticated);
        return true;
      } else {
        _authStateController.add(AuthState.error);
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      _authStateController.add(AuthState.error);
      return false;
    }
  }

  // Huawei Email/Password Registration
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _authStateController.add(AuthState.loading);

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        // Update profile
        if (name.isNotEmpty) {
          await user.updateDisplayName(name);
        }

        // Note: User data will be saved on login, not registration
        // Registration only creates the account, login is separate

        // Sign out to prevent auto-login
        await _firebaseAuth.signOut();

        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      _authStateController.add(AuthState.error);
      // If error is about verification code, we might need UI changes.
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Logout error: $e');
    }
    await _clearTokens();
    _isLoggedIn = false;
    _userData = null;
    await _storageService.saveUserData({}); // Clear current user data
    _authStateController.add(AuthState.unauthenticated);
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get authToken => _accessToken;
  Map<String, dynamic>? get userData => _userData;

  // Helper methods for token management
  Future<bool> _verifyToken(String token) async {
    try {
      return token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      _accessToken = await user.getIdToken(true);
      await _storageService.saveAuthToken(_accessToken!);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> _getUserInfo(String accessToken) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return {
        'sub': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'picture': user.photoURL ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storageService.clearAuthData();
  }

  void dispose() {
    _authStateSubscription?.cancel();
    _authStateController.close();
  }

  void _handleAuthStateChange(User? user) {
    if (user == null) {
      _isLoggedIn = false;
      _authStateController.add(AuthState.unauthenticated);
      return;
    }

    _isLoggedIn = true;
    _userData = {
      'id': user.uid,
      'email': user.email,
      'name': user.displayName ?? '',
      'provider': 'firebase',
      'verified': user.emailVerified,
      'auth_service_enabled': true,
    };
    _storageService.saveUserData(_userData!);
    _authStateController.add(AuthState.authenticated);
  }
}
