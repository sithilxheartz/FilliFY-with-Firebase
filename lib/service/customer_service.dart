import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillify_with_firebase/models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new customer
  Future<void> registerCustomer(Customer customer) async {
    try {
      final customerRef = _firestore.collection('customers').doc();
      await customerRef.set(customer.toJson());
    } catch (e) {
      throw e;
    }
  }

  // Customer login (Check email and password)
  Future<Customer?> loginCustomer(String email, String password) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('customers')
              .where('email', isEqualTo: email)
              .where('password', isEqualTo: password)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // Invalid credentials
      } else {
        final doc = querySnapshot.docs.first;
        return Customer.fromJson(doc.data(), doc.id);
      }
    } catch (e) {
      throw e;
    }
  }

  // Update customer loyalty points to 0 after the order is placed
  Future<void> resetLoyaltyPoints(String customerId) async {
    try {
      await _firestore.collection('customers').doc(customerId).update({
        'loyaltyPoints': 0, // Set loyalty points to 0
      });
      print("Loyalty points reset to 0 for customer: $customerId");
    } catch (e) {
      print("Error resetting loyalty points: $e");
    }
  }
}
