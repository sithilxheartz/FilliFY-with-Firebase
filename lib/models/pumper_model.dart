class Pumper {
  final String id;
  final String name;
  final String email;
  final String password;
  final String mobileNumber; // Added mobile number field

  Pumper({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.mobileNumber, // Include mobile number in the constructor
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'mobileNumber': mobileNumber, // Include mobile number in toJson
    };
  }

  factory Pumper.fromJson(Map<String, dynamic> map) {
    return Pumper(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      mobileNumber:
          map['mobileNumber'] ?? '', // Include mobile number in fromJson
    );
  }
}
