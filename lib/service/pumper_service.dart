import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:fillify_with_firebase/models/pumper_model.dart';
import 'dart:convert';

class PumperService {
  final CollectionReference pumperCollection = FirebaseFirestore.instance
      .collection("Pumpers");

  final CollectionReference pendingCollection = FirebaseFirestore.instance
      .collection("pendingRegistrations");

  get pumpers => null;

  // Method to hash the password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to bytes
    final digest = sha256.convert(bytes); // Apply SHA256 hash
    return digest.toString(); // Return hashed password
  }

  // Add user to the pending registration collection
  Future<void> addToPendingRegistrations(Pumper pumper) async {
    try {
      // Hash the password before storing it
      final hashedPassword = _hashPassword(pumper.password);

      // Create a map with the user data
      final Map<String, dynamic> data = {
        'name': pumper.name,
        'email': pumper.email,
        'password': hashedPassword,
        'status': 'pending', // Add status as 'pending' initially
      };

      // Add the user to the pending collection
      final DocumentReference docRef = await pendingCollection.add(data);

      // Optionally update the document with an id (not strictly necessary)
      await docRef.update({'id': docRef.id});
      print("Registration request sent. Awaiting approval.");
    } catch (error) {
      print("Error creating pending registration: $error");
    }
  }

  // Admin approves the registration and moves the user to the main collection
  Future<void> approveUser(String pendingId) async {
    try {
      // Get the pending user data
      final pendingDoc = await pendingCollection.doc(pendingId).get();

      if (pendingDoc.exists) {
        // Create a Pumper object with the data
        final pumperData = pendingDoc.data() as Map<String, dynamic>;
        final pumper = Pumper(
          name: pumperData['name'],
          email: pumperData['email'],
          password: pumperData['password'],
          id: pendingDoc.id,
        );

        // Add the user to the main collection
        await pumperCollection.add({
          'name': pumper.name,
          'email': pumper.email,
          'password': pumper.password,
        });

        // Remove from the pending collection
        await pendingCollection.doc(pendingId).delete();
        print("User approved and moved to active users.");
      } else {
        print("Pending user not found.");
      }
    } catch (e) {
      print("Failed to approve user: $e");
    }
  }

  // Admin declines the registration request
  Future<void> declineUser(String pendingId) async {
    try {
      await pendingCollection.doc(pendingId).delete();
      print("User registration request declined.");
    } catch (e) {
      print("Failed to decline user: $e");
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

  // 🔹 Get all pending registration requests (admin side)
  Stream<List<Pumper>> getPendingRegistrations() {
    return pendingCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Pumper(
          name: data['name'],
          email: data['email'],
          password: data['password'],
          id: doc.id,
        );
      }).toList();
    });
  }
}
