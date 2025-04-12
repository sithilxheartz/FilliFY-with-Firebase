import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/tank_model.dart';
import 'package:fillify_with_firebase/tank_service.dart';
import 'package:fillify_with_firebase/shared/custom_button.dart';

class AddStockPage extends StatefulWidget {
  const AddStockPage({super.key});

  @override
  _AddStockPageState createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final FuelTankService _fuelTankService = FuelTankService();
  String? _selectedTankId; // For holding selected tank ID
  double _addedQuantity = 0.0; // For holding quantity input
  double? _currentStock; // To hold the current stock level of the selected tank
  double?
  _availableSpace; // To calculate the remaining available space in the tank
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
      _currentStock = tank?.currentLevel;
      _availableSpace =
          tank?.capacity != null && tank?.currentLevel != null
              ? tank!.capacity - tank.currentLevel
              : 0.0;
    });
  }

  // Handle the form submission
  void _submitStock() async {
    if (_selectedTankId == null || _addedQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a tank and enter a valid quantity.'),
        ),
      );
      return;
    }

    if (_addedQuantity > (_availableSpace ?? 0.0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough available space in this tank.')),
      );
      return;
    }

    try {
      await _fuelTankService.addFuelStockRecord(
        _selectedTankId!,
        _addedQuantity,
      );
      // Refresh the current stock and available space after adding new stock
      _fetchTankDetails(_selectedTankId!);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fuel stock added successfully!')));

      // Clear the input fields and navigate back to the previous page
      setState(() {
        _selectedTankId = null;
        _addedQuantity = 0.0;
      });

      // Navigator.pop(context); // Navigate back to the previous page
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding fuel stock: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset("assets/bowser.png"),
              ),
              const SizedBox(height: 10),
              Text(
                "Add New Stock",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "Fill in the details below to adding new stock.",
                style: TextStyle(color: Colors.white70),
              ),
              Divider(),
              SizedBox(height: 8),
              // Dropdown to select tank
              Text(
                "Select Tank :",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),

              _fuelTanks.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButton<String>(
                    hint: Text("Choose Tank", style: TextStyle(fontSize: 18)),
                    value: _selectedTankId,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTankId = newValue;
                      });
                      if (newValue != null) {
                        _fetchTankDetails(
                          newValue,
                        ); // Fetch tank details when a tank is selected
                      }
                    },
                    items:
                        _fuelTanks.map<DropdownMenuItem<String>>((
                          FuelTank tank,
                        ) {
                          return DropdownMenuItem<String>(
                            value: tank.id,
                            child: Text("${tank.fuelType} - ${tank.id}"),
                          );
                        }).toList(),
                  ),
              SizedBox(height: 16),

              // Display current stock level for the selected tank
              if (_currentStock != null)
                Text(
                  "Available Stock:  $_currentStock liters",
                  style: TextStyle(fontSize: 19, color: Colors.green),
                ),
              SizedBox(height: 8),

              // Display available space for the selected tank
              if (_availableSpace != null)
                Text(
                  "Available Space:  $_availableSpace liters",
                  style: TextStyle(fontSize: 19, color: Colors.red),
                ),
              SizedBox(height: 16),

              // Input field for added quantity
              Text(
                "Enter New Adding Quantity :",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 13),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _addedQuantity = double.tryParse(value) ?? 0.0;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Enter quantity in Liters ",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),

              CustomButton(labelText: "Add Stock", onPressed: _submitStock),
            ],
          ),
        ),
      ),
    );
  }
}
