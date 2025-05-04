import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/models/product_model.dart';
import 'package:fillify_with_firebase/service/product_service.dart'; // Product service to interact with Firestore

class ProductStockPage extends StatefulWidget {
  @override
  _ProductStockPageState createState() => _ProductStockPageState();
}

class _ProductStockPageState extends State<ProductStockPage> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  String _searchQuery = '';
  TextEditingController _stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Fetch all products from Firestore
  void _fetchProducts() {
    _productService.getAllProducts().then((products) {
      setState(() {
        _products = products;
      });
    });
  }

  // Function to update product stock in Firestore
  void _updateProductStock(Product product) async {
    int newStock = int.tryParse(_stockController.text) ?? 0;
    if (newStock > 0) {
      try {
        await _productService.updateProductStock(product.id, newStock);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock updated for ${product.name}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update stock')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid quantity')));
    }
  }

  // Filter products based on search query
  List<Product> getFilteredProducts() {
    return _products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset("assets/oilshop.png"),
            ),
            const SizedBox(height: 10),
            Text(
              "Update Product Stock",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Search products & update product stock.",
              style: TextStyle(color: Colors.white70),
            ),
            Divider(),
            SizedBox(height: 8),
            // Search Bar
            TextField(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // Product List
            Expanded(
              child: ListView.builder(
                itemCount: getFilteredProducts().length,
                itemBuilder: (context, index) {
                  final product = getFilteredProducts()[index];

                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text('Current Stock: ${product.quantity}'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showStockUpdateDialog(product);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show the dialog to update stock
  void _showStockUpdateDialog(Product product) {
    _stockController.text = product.quantity.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Stock for ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter new stock quantity',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateProductStock(product);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
