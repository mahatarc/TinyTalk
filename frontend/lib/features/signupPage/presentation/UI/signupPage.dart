import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiny_talks/features/homepage/presentation/UI/home.dart';
import 'package:tiny_talks/features/loginPage/presentation/UI/login.dart';
import 'package:tiny_talks/features/signupPage/presentation/bloc/signup_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tiny_talks/config.dart';

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
  TextEditingController _confirmPasswordController = TextEditingController();
  int _currentPage = 0;
  late List<Widget> _pages;
  late SignUpBloc signUpBloc;
  String _passwordErrorMessage = '';
  String _usernameErrorMessage = '';
  String _emailErrorMessage = '';

  @override
  void initState() {
    signUpBloc = BlocProvider.of<SignUpBloc>(context);
    signUpBloc.add(SignUpInitialEvent());

    super.initState();
    _pages = [
      UsernamePage(_usernameController, _usernameErrorMessage, _validateUsername),
      EmailPage(_emailController, _emailErrorMessage, _validateEmail),
      PasswordPage(_passwordController, _confirmPasswordController, _passwordErrorMessage),
    ];
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      // Validate username before proceeding
      if (_usernameController.text.isEmpty) {
        setState(() {
          _usernameErrorMessage = 'Username is required';
        });
        return; // Stop navigation if username is empty
      } else {
        setState(() {
          _usernameErrorMessage = ''; // Clear error if username is valid
        });
      }
    } else if (_currentPage == 1) {
      // Validate email before proceeding
      if (_emailController.text.isEmpty) {
        setState(() {
          _emailErrorMessage = 'Email is required';
        });
        return; // Stop navigation if email is empty
      } else if (!_isValidEmail(_emailController.text)) {
        setState(() {
          _emailErrorMessage = 'Please enter a valid email address';
        });
        return; // Stop navigation if email is invalid
      } else {
        setState(() {
          _emailErrorMessage = ''; // Clear error if email is valid
        });
      }
    }

    // Navigate to the next page
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
      Navigator.pop(context);
    }
  }

  void _validateUsername(String value) {
    if (value.isEmpty) {
      setState(() {
        _usernameErrorMessage = 'Username is required';
      });
    } else {
      setState(() {
        _usernameErrorMessage = '';
      });
    }
  }

  void _validateEmail(String value) async {
  if (value.isEmpty) {
    setState(() { _emailErrorMessage = 'Email is required'; });
  } else if (!_isValidEmail(value)) {
    setState(() { _emailErrorMessage = 'Please enter a valid email address'; });
  } else {
    final response = await http.get(Uri.parse("${AppConfig.baseUrl}/api/check_email/$value"));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['email_exists']) {
        setState(() { _emailErrorMessage = 'Email is already registered!'; });
      } else {
        setState(() { _emailErrorMessage = ''; });
      }
    }
  }
}


  bool _isValidEmail(String email) {
    // Regular expression for validating email format
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
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
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/logbg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          // Update the pages with the latest error messages
                          if (index == 0) {
                            return UsernamePage(_usernameController, _usernameErrorMessage, _validateUsername);
                          } else if (index == 1) {
                            return EmailPage(_emailController, _emailErrorMessage, _validateEmail);
                          } else {
                            return PasswordPage(_passwordController, _confirmPasswordController, _passwordErrorMessage);
                          }
                        },
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _currentPage == _pages.length - 1
                              ? () {
                                // Check if password fields are empty
                                  if (_passwordController.text.trim().isEmpty ||
                                      _confirmPasswordController.text.trim().isEmpty){
                                        setState((){
                                          _passwordErrorMessage = 'Both password fields are required!';
                                        });
                                        return; // Stop sign-up if any password field is empty
                                      }
                                    // Check if passwords match
                                   if (_passwordController.text.trim() !=
                                      _confirmPasswordController.text.trim()) {
                                    setState(() {
                                      _passwordErrorMessage = 'Passwords do not match!';
                                    });
                                    return; // Stop sign-up if passwords do not match
                                  } else {
                                    setState(() {
                                      _passwordErrorMessage = '';
                                    });

                                    // Validate email again before sending for verification
                                    if (!_isValidEmail(_emailController.text.trim())) {
                                      setState(() {
                                        _emailErrorMessage = 'Please enter a valid email address';
                                      });
                                      return;
                                    }

                                    context.read<SignUpBloc>().add(
                                      SignUpButtonPressedEvent(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text.trim(),
                                        username: _usernameController.text.trim(),
                                      ),
                                    );
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Verify Your Email"),
                                        content: Text("A verification email has been sent to ${_emailController.text.trim()}. Please verify before logging in."),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => const LoginPage()),
                                              );
                                            },
                                            child: Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              : (_currentPage == 0 && _usernameErrorMessage.isEmpty) ||
                                      (_currentPage == 1 && _emailErrorMessage.isEmpty)
                                  ? _nextPage
                                  : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.brown[500],
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1 ? 'Signup' : 'Next',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
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
        } else if (state is SignUpErrorState){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
    );
  }
}

class UsernamePage extends StatelessWidget {
  final TextEditingController usernameController;
  final String errorMessage;
  final Function(String) onValidate;

  UsernamePage(this.usernameController, this.errorMessage, this.onValidate);

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
              controller: usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                hintText: 'Username',
                prefixIcon: const Icon(Icons.person, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                errorText: errorMessage.isNotEmpty ? errorMessage : null,
              ),
              onChanged: (value) {
                onValidate(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EmailPage extends StatelessWidget {
  final TextEditingController emailController;
  final String errorMessage;
  final Function(String) onValidate;

  EmailPage(this.emailController, this.errorMessage, this.onValidate);

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
              controller: emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                errorText: errorMessage.isNotEmpty ? errorMessage : null,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                onValidate(value);
              },
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
  final String errorMessage;

  PasswordPage(this.passwordController, this.confirmPasswordController, this.errorMessage);

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
                padding: const EdgeInsets.only(top: 8.0),
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
