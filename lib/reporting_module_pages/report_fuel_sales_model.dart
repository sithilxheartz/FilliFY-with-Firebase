import 'package:cloud_firestore/cloud_firestore.dart';

class FuelSale {
  final String fuelType;
  final double soldQuantity;
  final String pumperName;
  final Timestamp date;
  final String tankId;

  FuelSale({
    required this.fuelType,
    required this.soldQuantity,
    required this.pumperName,
    required this.date,
    required this.tankId,
  });

  factory FuelSale.fromFirestore(Map<String, dynamic> data) {
    return FuelSale(
      fuelType: data['fuelType'] ?? 'Unknown',
      soldQuantity: data['soldQuantity']?.toDouble() ?? 0.0,
      pumperName: data['pumperName'] ?? 'Unknown',
      date: data['date'] as Timestamp,
      tankId: data['tankId'] ?? 'Unknown',
    );
  }
}
