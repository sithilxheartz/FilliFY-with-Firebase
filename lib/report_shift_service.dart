import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillify_with_firebase/models/shift_model.dart';

class ShiftReportService {
  // Reference to Firestore collection for shifts
  final CollectionReference shiftCollection = FirebaseFirestore.instance
      .collection('shifts');

  // Get shifts by date range and pumper
  Future<List<Shift>> getShiftsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot =
          await shiftCollection
              .where(
                "date",
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where("date", isLessThanOrEqualTo: Timestamp.fromDate(endDate))
              .get();

      return querySnapshot.docs.map((doc) {
        return Shift.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (error) {
      throw Exception("Error fetching shifts: $error");
    }
  }

  // Get the total number of shifts worked by each pumper
  Future<Map<String, int>> getShiftsCountByPumper(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot =
          await shiftCollection
              .where(
                "date",
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where("date", isLessThanOrEqualTo: Timestamp.fromDate(endDate))
              .get();

      Map<String, int> shiftsCount = {};

      querySnapshot.docs.forEach((doc) {
        final shift = Shift.fromJson(doc.data() as Map<String, dynamic>);
        if (shiftsCount.containsKey(shift.pumperName)) {
          shiftsCount[shift.pumperName] = shiftsCount[shift.pumperName]! + 1;
        } else {
          shiftsCount[shift.pumperName] = 1;
        }
      });

      return shiftsCount;
    } catch (error) {
      throw Exception("Error fetching shifts count: $error");
    }
  }
}
