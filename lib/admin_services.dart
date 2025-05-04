import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:fillify_with_firebase/admin_model.dart';

class AdminService {
  final CollectionReference adminCollection = FirebaseFirestore.instance
      .collection("Admins");

  // Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Add new admin to Firestore
  Future<void> addToAdminCollection(Admin admin) async {
    try {
      final hashedPassword = _hashPassword(admin.password);

      final Map<String, dynamic> data = {
        'name': admin.name,
        'email': admin.email,
        'password': hashedPassword,
      };

      await adminCollection.add(data);
    } catch (e) {
      throw Exception("Error adding admin to Firestore: $e");
    }
  }

  // Login admin by email and password
  Future<Admin?> loginUser(String email, String password) async {
    final hashedPassword = _hashPassword(password);

    final snapshot =
        await adminCollection
            .where('email', isEqualTo: email)
            .where('password', isEqualTo: hashedPassword)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      return Admin.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Check if the email is already taken
  Future<bool> isEmailTaken(String email) async {
    final snapshot =
        await adminCollection.where('email', isEqualTo: email).get();
    return snapshot.docs.isNotEmpty;
  }
}
