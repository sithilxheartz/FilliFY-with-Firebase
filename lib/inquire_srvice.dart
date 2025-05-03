import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillify_with_firebase/inquire_model.dart';

class InquireService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new inquiry with customerName
  Future<void> addInquiry(String customerName, String inquiryText) async {
    try {
      await _firestore.collection('inquiries').add({
        'customerName': customerName, // Store the customer's name
        'inquiry': inquiryText,
        'status': 'pending', // Initial status as pending
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding inquiry: $e");
    }
  }

  // Fetch all inquiries
  Stream<List<InquireModel>> getInquiries() {
    return _firestore
        .collection('inquiries')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => InquireModel.fromFirestore(doc))
              .toList();
        });
  }

  // Add reply to a specific inquiry (Admin Reply)
  Future<void> addReply(String inquiryId, String replyText) async {
    try {
      await _firestore.collection('inquiries').doc(inquiryId).update({
        'reply': replyText,
        'status': 'replied',
        'replyTimestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding reply: $e");
    }
  }
}
