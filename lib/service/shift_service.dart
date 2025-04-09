import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillify_with_firebase/models/shift_model.dart';

class ShiftService {
  // Reference to the fuel stock collection
  final CollectionReference shiftCollection = FirebaseFirestore.instance
      .collection("shifts");

  /// Method to add a new shift to Firebase
  Future<String> createNewShift(Shift shift) async {
    try {
      // Convert object to JSON and remove 'id' since Firestore generates it
      final Map<String, dynamic> data = shift.toJson();

      // Add stock to Firestore and get the document reference
      final DocumentReference docRef = await shiftCollection.add(data);

      // update the course document with the generated id
      await docRef.update({'id': docRef.id});

      print("✅ Fuel stock saved with ID: ${docRef.id}");
      return docRef.id; // Return the generated ID
    } catch (error) {
      print("❌ Error saving fuel stock: $error");
      rethrow; // Throw the error for further handling
    }
  }

  Stream<List<Shift>> getShiftsByDate(DateTime selectedDate) {
    try {
      return shiftCollection
          .where(
            "date",
            isGreaterThanOrEqualTo: Timestamp.fromDate(
              DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
            ),
          )
          .where(
            "date",
            isLessThan: Timestamp.fromDate(
              DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day + 1,
              ),
            ),
          )
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map(
                  (doc) => Shift.fromJson(doc.data() as Map<String, dynamic>),
                )
                .toList();
          });
    } catch (error) {
      print("Error fetching shifts: $error");
      return Stream.empty();
    }
  }
}
