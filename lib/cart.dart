import 'package:fillify_with_firebase/cart_service.dart';
import 'package:fillify_with_firebase/product_model.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/customer_model.dart'; // Import customer model

class CartPage extends StatefulWidget {
  final CartService cartService;
  final Customer customer; // Accept customer data

  const CartPage({Key? key, required this.cartService, required this.customer})
    : super(key: key); // Modify constructor

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<Product> _cartItems;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _cartItems = widget.cartService.getCartItems();
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    double total = 0.0;
    for (var item in _cartItems) {
      total += item.price * item.quantity;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  // Remove product from cart
  void _removeFromCart(Product product) {
    setState(() {
      widget.cartService.removeProduct(product);
      _cartItems = widget.cartService.getCartItems();
      _calculateTotalPrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _cartItems.isEmpty
              ? Center(child: Text('No products in the cart.'))
              : Padding(
                padding: const EdgeInsets.only(left: 15, right: 14, bottom: 30),
                child: Column(
                  children: [
                    // New Container with loyalty points and discount information
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
                              child: Image.asset(
                                "assets/applogo.png",
                              ), // Your app logo
                            ),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello ${widget.customer.name},",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "${widget.customer.loyaltyPoints} FilliFY Coins",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Get 10% Discounts with FilliFY Coins",
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
                    SizedBox(
                      height: 10,
                    ), // Spacer between the new container and the cart items
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final product = _cartItems[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 5,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  product.imgUrl,
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                              title: Text(product.name),
                              subtitle: Text('Qty: ${product.quantity}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Rs. ${product.price * product.quantity}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed:
                                        () => _removeFromCart(
                                          product,
                                        ), // Delete product
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                'Estimated: Rs. $_totalPrice',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              child: Text(
                                'Discount: Rs. ${widget.customer.loyaltyPoints * 100}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              child: Text(
                                'Total: Rs. ${_totalPrice - widget.customer.loyaltyPoints * 100}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              // Checkout functionality goes here
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
                              backgroundColor: Colors.deepPurple.withOpacity(
                                0.7,
                              ),
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
                  ],
                ),
              ),
    );
  }
}
