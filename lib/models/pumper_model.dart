class Pumper {
  final String id;
  final String name;
  final String email;
  final String password;

  Pumper({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'password': password};
  }

  factory Pumper.fromJson(Map<String, dynamic> map) {
    return Pumper(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }
}
