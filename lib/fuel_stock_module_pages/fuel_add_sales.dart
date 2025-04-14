import 'package:fillify_with_firebase/shared/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/models/tank_model.dart';
import 'package:fillify_with_firebase/service/tank_service.dart';
import 'package:fillify_with_firebase/models/pumper_model.dart';

class AddSalesPage extends StatefulWidget {
  final Pumper pumper; // Accept Pumper object

  const AddSalesPage({
    super.key,
    required this.pumper,
  }); // Constructor to receive the pumper

  @override
  _AddSalesPageState createState() => _AddSalesPageState();
}

class _AddSalesPageState extends State<AddSalesPage> {
  final FuelTankService _fuelTankService = FuelTankService();
  String? _selectedTankId; // For holding selected tank ID
  double _soldQuantity = 0.0; // For holding quantity input
  double? _currentStock; // To hold the current stock level of the selected tank
  double?
  _availableSpace; // To calculate the remaining available space in the tank
  List<FuelTank> _fuelTanks = [];
  String _pumperId = ""; // Pumper ID for sales
  String _pumperName = ""; // Pumper Name for sales

  @override
  void initState() {
    super.initState();
    _loadTanks(); // Fetch tanks data when the page loads
    _pumperId =
        widget.pumper.id; // Set the pumperId from the passed pumper object
    _pumperName =
        widget.pumper.name; // Set the pumperName from the passed pumper object
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

  void _submitSale() async {
    // Check if the selected tank is valid
    if (_selectedTankId == null || _soldQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a tank and enter a valid quantity.'),
        ),
      );
      return;
    }

    // Check if the sold quantity exceeds the available stock
    if (_currentStock == null || _soldQuantity > _currentStock!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough fuel in the tank to process sale.')),
      );
      return;
    }

    // Proceed to add the sale record
    try {
      await _fuelTankService.addFuelSaleRecord(
        _selectedTankId!,
        _soldQuantity,
        _pumperName, // Only pass the pumper name
      );

      // Refresh the current stock and available space after adding the sale
      _fetchTankDetails(_selectedTankId!);

      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fuel sale added successfully!')));

      // Clear the form data
      setState(() {
        _selectedTankId = null; // Clear the selected tank
        _soldQuantity = 0.0; // Clear the sold quantity
      });

      // Optionally clear the text field by resetting the controller (if applicable)
      // If you use a TextEditingController for the soldQuantity field, you can clear it here:
      // _quantityController.clear();  // If you are using a TextEditingController
      //  Navigator.pop(context); // Navigate back to the previous page
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding fuel sale: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset("assets/gasfiller.png"),
              ),
              const SizedBox(height: 10),
              Text(
                "Hello, Mr. ${widget.pumper.name}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Add Fuel Sales",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "Fill in the details below to adding fuel sales.",
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
                        _fetchTankDetails(newValue);
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

              // Input field for sold quantity
              Text(
                "Enter Quantity Sold :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 13),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _soldQuantity = double.tryParse(value) ?? 0.0;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Enter quantity in Liters ",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              CustomButton(labelText: "Add Sale", onPressed: _submitSale),
            ],
          ),
        ),
      ),
    );
  }
}
