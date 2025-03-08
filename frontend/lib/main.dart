import 'dart:async'; // Add this import for StreamSubscription
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiny_talks/features/loginPage/presentation/UI/login.dart';
import 'package:tiny_talks/features/signupPage/presentation/UI/signupPage.dart';
import 'package:tiny_talks/features/splashscreen/presentation/UI/splashscreen.dart';
import 'package:tiny_talks/features/signupPage/presentation/bloc/signup_bloc.dart';
import 'package:tiny_talks/features/signupPage/presentation/bloc/auth.dart';
import 'package:tiny_talks/features/homepage/presentation/UI/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Add a stream subscription for deep links
  StreamSubscription? _sub;

  // GlobalKey to access the Navigator state
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    // Cancel the stream subscription when the widget is disposed
    _sub?.cancel();
    super.dispose();
  }

  // Initialize deep link handling
  Future<void> _initDeepLinks() async {
    try {
      // Handle initial deep link (when the app is launched via a deep link)
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }

      // Listen for deep links while the app is running
      _sub = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      }, onError: (err) {
        print("Error listening to URI stream: $err");
      });
    } catch (e) {
      print("Error initializing deep links: $e");
    }
  }

  // Handle the deep link
  void _handleDeepLink(Uri uri) {
    // Example: Navigate to the homepage if the deep link is 'myapp://homepage'
    if (uri.scheme == 'myapp' && uri.host == 'homepage') {
      // Use the GlobalKey to access the Navigator state
      _navigatorKey.currentState?.pushReplacementNamed('/homepage');
    }
  }

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
        navigatorKey: _navigatorKey, // Assign the GlobalKey to the MaterialApp
        routes: {
          '/login': (context) => const LoginPage(),

          '/signup': (context) => const Signup(),
          '/homepage': (context) => const HomeScreen(), // Add this route

        },
      ),
    );
  }
}