import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiny_talks/features/homepage/presentation/UI/home.dart';
import 'package:tiny_talks/features/loginPage/presentation/UI/login.dart';
import 'package:tiny_talks/features/signupPage/presentation/bloc/signup_bloc.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const Signup(),
    theme: ThemeData(
      primarySwatch: Colors.lightGreen,
    ),
  ));
}

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  PageController _pageController = PageController();
  late TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController(); // Added confirm password controller
  int _currentPage = 0;
  late List<Widget> _pages;
  late SignUpBloc signUpBloc;
  String _passwordErrorMessage = '';  // To store the password mismatch error
  @override
  void initState() {
    signUpBloc = BlocProvider.of<SignUpBloc>(context);
    signUpBloc.add(SignUpInitialEvent());

    super.initState();
    _pages = [
      UsernamePage(_usernameController),
      EmailPage(_emailController),
      PasswordPage(_passwordController, _confirmPasswordController), // Pass confirm password controller here
    ];
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Dispose the confirm password controller
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // Navigate back to login page
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpBloc, SignUpState>(
      bloc: signUpBloc,
      listenWhen: (previous, current) => current is SignUpActionState,
      buildWhen: (previous, current) => current is! SignUpActionState,
      
      builder: (context, state) {
        if (state is SignUpInitialState) {
          return Scaffold(
            body: Stack(
              children: [
                // Background image
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/logbg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Signup form
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back arrow on UsernamePage
                    if (_currentPage == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0, left: 16.0),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: _previousPage,
                        ),
                      ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        itemBuilder: (context, index) {
                          return _pages[index];
                        },
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                      ),
                    ),
                    // Show password mismatch error message if there is one
                    if (_passwordErrorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _passwordErrorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _currentPage == _pages.length - 1
                              ? () {
                                  // Validate if the password and confirm password match
                                  if (_passwordController.text.trim() !=
                                      _confirmPasswordController.text.trim()) {
                                    setState(() {
                                      _passwordErrorMessage =
                                          'Passwords do not match!';
                                    });
                                  } else {
                                    // Clear the error message
                                    setState(() {
                                      _passwordErrorMessage = '';
                                    });

                                    context.read<SignUpBloc>().add(
                                      SignUpButtonPressedEvent(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text.trim(),
                                        username: _usernameController.text.trim(),
                                      ),
                                    );
                                    // Show dialog for email verification
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Verify Your Email"),
                                        content: Text("A verification email has been sent to ${_emailController.text.trim()}. Please verify before logging in."),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context); // Close the dialog
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => const LoginPage()), // Redirect to login page
                                              );
                                            },
                                            child: Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              : _nextPage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.brown[500],
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1 ? 'Signup' : 'Next',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return const Scaffold();
        }
      },
      listener: (context, state) {
        if (state is SignUpButtonPressedNavigateToHome) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      },
    );
  }
}

class UsernamePage extends StatefulWidget {
  final TextEditingController usernameController;
  
  UsernamePage(this.usernameController);

  @override
  _UsernamePageState createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter Username',
              textAlign: TextAlign.center,
              style: GoogleFonts.lobster(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: widget.usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                hintText: 'Username',
                prefixIcon: const Icon(Icons.person, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailPage extends StatefulWidget {
  final TextEditingController emailController;
  
  EmailPage(this.emailController);

  @override
  _EmailPageState createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter Email',
              textAlign: TextAlign.center,
              style: GoogleFonts.lobster(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: widget.emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordPage extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  PasswordPage(this.passwordController, this.confirmPasswordController);

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _errorMessage = '';

  void _validatePasswords() {
    if (widget.passwordController.text != widget.confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match!';
      });
    } else {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create Password',
              textAlign: TextAlign.center,
              style: GoogleFonts.lobster(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: widget.passwordController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: !_isPasswordVisible,
              onChanged: (_) => _validatePasswords(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: widget.confirmPasswordController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                hintText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: !_isConfirmPasswordVisible,
              onChanged: (_) => _validatePasswords(),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
