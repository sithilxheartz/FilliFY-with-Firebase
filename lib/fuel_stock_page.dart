import 'package:fillify_with_firebase/tank_model.dart';
import 'package:fillify_with_firebase/tank_service.dart';
import 'package:fillify_with_firebase/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FuelStockPage extends StatefulWidget {
  @override
  _FuelStockPageState createState() => _FuelStockPageState();
}

class _FuelStockPageState extends State<FuelStockPage> {
  final FuelTankService _fuelTankService = FuelTankService();
  String? _selectedTankId; // For holding selected tank ID
  List<FuelTank> _fuelTanks = [];

  @override
  void initState() {
    super.initState();
    _loadTanks(); // Fetch tanks data when the page loads
  }

  // Fetch all tanks from Firestore
  Future<void> _loadTanks() async {
    List<FuelTank> tanks = await _fuelTankService.getAllFuelTanks();
    setState(() {
      _fuelTanks = tanks;
    });
  }

  // Fetch the current fuel level and available space for the selected tank
  Future<void> _fetchTankDetails(String tankId) async {
    final tank = await _fuelTankService.getFuelTankById(tankId);
    setState(() {
      // You can use these details to update any UI element related to the selected tank.
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Real-time Fuel Stock",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Monitor Real-time fuel stocks at a glance.",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // Dropdown to select tank (will allow user to select a tank to filter or view all tanks)
                DropdownButton<String>(
                  hint: Text("Select Tank", style: TextStyle(fontSize: 18)),
                  value: _selectedTankId,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTankId = newValue;
                    });
                    if (newValue != null) {
                      _fetchTankDetails(
                        newValue,
                      ); // Fetch more details if needed
                    }
                  },
                  items: [
                    // Adding "All Tanks" option
                    DropdownMenuItem<String>(
                      value: null, // Null value will represent "All Tanks"
                      child: Text("All Fuel Types    "),
                    ),
                    // Add tanks from the fetched list
                    ..._fuelTanks.map<DropdownMenuItem<String>>((
                      FuelTank tank,
                    ) {
                      return DropdownMenuItem<String>(
                        value: tank.id,
                        // child: Text("${tank.fuelType} - ${tank.id}"),
                        child: Text("${tank.fuelType}"),
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 10),

                // Display all the tanks or filter by selected tank
                ..._fuelTanks
                    .where(
                      (tank) =>
                          _selectedTankId == null || tank.id == _selectedTankId,
                    ) // Show all or filtered tanks
                    .map((tank) {
                      final fuelPercentage =
                          ((tank.currentLevel / tank.capacity) * 100).clamp(
                            0.0,
                            100.0,
                          );
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: FuelTankPieChart(
                          tankId: tank.id,
                          fuelPercentage: fuelPercentage,
                          fuelType: tank.fuelType,
                          capacity: tank.capacity,
                          currentLevel: tank.currentLevel,
                        ),
                      );
                    })
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FuelTankPieChart extends StatelessWidget {
  final String tankId;
  final double fuelPercentage;
  final String fuelType;
  final double capacity;
  final double currentLevel;

  FuelTankPieChart({
    required this.tankId,
    required this.fuelPercentage,
    required this.fuelType,
    required this.capacity,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    bool isLowFuel = fuelPercentage < 20; // Define low fuel threshold

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fuel Type: $fuelType',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 15),
            // Pie chart with dynamic color change based on fuel level
            SizedBox(
              width: double.infinity,
              height: 170,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 100 - fuelPercentage,
                      color:
                          isLowFuel
                              ? Colors.red.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2),
                      title: '${(100 - fuelPercentage).toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: fuelPercentage,
                      color:
                          isLowFuel
                              ? Colors.red
                              : Colors.green, // Change color if low fuel
                      title: '${fuelPercentage.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            // Displaying the current fuel level and capacity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Stock: ${currentLevel.toStringAsFixed(1)} L',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Capacity: ${capacity.toStringAsFixed(1)} L',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Icon(
                  isLowFuel
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: isLowFuel ? Colors.red : Colors.green,
                  size: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
