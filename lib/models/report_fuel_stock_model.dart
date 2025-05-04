import 'package:cloud_firestore/cloud_firestore.dart';

class FuelStock {
  final String id;
  final String fuelType;
  final double addedQuantity;
  final Timestamp date;

  FuelStock({
    required this.id,
    required this.fuelType,
    required this.addedQuantity,
    required this.date,
  });

  // Factory constructor to convert Firestore document data into a FuelStock object
  factory FuelStock.fromFirestore(Map<String, dynamic> data, String id) {
    return FuelStock(
      id: id,
      fuelType: data['fuelType'] ?? 'Unknown',
      addedQuantity: data['addedQuantity']?.toDouble() ?? 0.0,
      date: data['date'] ?? Timestamp.now(),
    );
  }
}
