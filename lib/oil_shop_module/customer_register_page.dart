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
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Please enter your name' : null,
                ),
                SignInInput(
                  heading: "Email *",
                  isPassword: false,
                  controller: _emailController,
                  labelText: "Enter your Email",
                  validator:
                      (value) =>
                          value!.isEmpty || !value.contains('@')
                              ? 'Please enter a valid email'
                              : null,
                ),
                SignInInput(
                  heading: "Password *",
                  isPassword: true,
                  controller: _passwordController,
                  labelText: "Enter your Password",
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Please enter your password' : null,
                ),
                SignInInput(
                  heading: "Mobile Number *",
                  isPassword: false,
                  controller: _mobileController,
                  labelText: "Enter your Mobile Number",
                  validator:
                      (value) =>
                          value!.isEmpty || value.length < 10
                              ? 'Please enter a valid mobile number'
                              : null,
                ),
                SizedBox(height: 15),
                _isLoading
                    ? CircularProgressIndicator()
                    : CustomButton(
                      labelText: "Register",
                      onPressed: _submitRegistration,
                    ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an Account?"),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerLoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        "SIGN IN",
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
      ),
    );
  }
}
