import 'package:fillify_with_firebase/oil_shop_module.dart/product_model.dart';

class CartService {
  List<Product> _cartItems = [];

  // Add product to the cart
  void addProduct(Product product) {
    _cartItems.add(product);
  }

  // Remove product from the cart
  void removeProduct(Product product) {
    _cartItems.removeWhere((item) => item.id == product.id);
  }

  // Get all cart items
  List<Product> getCartItems() {
    return _cartItems;
  }

  // Get total price of all products in the cart
  double getTotalPrice() {
    double total = 0.0;
    for (var product in _cartItems) {
      total += product.price * product.quantity;
    }
    return total;
  }
}
