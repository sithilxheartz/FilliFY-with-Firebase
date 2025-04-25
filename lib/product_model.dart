class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imgUrl;
  final String brand;
  final String size;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imgUrl,
    required this.brand,
    required this.size,
    required this.quantity,
  });

  // Convert Firestore document to Product object
  factory Product.fromJson(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      imgUrl: data['imgUrl'] ?? '',
      brand: data['brand'] ?? '',
      size: data['size'] ?? '',
      quantity: data['quantity']?.toInt() ?? 0,
    );
  }

  // Convert Product object to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imgUrl': imgUrl,
      'brand': brand,
      'size': size,
      'quantity': quantity,
    };
  }
}
