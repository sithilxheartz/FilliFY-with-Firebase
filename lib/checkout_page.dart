import 'package:fillify_with_firebase/purchase_page.dart';
import 'package:fillify_with_firebase/service/cart_service.dart';
import 'package:fillify_with_firebase/models/product_model.dart';
import 'package:fillify_with_firebase/service/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/models/customer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutPage extends StatelessWidget {
  final CartService cartService;
  final Customer customer;

  CheckoutPage({required this.cartService, required this.customer});

  // Calculate total price after discount
  double _calculateTotal(List<Product> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      total += item.price * item.quantity;
    }
    // Applying discount based on loyalty points
    double discount =
        customer.loyaltyPoints *
        100; // Assuming each loyalty point equals 100 units discount
    return total - discount;
  }

  // Function to save order and update stock
  Future<void> _saveOrderToFirestore(List<Product> cartItems) async {
    double totalPrice = _calculateTotal(cartItems);

    // Prepare the order data
    Map<String, dynamic> orderData = {
      'customerName': customer.name,
      'cartItems':
          cartItems.map((item) {
            return {
              'productName': item.name,
              'quantity': item.quantity,
              'price': item.price,
              'total': item.price * item.quantity,
            };
          }).toList(),
      'totalPrice': totalPrice,
      'status': 'pending', // Order status is initially pending
      'orderDate': FieldValue.serverTimestamp(), // Order timestamp
    };

    // Add order to Firestore collection "OrderHistory"
    await FirebaseFirestore.instance.collection('OrderHistory').add(orderData);

    // Update stock for each product in the cart
    for (var item in cartItems) {
      await _updateProductStock(item); // Reduce the stock based on quantity
    }
    // Reset loyalty points to 0 after the order is placed
    await CustomerService().resetLoyaltyPoints(customer.id);
  }

  // Function to update product stock in Firestore by reducing quantity
  Future<void> _updateProductStock(Product product) async {
    try {
      // Get the current stock of the product from Firestore
      DocumentSnapshot productSnapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .doc(
                product.id,
              ) // Using the product ID to get the correct document
              .get();

      int currentStock =
          productSnapshot['quantity'] ?? 0; // Current stock in Firestore

      // Ensure stock is not negative
      if (currentStock > 0) {
        int newStock =
            currentStock -
            product.quantity; // Reduce stock by the quantity in cart
        if (newStock < 0) newStock = 0; // Ensure stock doesn't go negative

        // Update the stock in Firestore
        await FirebaseFirestore.instance
            .collection('products')
            .doc(product.id)
            .update({'quantity': newStock});

        print(
          "Product stock updated for: ${product.name}, new stock: $newStock",
        );
      } else {
        print("Insufficient stock for: ${product.name}");
      }
    } catch (e) {
      print("Error updating product stock: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Product> cartItems = cartService.getCartItems();
    double totalPrice = _calculateTotal(
      cartItems,
    ); // Calculate total price to pass

    return Scaffold(
      appBar: AppBar(title: Text('Order Receipt')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Logo and Title
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset("assets/applogo.png", height: 80),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "FilliFY Oil Shop",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Customer Name and Loyalty Points
            Text(
              'Customer Name : ${customer.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '${customer.loyaltyPoints} FilliFY Coins',
              style: TextStyle(fontSize: 16, color: Colors.amber),
            ),
            SizedBox(height: 10),

            // Cart Items
            Text(
              'Items Purchased:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final product = cartItems[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.name} X ${product.quantity}  -  Rs. ${product.price * product.quantity}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
            Divider(),

            // Discount Information
            Text(
              'Discounts:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Text(
              'FilliFY Coins Value : Rs. ${customer.loyaltyPoints * 100}',
              style: TextStyle(fontSize: 14, color: Colors.amber),
            ),
            Divider(),

            // Total Price Section
            SizedBox(height: 10),
            Text(
              'Total with Discount : Rs. $totalPrice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Place Order Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 360,
                  child: ElevatedButton(
                    onPressed: () {
                      // Save order to Firestore before navigating to purchase page
                      _saveOrderToFirestore(cartItems);

                      // Navigate to the purchase page (passing customer name and total price)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProductPurchasePage(
                                product: cartItems.first,
                                customerName:
                                    customer.name, // Pass customer name
                                totalPrice: totalPrice, // Pass total price
                              ),
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order placed successfully!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 20.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                      backgroundColor: Colors.deepPurple.withOpacity(0.7),
                    ),
                    child: Text(
                      'Checkout',
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
