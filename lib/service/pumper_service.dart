import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:fillify_with_firebase/models/pumper_model.dart';
import 'dart:convert';

class PumperService {
  final CollectionReference pumperCollection = FirebaseFirestore.instance
      .collection("Pumpers");

  // Method to hash the password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to bytes
    final digest = sha256.convert(bytes); // Apply SHA256 hash
    return digest.toString(); // Return hashed password
  }

  // 🔹 Directly add a pumper to the 'Pumper' collection
  Future<void> addToPumperCollection(Pumper pumper) async {
    try {
      // Hash the password before storing it
      final hashedPassword = _hashPassword(pumper.password);

      // Create a map with the pumper data, including mobile number
      final Map<String, dynamic> data = {
        'name': pumper.name,
        'email': pumper.email,
        'password': hashedPassword,
        'mobileNumber': pumper.mobileNumber, // Add mobile number to the map
      };

      // Debugging: Check what is being added to Firestore
      print("Adding data to Firestore: $data");

      // Add the pumper to the collection
      await pumperCollection.add(data);
      print("Pumper registration added directly to the Pumper collection.");
    } catch (e) {
      throw Exception("Error adding pumper to collection: $e");
    }
  }

  // 🔹 Login user by checking email and hashed password
  Future<Pumper?> loginUser(String email, String password) async {
    final hashedPassword = _hashPassword(password); // Hash the entered password

    final snapshot =
        await pumperCollection
            .where('email', isEqualTo: email)
            .where('password', isEqualTo: hashedPassword)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      return Pumper.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    } else {
      return null;
    }
  }

  // 🔹 Optional: Check if email is already taken (useful during registration)
  Future<bool> isEmailTaken(String email) async {
    final snapshot =
        await pumperCollection.where('email', isEqualTo: email).get();
    return snapshot.docs.isNotEmpty;
  }
}
