import 'package:fillify_with_firebase/cart_service.dart';
import 'package:fillify_with_firebase/customer_model.dart';
import 'package:fillify_with_firebase/oil_shop_module.dart/product_model.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final CartService cartService;

  const CartPage({
    Key? key,
    required this.cartService,
    required Customer customer,
  }) : super(key: key);

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
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Shopping Cart'),
      ),
      body:
          _cartItems.isEmpty
              ? Center(child: Text('No products in the cart.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
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
                              leading: Image.network(
                                product.imgUrl,
                                height: 50,
                                width: 50,
                              ),
                              title: Text(product.name),
                              subtitle: Text('Qty: ${product.quantity}'),
                              trailing: Text(
                                'Rs. ${product.price * product.quantity}',
                              ),
                              onLongPress: () {
                                _removeFromCart(product);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: Rs. $_totalPrice',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Checkout functionality goes here
                          },
                          child: Text('Checkout'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
