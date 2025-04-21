import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillify_with_firebase/report_fuel_sales_model.dart';

class FuelSaleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to fetch real-time data from the 'FuelSaleHistory' collection
  Stream<List<FuelSale>> getFuelSaleHistoryStream(
    DateTime? startDate,
    DateTime? endDate,
  ) {
    Query query = _firestore.collection('FuelSaleHistory');

    // If a start date is provided, filter the query by start date
    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    // If an end date is provided, filter the query by end date
    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    return query.snapshots().map((querySnapshot) {
      List<FuelSale> salesData = [];

      querySnapshot.docs.forEach((doc) {
        salesData.add(
          FuelSale.fromFirestore(doc.data() as Map<String, dynamic>),
        );
      });

      return salesData;
    });
  }

  // Get total sales per fuel type (filtered by date range if needed)
  Future<Map<String, double>> getTotalSalesByFuelType({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('FuelSaleHistory');

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

      var querySnapshot = await query.get();
      Map<String, double> fuelTypeSales = {};

      for (var doc in querySnapshot.docs) {
        String fuelType = doc['fuelType'];
        double soldQuantity = doc['soldQuantity'].toDouble();

        if (fuelTypeSales.containsKey(fuelType)) {
          fuelTypeSales[fuelType] = fuelTypeSales[fuelType]! + soldQuantity;
        } else {
          fuelTypeSales[fuelType] = soldQuantity;
        }
      }

      return fuelTypeSales;
    } catch (e) {
      print('Error fetching total sales by fuel type: $e');
      return {}; // In case of error, return an empty map
    }
  }
}
