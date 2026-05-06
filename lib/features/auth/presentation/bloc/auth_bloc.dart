library;

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../../application/usecases/check_auth_usecase.dart';
import '../../application/usecases/login_usecase.dart';
import '../../application/usecases/logout_usecase.dart';
import '../../application/usecases/signup_usecase.dart';
import '../../application/usecases/update_profile_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required SignupUseCase signupUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthUseCase checkAuthUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _login = loginUseCase,
        _signup = signupUseCase,
        _logout = logoutUseCase,
        _checkAuth = checkAuthUseCase,
        _updateProfile = updateProfileUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckAuth);
    on<LoginRequested>(_onLogin);
    on<SignupRequested>(_onSignup);
    on<LogoutRequested>(_onLogout);
    on<AuthSessionInvalidated>(_onSessionInvalidated);
    on<UpdateProfileRequested>(_onUpdateProfile);
  }

  final LoginUseCase _login;
  final SignupUseCase _signup;
  final LogoutUseCase _logout;
  final CheckAuthUseCase _checkAuth;
  final UpdateProfileUseCase _updateProfile;

  Future<void> _onCheckAuth(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final user = await _checkAuth.call();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _login(phone: event.phone, password: event.password);
      emit(AuthAuthenticated(result.user));
    } catch (e) {
      emit(AuthFailure(_message(e)));
    }
  }

  Future<void> _onSignup(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signup(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        password: event.password,
        firebaseIdToken: event.firebaseIdToken,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(_message(e)));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _logout();
    emit(const AuthUnauthenticated());
  }

  void _onSessionInvalidated(
    AuthSessionInvalidated event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthUnauthenticated());
  }

  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _updateProfile(event.user);
    emit(AuthAuthenticated(event.user));
  }

  String _message(dynamic e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      if (code == 429) {
        return 'Too many login attempts. Wait a few minutes and try again.';
      }
      final server = _serverMessage(e.response?.data);
      if (server != null && server.isNotEmpty) {
        return _sanitizeUserFacingAuth(server);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return 'Network error. Check your connection.';
      }
    }
    if (e is Exception) {
      final s = e.toString();
      if (s.contains('Invalid credentials')) return 'Invalid phone or password.';
      if (s.contains('Email already registered')) return 'Email already registered.';
      if (s.contains('SocketException') || s.contains('Connection')) {
        return 'Network error. Check your connection.';
      }
      final pemMsg = _friendlyMessageIfFirebaseKeyConfigError(s);
      if (pemMsg != null) return pemMsg;
    }
    return 'Something went wrong. Please try again.';
  }

  /// Hides PEM/private-key server misconfiguration from snackbars (fix backend env).
  static String _sanitizeUserFacingAuth(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return 'Something went wrong. Please try again.';
    return _friendlyMessageIfFirebaseKeyConfigError(t) ?? t;
  }

  static String? _friendlyMessageIfFirebaseKeyConfigError(String raw) {
    final l = raw.toLowerCase();
    if (l.contains('failed to parse private key') ||
        l.contains('invalid pem') ||
        (l.contains('private key') && l.contains('pem'))) {
      return 'Sign-up is temporarily unavailable. Please try again later.';
    }
    return null;
  }

  /// Parses common backend JSON shapes: `{ message }`, `{ error }`, `{ errors: [...] }`.
  static String? _serverMessage(dynamic data) {
    if (data == null) return null;
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in ['message', 'error', 'detail']) {
        final v = map[key];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      final errors = map['errors'];
      if (errors is List && errors.isNotEmpty) {
        final parts = <String>[];
        for (final item in errors) {
          if (item is String && item.trim().isNotEmpty) {
            parts.add(item.trim());
          } else if (item is Map) {
            final m = Map<String, dynamic>.from(item);
            final msg = m['message'] ?? m['msg'];
            if (msg is String && msg.trim().isNotEmpty) parts.add(msg.trim());
          }
        }
        if (parts.isNotEmpty) return parts.join(' ');
      }
    }
    return null;
  }
}
