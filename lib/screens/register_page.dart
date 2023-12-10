import 'package:flutter/material.dart';
import 'package:quiz_app/screens/quiz_screen.dart';
import '../services/firebase_auth.dart';
import '../widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  Future<void> _registerWithEmailAndPassword() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      try {
        setState(() {
          _loading = true;
        });

        await _authService.registerWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        _showDialog(
          title: 'Registration Successful',
          content: 'You have successfully registered.',
          success: true,
        );
      } catch (e) {
        print("Error: $e");
        _showDialog(
          title: 'Registration Failed',
          content: 'An error occurred during registration. Please try again.',
          success: false,
        );
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showDialog({required String title, required String content, required bool success}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text(content),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    if (success) {
                      // Navigate to the next screen after successful registration
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizScreen()),
                      );
                    }
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 37, 55, 83),
                  const Color.fromARGB(255, 28, 55, 78),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'registerText',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            'Register',
                            style: TextStyle(color: Colors.black, fontSize: 36),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        validator: _emailValidator,
                        isSmall: true,
                      ),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        obscureText: true,
                        validator: _passwordValidator,
                        isSmall: true,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _registerWithEmailAndPassword,
                        child: Text(
                          'Register',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
