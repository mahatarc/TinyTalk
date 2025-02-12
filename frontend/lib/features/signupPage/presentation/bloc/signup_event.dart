part of 'signup_bloc.dart';
abstract class SignUpEvent {}

class SignUpInitialEvent extends SignUpEvent{}

class SignUpButtonPressedEvent extends SignUpEvent{
  final String password;
  final String username;
  final String email;

  SignUpButtonPressedEvent({
    required this.password,
    required this.username,
    required this. email,
  });
}