import 'package:fillify_with_firebase/service/pumper_service.dart';
import 'package:fillify_with_firebase/shared/custom_button.dart';
import 'package:fillify_with_firebase/shared/signin_input.dart';
import 'package:fillify_with_firebase/fuel_stock_module_pages/fuel_add_sales.dart';
import 'package:flutter/material.dart';

class PumperSignInSales extends StatefulWidget {
  const PumperSignInSales({super.key});

  @override
  State<PumperSignInSales> createState() => _PumperSignInSalesState();
}

class _PumperSignInSalesState extends State<PumperSignInSales> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = PumperService();

  bool _isLoading = false;
  String? _errorMessage;

  // Login method to validate the pumper credentials
  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null; // Reset error message
      });

      final user = await _userService.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      _emailController.clear();
      _passwordController.clear();

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Welcome, ${user.name}!')));

        // Navigate to AddSalesPage after successful login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddSalesPage(pumper: user)),
        );
      } else {
        // Invalid credentials - Show error message
        setState(() {
          _errorMessage = "Invalid login credentials. Please Try Again";
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
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
          image: AssetImage("assets/img3.png"),
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
                      "Please verify yourself before adding fuel sales.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Divider(),
                  ],
                ),
              ),

              // Email input field
              SignInInput(
                heading: "Email *",
                isPassword: false,
                controller: _emailController,
                labelText: "Enter your Email",
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),

              // Password input field
              SignInInput(
                heading: "Password *",
                isPassword: true,
                controller: _passwordController,
                labelText: "Enter your password",
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your password';
                  }
                  //If all checks pass, return null (valid)
                  return null;
                },
              ),
              const SizedBox(height: 5),

              // Displaying error message if any
              if (_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),

              // Loading indicator or login button
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                    labelText: "Login",
                    onPressed: () => _login(context), // Handle login
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
