part of 'signup_bloc.dart';
abstract class SignUpState {}


class SignUpInitialState extends SignUpState {}

class SignUpLoadingState extends SignUpState {}

class SignUpActionState extends SignUpState{}

class SignUpButtonPressedNavigateToHome extends SignUpActionState{}

class SignUpButtonPressedWaitForVerification extends SignUpState {}

class SignUpLoagedState extends SignUpState{}

class SignUpErrorState extends SignUpState{
  SignUpErrorState(param0);
}