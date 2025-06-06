import 'package:fillify_with_firebase/oil_shop_module/customer_register_page.dart';
import 'package:fillify_with_firebase/service/customer_service.dart';
import 'package:fillify_with_firebase/logged_product_menu.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/shared/custom_button.dart';
import 'package:fillify_with_firebase/shared/signin_input.dart';

class CustomerLoginPage extends StatefulWidget {
  @override
  _CustomerLoginPageState createState() => _CustomerLoginPageState();
}

class _CustomerLoginPageState extends State<CustomerLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String?
  _errorMessage; // Variable to store error message for invalid credentials

  final CustomerService _customerService = CustomerService();

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null; // Reset error message on new login attempt
      });

      try {
        final customer = await _customerService.loginCustomer(
          _emailController.text,
          _passwordController.text,
        );

        if (customer == null) {
          // If invalid credentials, show error message
          setState(() {
            _errorMessage = 'Invalid login credentials. Please Try Again';
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
        } else {
          // If login is successful, navigate to the next page
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Login Successful')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoggedProductMenu(customer: customer),
            ),
          );
        }
      } catch (e) {
        // Catch and display errors
        setState(() {
          _errorMessage = 'Error: $e';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
      } finally {
        setState(() {
          _isLoading = false;
        });
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
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[400], // The notch color
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.only(top: 15), // Space above the notch
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Customer Login",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Please verify yourself to enter shopping cart.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Divider(),
                ],
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
                  return null;
                },
              ),
              SizedBox(height: 5),
              SignInInput(
                heading: "Password *",
                isPassword: true,
                controller: _passwordController,
                labelText: "Enter your password",
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter your password' : null,
              ),
              SizedBox(height: 5),

              // Show error message if credentials are invalid
              if (_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),

              // Display loading indicator or login button
              _isLoading
                  ? CircularProgressIndicator()
                  : CustomButton(labelText: "Login", onPressed: _submitLogin),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an Account?"),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerRegisterPage(),
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
