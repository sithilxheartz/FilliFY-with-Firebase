import 'package:fillify_with_firebase/models/product_model.dart';

class CartService {
  List<Product> _cartItems = [];

  // Add product to the cart
  void addProduct(Product product) {
    final index = _cartItems.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      // If the product is already in the cart, increase the quantity
      _cartItems[index] = Product(
        id: _cartItems[index].id,
        name: _cartItems[index].name,
        description: _cartItems[index].description,
        price: _cartItems[index].price,
        imgUrl: _cartItems[index].imgUrl,
        brand: _cartItems[index].brand,
        size: _cartItems[index].size,
        quantity: _cartItems[index].quantity + 1,
      );
    } else {
      // Add new product with quantity = 1
      _cartItems.add(
        Product(
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          imgUrl: product.imgUrl,
          brand: product.brand,
          size: product.size,
          quantity: 1,
        ),
      );
    }
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
