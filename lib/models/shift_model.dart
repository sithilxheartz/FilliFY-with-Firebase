import 'package:cloud_firestore/cloud_firestore.dart';

class Shift {
  final String id;
  final DateTime date;
  final String pumpNumber;
  final String pumperName;
  final String shiftType;

  Shift({
    required this.id,
    required this.date,
    required this.pumpNumber,
    required this.pumperName,
    required this.shiftType,
  });

  // method to convert the firebase document in to a dart object
  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] ?? '',
      pumpNumber: json['pumpNumber'] ?? '',
      pumperName: json['pumperName'] ?? '',
      shiftType: json['shiftType'] ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // convert the product model to a firebase document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pumpNumber': pumpNumber,
      'pumperName': pumperName,
      'shiftType': shiftType,
      'date': date,
    };
  }
}
