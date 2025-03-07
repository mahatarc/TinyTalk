import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiny_talks/features/loginPage/presentation/UI/login.dart';
import 'package:tiny_talks/features/signupPage/presentation/UI/signupPage.dart';
import 'package:tiny_talks/features/splashscreen/presentation/UI/splashscreen.dart';
import 'package:tiny_talks/features/signupPage/presentation/bloc/signup_bloc.dart';
import 'package:tiny_talks/features/signupPage/presentation/bloc/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SignupService
    final signupService = SignupService();

    return MultiBlocProvider(
      providers: [
        // Add SignUpBloc and any other blocs here
        BlocProvider(
          create: (context) => SignUpBloc(signupService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tiny Talks',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const OnboardingPage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) =>  Signup(),
        },
      ),
    );
  }
}
