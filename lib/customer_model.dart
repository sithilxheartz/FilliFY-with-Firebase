import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Customer {
  final String id;
  final String name;
  final String email;
  final int loyaltyPoints;
  final List<Map<String, dynamic>> orderHistory;
  final List<Map<String, dynamic>> cart;
  final String password;
  final String mobile;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.loyaltyPoints,
    required this.orderHistory,
    required this.cart,
    required this.password,
    required this.mobile,
  });

  factory Customer.fromJson(Map<String, dynamic> data, String id) {
    return Customer(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      orderHistory: List<Map<String, dynamic>>.from(data['orderHistory'] ?? []),
      cart: List<Map<String, dynamic>>.from(data['cart'] ?? []),
      password: data['password'] ?? '',
      mobile: data['mobile'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'loyaltyPoints': loyaltyPoints,
      'orderHistory': orderHistory,
      'cart': cart,
      'password': password,
      'mobile': mobile,
    };
  }
}
