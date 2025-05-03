import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class InquireModel {
  final String customerName;
  final String inquiry;
  final String status;
  final String? reply;
  final Timestamp? replyTimestamp; // Timestamp for reply time
  final String inquiryId; // Add inquiryId field

  // Constructor
  InquireModel({
    required this.customerName,
    required this.inquiry,
    required this.status,
    this.reply,
    this.replyTimestamp,
    required this.inquiryId, // Initialize inquiryId
  });

  // Factory method to create an InquireModel from Firestore document
  factory InquireModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return InquireModel(
      customerName: data['customerName'] ?? '',
      inquiry: data['inquiry'] ?? '',
      status: data['status'] ?? 'pending',
      reply: data['reply'],
      replyTimestamp: data['replyTimestamp'], // Firestore Timestamp
      inquiryId: doc.id, // Store document ID as inquiryId
    );
  }
}
