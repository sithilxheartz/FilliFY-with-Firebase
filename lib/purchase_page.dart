import 'package:fillify_with_firebase/shared/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/models/product_model.dart';

class ProductPurchasePage extends StatelessWidget {
  final Product product;
  final String customerName; // Added parameter to receive customer name
  final double totalPrice; // Added parameter to receive total price

  ProductPurchasePage({
    Key? key,
    required this.product,
    required this.customerName,
    required this.totalPrice,
  }) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _NameOnCardController = TextEditingController();
  final TextEditingController _CardNumberController = TextEditingController();
  final TextEditingController _ExpireDateController = TextEditingController();
  final TextEditingController _CVVController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _street1Controller = TextEditingController();
  final TextEditingController _street2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();

  void _submitPurchaseForm(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // Save the form
      _formKey.currentState?.save();

      // Simulate successful payment (no real payment is made)
      showSnackBar(context, 'Payment Successful! Confirmation Email Sent');

      // Clear all the text fields after submission
      _NameOnCardController.clear();
      _CardNumberController.clear();
      _ExpireDateController.clear();
      _CVVController.clear();
      _phoneController.clear();
      _street1Controller.clear();
      _street2Controller.clear();
      _cityController.clear();
      _provinceController.clear();
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Logo and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset("assets/applogo.png"),
                            ),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mr. $customerName,",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Thank You for Choosing Us",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 2),

                                Text(
                                  "Ypu Got Better Discount with FilliFY Coins",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Divider(),
              // Show customer name and total price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order No:', // Display total price
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'VGHB16364ASVQYV1', // Display total price
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer Name:', // Display total price
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '$customerName', // Display total price
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Price: ', // Display total price
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Rs. $totalPrice', // Display total price
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Divider(),
              // Card Details Form
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Enter your card details:",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 15),

                      // Reusing the CustomTextFormField widget for card details
                      CustomTextFormField(
                        controller: _NameOnCardController,
                        labelText: "Card Holder Name",
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter Card Holder Name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      CustomTextFormField(
                        controller: _CardNumberController,
                        labelText: "Card Number",
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter Card Number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      CustomTextFormField(
                        controller: _ExpireDateController,
                        labelText: "Expire Date (MM/YY)",
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter Expiry Date';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      CustomTextFormField(
                        controller: _CVVController,
                        labelText: "Security Code (CVV)",
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter CVV';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Shipping Details
                      Text(
                        "Enter your delivery details:",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 15),

                      CustomTextFormField(
                        controller: _phoneController,
                        labelText: "Phone Number",
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter Phone Number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      CustomTextFormField(
                        controller: _street1Controller,
                        labelText: "Street Address Line 1",
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter Street Address Line 1';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      CustomTextFormField(
                        controller: _street2Controller,
                        labelText: "Street Address Line 2",
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter Street Address Line 2';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      CustomTextFormField(
                        controller: _cityController,
                        labelText: "City",
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your City';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      CustomTextFormField(
                        controller: _provinceController,
                        labelText: "Province",
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your Province';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Submit Button
                      ElevatedButton(
                        onPressed: () => _submitPurchaseForm(context),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 20.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          backgroundColor: Colors.deepPurple.withOpacity(0.7),
                        ),
                        child: Text(
                          'Confirm Payment',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
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
