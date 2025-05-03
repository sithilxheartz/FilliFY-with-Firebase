class ProductFeedback {
  final int rating;
  final String description;

  ProductFeedback({required this.rating, required this.description});

  // Convert Firestore document to ProductFeedback object
  factory ProductFeedback.fromJson(Map<String, dynamic> data) {
    return ProductFeedback(
      rating: data['rating'] ?? 0,
      description: data['description'] ?? '',
    );
  }
}
