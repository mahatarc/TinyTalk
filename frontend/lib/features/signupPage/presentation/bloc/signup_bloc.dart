import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiny_talks/features/signupPage/presentation/bloc/auth.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignupService signupService;

  SignUpBloc(this.signupService) : super(SignUpInitialState()) {
    on<SignUpInitialEvent>(signUpInitialEvent);
    on<SignUpButtonPressedEvent>(signUpButtonPressedEvent);
  }

  Future<void> signUpButtonPressedEvent(SignUpButtonPressedEvent event, Emitter<SignUpState> emit) async {
    try {
      // Emit loading state
      emit(SignUpLoadingState());

      // Log input fields for debugging
      print("Username: ${event.username}");
      print("Email: ${event.email}");
      print("Password: ${event.password}");

      // Call the signup service method
      final response = await signupService.signup(
        event.username,
        event.email,
        event.password,
      );
      print("..................API Response: $response..............................");

      // If the signup is successful
      if (response['success']) {
        // Show the email verification prompt
        emit(SignUpButtonPressedWaitForVerification());
      } else {
        // Emit error state with message
        emit(SignUpErrorState(response['message'] ?? 'Unknown error occurred'));
      }
    } catch (e) {
      // Handle any exceptions and emit error state
      emit(SignUpErrorState('An error occurred: $e'));
    }
  }

  FutureOr<void> signUpInitialEvent(SignUpInitialEvent event, Emitter<SignUpState> emit) {
    emit(SignUpInitialState());
  }
}