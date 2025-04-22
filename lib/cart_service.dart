import 'package:fillify_with_firebase/product_model.dart';

class CartService {
  // Store cart items
  List<Product> _cartItems = [];

  // Add product to the cart
  void addToCart(Product product) {
    _cartItems.add(product);
  }

  // Remove product from the cart
  void removeFromCart(Product product) {
    _cartItems.remove(product);
  }

  // Get all cart items
  List<Product> getCartItems() {
    return _cartItems;
  }

  // Clear the cart
  void clearCart() {
    _cartItems.clear();
  }
}
