class Customer {
  final String id;
  final String name;
  final String email;
  final int loyaltyPoints;
  final List<Map<String, dynamic>> orderHistory;

  final String password;
  final String mobile;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.loyaltyPoints,
    required this.orderHistory,

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

      'password': password,
      'mobile': mobile,
    };
  }
}
