import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  // Method to format the date into a string without time
  String getFormattedDate() {
    return DateFormat(
      'yyyy-MM-dd',
    ).format(date); // Format the date to only show 'yyyy-MM-dd'
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
