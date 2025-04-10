import 'package:fillify_with_firebase/pages_shift_module/pumper_login_page.dart';
import 'package:fillify_with_firebase/pages_shift_module/shift_view_page.dart';
import 'package:fillify_with_firebase/service/pumper_service.dart';
import 'package:fillify_with_firebase/models/pumper_model.dart';
import 'package:fillify_with_firebase/shared/custom_button.dart';
import 'package:fillify_with_firebase/shared/signin_input.dart';
import 'package:fillify_with_firebase/utils/colors.dart';
import 'package:flutter/material.dart';

class PumperRegisterPage extends StatelessWidget {
  PumperRegisterPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final PumperService _userService = PumperService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController =
      TextEditingController(); // New controller for mobile number

  // Submit the registration form and add to the Pumper collection
  void _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final pumper = Pumper(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        mobileNumber:
            _mobileController.text
                .trim(), // Pass the mobile number to the Pumper object
        id: '', // Firestore will auto-generate the ID
      );

      try {
        await _userService.addToPumperCollection(
          pumper,
        ); // Add directly to the Pumper collection
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pumper registration completed!')),
        );
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _mobileController.clear(); // Clear the mobile number field
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset("assets/img1.png"),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Register as a Pumper",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Fill in the details below to register as a pumper.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Divider(),
                  ],
                ),
              ),
              SignInInput(
                heading: "Username *",
                isPassword: false,
                controller: _nameController,
                labelText: "Enter your name (e.g. Kasun)",
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your name';
                  }
                  // Check for a minimum and maximum length (e.g., between 2 and 50 characters)
                  if ((value?.length ?? 0) < 4) {
                    return 'Name must be at least 4 characters long';
                  }
                  if ((value?.length ?? 0) > 50) {
                    return 'Name must be less than 50 characters long';
                  }

                  // Check if the username contains only letters
                  if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value!)) {
                    return 'Username cannot contain spaces';
                  }
                  return null;
                },
              ),
              SignInInput(
                heading: "Email *",
                controller: _emailController,
                isPassword: false,
                labelText: "Enter your Email",
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  // Regular expression for basic email format validation
                  final emailRegExp = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );

                  // Check if the email matches the pattern
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
                labelText: "Enter Password",
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your password';
                  }

                  // Check for a minimum length (e.g., 8 characters)
                  if ((value?.length ?? 0) < 8) {
                    return 'Password must be at least 8 characters long';
                  }

                  // Check for at least one lowercase letter
                  if (!RegExp(r'[a-z]').hasMatch(value!)) {
                    return 'Password must contain at least one lowercase letter';
                  }

                  // Check for at least one uppercase letter
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Password must contain at least one uppercase letter';
                  }

                  // Check for at least one digit
                  if (!RegExp(r'\d').hasMatch(value)) {
                    return 'Password must contain at least one digit';
                  }

                  // Check for at least one special character
                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Password must contain at least one special character';
                  }
                  return null;
                },
              ),
              SignInInput(
                heading: "Mobile Number *", // New field for mobile number
                isPassword: false,
                controller: _mobileController,
                labelText: "Mobile Number (e.g. 07X 6X7 XX67)",
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your mobile number';
                  }
                  // Optional: Validate mobile number format
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value!)) {
                    return 'Please enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),
              CustomButton(
                labelText: "Register",
                onPressed: () => _submit(context),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
