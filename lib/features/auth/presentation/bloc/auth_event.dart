library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/driver_user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.phone, required this.password});
  final String phone;
  final String password;
  @override
  List<Object?> get props => [phone, password];
}

class SignupRequested extends AuthEvent {
  const SignupRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.firebaseIdToken,
  });
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String? firebaseIdToken;
  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    password,
    firebaseIdToken,
  ];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Local session was cleared (e.g. expired token); sync BLoC without calling logout API.
class AuthSessionInvalidated extends AuthEvent {
  const AuthSessionInvalidated();
}

class UpdateProfileRequested extends AuthEvent {
  const UpdateProfileRequested(this.user);
  final DriverUser user;
  @override
  List<Object?> get props => [user];
}
