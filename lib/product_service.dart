import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillify_with_firebase/feedback_model.dart';
import 'package:fillify_with_firebase/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to fetch products dynamically
  Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection('products')
        .snapshots()
        .map(
          (querySnapshot) =>
              querySnapshot.docs
                  .map(
                    (doc) => Product.fromJson(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList(),
        );
  }

  // Search products by query (filter by name or brand)
  Future<List<Product>> searchProducts(String query) async {
    var result =
        await _firestore
            .collection('products')
            .where('name', isGreaterThanOrEqualTo: query)
            .get();

    return result.docs
        .map(
          (doc) => Product.fromJson(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  // Fetch all products
  Future<List<Product>> getAllProducts() async {
    var result = await _firestore.collection('products').get();
    return result.docs
        .map(
          (doc) => Product.fromJson(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  // Add a new product to Firestore
  Future<void> addNewProduct(Product product) async {
    try {
      final docRef = await _firestore
          .collection('products')
          .add(product.toJson());
      print("Product added with ID: ${docRef.id}");
    } catch (e) {
      print("Error adding product: $e");
    }
  }

  // Update an existing product in Firestore
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toJson());
      print("Product updated: ${product.id}");
    } catch (e) {
      print("Error updating product: $e");
    }
  }

  // Delete a product from Firestore
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      print("Product deleted: $productId");
    } catch (e) {
      print("Error deleting product: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getFeedbacksStream(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('feedbacks')
        .orderBy('timestamp', descending: true) // Order feedback by timestamp
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'rating': doc['rating'], // Ensure this field exists in Firestore
              'description':
                  doc['feedback'], // Ensure this field exists in Firestore
            };
          }).toList();
        });
  }

  // Add feedback with rating and description for a product
  Future<void> addFeedback(
    String productId,
    int rating,
    String feedback,
  ) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('feedbacks')
          .add({
            'rating': rating,
            'feedback': feedback,
            'timestamp': FieldValue.serverTimestamp(),
          });
      print("Feedback added successfully");
    } catch (e) {
      print("Error adding feedback: $e");
    }
  }
}
