import 'package:fillify_with_firebase/oil_shop_module/customer_login_page.dart';
import 'package:fillify_with_firebase/service/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/models/customer_model.dart';
import 'package:fillify_with_firebase/shared/custom_button.dart';
import 'package:fillify_with_firebase/shared/signin_input.dart';

class CustomerRegisterPage extends StatefulWidget {
  @override
  _CustomerRegisterPageState createState() => _CustomerRegisterPageState();
}

class _CustomerRegisterPageState extends State<CustomerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  final CustomerService _customerService = CustomerService();

  void _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newCustomer = Customer(
        id: '',
        name: _nameController.text,
        email: _emailController.text,
        loyaltyPoints: 0, // New customers start with 0 points
        orderHistory: [],
        password: _passwordController.text,
        mobile: _mobileController.text,
      );

      try {
        await _customerService.registerCustomer(newCustomer);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration Successful')));

        Navigator.pop(context); // Go back after successful registration
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset("assets/ferrari.png"),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Register with US",
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
                SignInInput(
                  heading: "Name *",
                  isPassword: false,
                  controller: _nameController,
                  labelText: "Enter your Name",
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
                  isPassword: false,
                  controller: _emailController,
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
                  labelText: "Enter your Password",
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
                  heading: "Mobile Number *",
                  isPassword: false,
                  controller: _mobileController,
                  labelText: "Enter your Mobile Number",
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
                SizedBox(height: 10),
                _isLoading
                    ? CircularProgressIndicator()
                    : CustomButton(
                      labelText: "Register",
                      onPressed: _submitRegistration,
                    ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
