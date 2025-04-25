import 'package:fillify_with_firebase/product_model.dart';
import 'package:fillify_with_firebase/product_service.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/shared/signin_input.dart'; // Custom TextFormField
import 'package:fillify_with_firebase/shared/custom_button.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _imgUrlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController =
      TextEditingController(); // Price controller

  // Submit the form and add the product to Firestore
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: '', // Firestore will auto-generate this
        name: _nameController.text.trim(),
        quantity: int.parse(_quantityController.text),
        size: _sizeController.text.trim(),
        brand: _brandController.text.trim(),
        imgUrl: _imgUrlController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text), // Adding price
      );

      try {
        await _productService.addNewProduct(product);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Product added successfully')));
        _nameController.clear();
        _quantityController.clear();
        _sizeController.clear();
        _brandController.clear();
        _imgUrlController.clear();
        _descriptionController.clear();
        _priceController.clear(); // Clear price input
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding product: $e')));
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset("assets/img5.png"),
                ),
                SizedBox(height: 15),
                Text(
                  "Add New Product",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "Fill in the details below to add a new product.",
                  style: TextStyle(color: Colors.white70),
                ),
                Divider(),
                SizedBox(height: 8),

                // Product Name (using custom TextFormField)
                SignInInput(
                  heading: "Product Name *",
                  controller: _nameController,
                  isPassword: false,
                  labelText: "Enter product name",
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter product name';
                    }
                    if (value!.length < 3) {
                      return 'Product name must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                // Quantity (using custom TextFormField)
                SignInInput(
                  heading: "Quantity *",
                  controller: _quantityController,
                  isPassword: false,
                  labelText: "Enter product quantity",
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter quantity';
                    }
                    if (int.tryParse(value!) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),

                // Size (using custom TextFormField)
                SignInInput(
                  heading: "Size *",
                  controller: _sizeController,
                  isPassword: false,
                  labelText: "Enter size",
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter size';
                    }
                    return null;
                  },
                ),

                // Brand (using custom TextFormField)
                SignInInput(
                  heading: "Brand *",
                  controller: _brandController,
                  isPassword: false,
                  labelText: "Enter brand",
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter brand';
                    }
                    return null;
                  },
                ),

                // Image URL (using custom TextFormField)
                SignInInput(
                  heading: "Image URL *",
                  controller: _imgUrlController,
                  isPassword: false,
                  labelText: "Enter image URL",
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter image URL';
                    }
                    final urlPattern = r'(https?|ftp)://[^\s/$.?#].[^\s]*';
                    final regExp = RegExp(urlPattern);
                    if (!regExp.hasMatch(value!)) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                ),

                // Description (using custom TextFormField)
                SignInInput(
                  heading: "Description *",
                  controller: _descriptionController,
                  isPassword: false,
                  labelText: "Enter description",
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter description';
                    }
                    if (value!.length < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                ),

                // Price (using custom TextFormField)
                SignInInput(
                  heading: "Price *",
                  controller: _priceController,
                  isPassword: false,
                  labelText: "Enter price",
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value!) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 15),

                // Submit Button
                CustomButton(labelText: "Add Product", onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
