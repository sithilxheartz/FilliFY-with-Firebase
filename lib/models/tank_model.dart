class FuelTank {
  final String id; // Unique identifier for the tank
  final String fuelType; // Type of fuel (e.g., Petrol, Diesel, etc.)
  final double capacity; // Maximum capacity of the fuel tank (in liters)
  double currentLevel; // Current fuel level in the tank (in liters)
  DateTime lastRefillDate; // The last date when the tank was refilled

  FuelTank({
    required this.id,
    required this.fuelType,
    required this.capacity,
    required this.currentLevel,
    required this.lastRefillDate,
  });

  // Method to check if the tank is full
  bool isFull() {
    return currentLevel >= capacity;
  }

  // Method to calculate the remaining fuel in percentage
  double fuelPercentage() {
    return (currentLevel / capacity) * 100;
  }

  // Method to calculate how much more fuel is needed to fill the tank
  double fuelNeededToFull() {
    return capacity - currentLevel;
  }

  // Method to refill the tank
  void refill(double amount) {
    if (currentLevel + amount <= capacity) {
      currentLevel += amount;
      lastRefillDate = DateTime.now();
    } else {
      currentLevel = capacity;
    }
  }

  // Method to get the data as a map (for database, APIs, etc.)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fuelType': fuelType,
      'capacity': capacity,
      'currentLevel': currentLevel,
      'lastRefillDate': lastRefillDate.toIso8601String(),
    };
  }

  // Factory method to create a FuelTank object from a map (for database, APIs, etc.)
  factory FuelTank.fromJson(Map<String, dynamic> map, String id) {
    return FuelTank(
      id: map['id'],
      fuelType: map['fuelType'],
      capacity: map['capacity'],
      currentLevel: map['currentLevel'],
      lastRefillDate: DateTime.parse(map['lastRefillDate']),
    );
  }
}
