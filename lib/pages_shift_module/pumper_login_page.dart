import 'package:fillify_with_firebase/pages_shift_module/pumper_register_page.dart';
import 'package:fillify_with_firebase/service/pumper_service.dart';
import 'package:fillify_with_firebase/shared/custom_button.dart';
import 'package:fillify_with_firebase/shared/signin_input.dart';
import 'package:fillify_with_firebase/pages_shift_module/shift_add_page.dart';
import 'package:flutter/material.dart';

class PumperSignInPage extends StatefulWidget {
  const PumperSignInPage({super.key});

  @override
  State<PumperSignInPage> createState() => _PumperSignInPageState();
}

class _PumperSignInPageState extends State<PumperSignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = PumperService();

  bool _isLoading = false;

  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = await _userService.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      _emailController.clear();
      _passwordController.clear();

      setState(() => _isLoading = false);

      if (user != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Welcome, ${user.name}!')));

        // Navigate to HomePage after successful login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShiftAddPage(pumper: user)),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid email or password')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        image: DecorationImage(
          image: AssetImage("assets/img2.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 15, left: 15, bottom: 110),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[400], // The notch color
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.only(top: 15), // Space above the notch
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pumper Login",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Please verify yourself before booking your shifts.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Divider(),
                  ],
                ),
              ),

              SignInInput(
                heading: "Email *",
                isPassword: false,
                controller: _emailController,
                labelText: "Enter your Email",
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  final emailRegExp = RegExp(
                    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                  );

                  if (!emailRegExp.hasMatch(value!)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SignInInput(
                heading: "Password *",
                isPassword: true,
                controller: _passwordController,
                labelText: "Enter your password",
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your password';
                  }

                  // Check for minimum length (e.g., 8 characters)
                  if (value!.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }

                  // Check if the password contains at least one uppercase letter
                  if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                    return 'Password must contain at least one uppercase letter';
                  }

                  // Check if the password contains at least one lowercase letter
                  if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                    return 'Password must contain at least one lowercase letter';
                  }

                  // Check if the password contains at least one digit
                  if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
                    return 'Password must contain at least one number';
                  }

                  // Check if the password contains at least one special character
                  if (!RegExp(
                    r'(?=.*[!@#$%^&*(),.?":{}|<>])',
                  ).hasMatch(value)) {
                    return 'Password must contain at least one special character';
                  }

                  //If all checks pass, return null (valid)
                  return null;
                },
              ),
              const SizedBox(height: 5),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                    labelText: "Login",
                    onPressed: () => _login(context),
                  ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  PumperRegisterPage(), // Register page navigation
                        ),
                      );
                    },
                    child: Text(
                      "REGISTER",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
