import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillify_with_firebase/models/report_fuel_stock_model.dart';

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
