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
    if (e is Exception) {
      final s = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['error'] != null) return data['error'].toString();
      }
      if (s.contains('Invalid credentials')) return 'Invalid phone or password.';
      if (s.contains('Email already registered')) return 'Email already registered.';
      if (s.contains('SocketException') || s.contains('Connection')) {
        return 'Network error. Check your connection.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
