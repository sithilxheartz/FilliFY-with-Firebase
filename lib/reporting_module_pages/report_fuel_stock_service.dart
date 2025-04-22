// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fillify_with_firebase/report_fuel_stock_model.dart';

// class FuelStockService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Fetch FuelStockHistory stream based on date range (real-time updates)
//   Stream<List<FuelStock>> getFuelStockHistoryStream(
//     DateTime? startDate,
//     DateTime? endDate,
//   ) {
//     Query query = _firestore.collection('FuelStockHistory');

//     // Apply date range filter if startDate is provided
//     if (startDate != null) {
//       query = query.where(
//         'date',
//         isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
//       );
//     }

//     // Apply date range filter if endDate is provided
//     if (endDate != null) {
//       query = query.where(
//         'date',
//         isLessThanOrEqualTo: Timestamp.fromDate(endDate),
//       );
//     }

//     // Real-time updates via stream
//     return query.snapshots().map((snapshot) {
//       // Map each document in the snapshot to a FuelStock object
//       return snapshot.docs
//           .map(
//             (doc) => FuelStock.fromFirestore(
//               doc.data() as Map<String, dynamic>,
//               doc.id,
//             ),
//           )
//           .toList();
//     });
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillify_with_firebase/reporting_module_pages/report_fuel_stock_model.dart';

class FuelStockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch FuelStockHistory stream based on the date range (real-time updates)
  Stream<List<FuelStock>> getFuelStockHistoryStream(
    DateTime? startDate,
    DateTime? endDate,
  ) {
    Query query = _firestore.collection('FuelStockHistory');

    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => FuelStock.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }
}
