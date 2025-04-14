import 'package:fillify_with_firebase/models/tank_model.dart';
import 'package:fillify_with_firebase/service/tank_service.dart';
import 'package:flutter/material.dart';

class NewTankPage extends StatefulWidget {
  @override
  _NewTankPageState createState() => _NewTankPageState();
}

class _NewTankPageState extends State<NewTankPage> {
  final _formKey = GlobalKey<FormState>();
  final _fuelTypeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _currentLevelController = TextEditingController();
  DateTime _lastRefillDate = DateTime.now();

  // Instantiate the FuelTankService
  final _fuelTankService = FuelTankService();

  // Function to handle form submission
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final fuelType = _fuelTypeController.text.trim();
      final capacity = double.tryParse(_capacityController.text) ?? 0;
      final currentLevel = double.tryParse(_currentLevelController.text) ?? 0;

      // Generate a unique tank ID (for example, using timestamp)
      final tankId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a new FuelTank object
      final newTank = FuelTank(
        id: tankId,
        fuelType: fuelType,
        capacity: capacity,
        currentLevel: currentLevel,
        lastRefillDate: _lastRefillDate,
      );

      // Add the new tank to Firestore
      await _fuelTankService.addFuelTank(newTank);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New fuel tank added successfully!')),
      );

      // Optionally, navigate to another page (e.g., fuel tank list page)
      Navigator.pop(context); // Close the form page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Fuel Tank')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fuelTypeController,
                decoration: InputDecoration(labelText: 'Fuel Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the fuel type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _capacityController,
                decoration: InputDecoration(labelText: 'Capacity (liters)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the capacity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _currentLevelController,
                decoration: InputDecoration(
                  labelText: 'Current Fuel Level (liters)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the current fuel level';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              // Date picker for the last refill date
              Row(
                children: [
                  Text('Last Refill Date: ${_lastRefillDate.toLocal()}'),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _lastRefillDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _lastRefillDate)
                        setState(() {
                          _lastRefillDate = pickedDate;
                        });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
