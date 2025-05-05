import 'package:fillify_with_firebase/service/admin_services.dart';
import 'package:fillify_with_firebase/shared/signin_input.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/models/admin_model.dart';
import 'admin_login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminRegisterPage extends StatefulWidget {
  @override
  _AdminRegisterPageState createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminService = AdminService();
  bool _isLoading = false;

  // Register method to create a new admin
  Future<void> _register() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill in all fields.");
      return;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: "Passwords do not match.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if the email is already taken
      bool isEmailTaken = await _adminService.isEmailTaken(email);
      if (isEmailTaken) {
        Fluttertoast.showToast(msg: "Email is already registered.");
        return;
      }

      // Create Admin object and add to the Firestore collection
      Admin admin = Admin(id: '', name: name, email: email, password: password);
      await _adminService.addToAdminCollection(admin);

      Fluttertoast.showToast(msg: "Registration successful.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error occurred during registration.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset("assets/admins.png"),
                ),
                const SizedBox(height: 10),
                Text(
                  "Register New Admin",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Fill in the details below to register as a admin.",
                  style: TextStyle(color: Colors.white70),
                ),
                Divider(),
                SizedBox(height: 8),
                SignInInput(
                  heading: "Username*",
                  controller: _nameController,
                  labelText: "Enter your name (e.g. Nimesh)",
                  isPassword: false,
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
                  heading: "Email*",
                  controller: _emailController,
                  labelText: "Enter your email",
                  isPassword: false,
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
                  heading: "Password*",
                  controller: _passwordController,
                  labelText: "Enter your password",
                  isPassword: true,
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
                  heading: "Confirm Password*",
                  controller: _confirmPasswordController,
                  labelText: "Confirm your password",
                  isPassword: true,
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

                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 20.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: _isLoading ? null : _register,
                    child:
                        _isLoading
                            ? CircularProgressIndicator()
                            : Text(
                              "Register",
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
