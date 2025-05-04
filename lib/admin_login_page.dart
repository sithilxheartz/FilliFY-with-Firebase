import 'package:fillify_with_firebase/admin_register_page.dart';
import 'package:fillify_with_firebase/admin_services.dart';
import 'package:fillify_with_firebase/management_page.dart';
import 'package:fillify_with_firebase/shared/signin_input.dart';
import 'package:flutter/material.dart'; // This will be the page to redirect after successful login
import 'package:fluttertoast/fluttertoast.dart';

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminService = AdminService();
  bool _isLoading = false;

  // Login method to authenticate user
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final admin = await _adminService.loginUser(
        _emailController.text,
        _passwordController.text,
      );

      if (admin != null) {
        // Navigate to Service Page after successful login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManagementPage()),
        );
      } else {
        Fluttertoast.showToast(msg: "No Access to Customers");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error occurred. Try again.");
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
          padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset("assets/admins.png"),
              ),
              SizedBox(height: 15),
              Text(
                "FilliFY Management",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              // SizedBox(height: 5),
              Text(
                "*Only for office staff & management use.",
                style: TextStyle(color: Colors.red),
              ),
              Divider(),
              SizedBox(height: 8),
              SignInInput(
                heading: "Enter Your Email*",
                controller: _emailController,
                labelText: "Email",
                isPassword: false,
              ),
              SizedBox(height: 10),
              SignInInput(
                heading: "Enter Your Password*",
                controller: _passwordController,
                labelText: "Password",
                isPassword: true,
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
                  onPressed: _isLoading ? null : _login,
                  child:
                      _isLoading
                          ? CircularProgressIndicator()
                          : Text(
                            "SIGN IN",
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
