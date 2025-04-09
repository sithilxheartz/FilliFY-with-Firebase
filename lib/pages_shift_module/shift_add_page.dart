import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fillify_with_firebase/models/pumper_model.dart';
import 'package:fillify_with_firebase/models/shift_model.dart';
import 'package:fillify_with_firebase/service/shift_service.dart';
import 'package:fillify_with_firebase/shared/custom_button.dart';
import 'package:fillify_with_firebase/shared/snack_bar.dart';
import 'package:fillify_with_firebase/utils/colors.dart';
import 'package:flutter/material.dart';

class ShiftAddPage extends StatefulWidget {
  final Pumper pumper;
  ShiftAddPage({super.key, required this.pumper});

  @override
  State<ShiftAddPage> createState() => _ShiftAddPageState();
}

class _ShiftAddPageState extends State<ShiftAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pumpNumber = TextEditingController();
  final TextEditingController _shiftType = TextEditingController();
  String? _selectedPump;
  String? _selectedShiftType;
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier<DateTime>(
    DateTime.now(),
  );

  Future<void> _selectDate(BuildContext ctx) async {
    final DateTime? picked = await showDatePicker(
      context: ctx,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      initialDate: _selectedDate.value,
    );

    if (picked != null) {
      _selectedDate.value = picked;
    }
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Check if the pumper has already booked a shift for the same shift type (Day or Night) on the same day
        final pumperShiftQuerySnapshot =
            await FirebaseFirestore.instance
                .collection('shifts')
                .where('pumperName', isEqualTo: widget.pumper.name)
                .where('shiftType', isEqualTo: _shiftType.text)
                .where(
                  'date',
                  isEqualTo: DateTime(
                    _selectedDate.value.year,
                    _selectedDate.value.month,
                    _selectedDate.value.day,
                  ),
                )
                .get();

        if (pumperShiftQuerySnapshot.docs.isNotEmpty) {
          showSnackBar(
            context,
            "You can only book one pump per shift type per day. You have already booked a shift for this day.",
          );
          return;
        }

        // Check if the selected pump and shift type is already booked by another pumper
        final pumpQuerySnapshot =
            await FirebaseFirestore.instance
                .collection('shifts')
                .where('pumpNumber', isEqualTo: _pumpNumber.text)
                .where('shiftType', isEqualTo: _shiftType.text)
                .where(
                  'date',
                  isEqualTo: DateTime(
                    _selectedDate.value.year,
                    _selectedDate.value.month,
                    _selectedDate.value.day,
                  ),
                )
                .get();

        if (pumpQuerySnapshot.docs.isNotEmpty) {
          showSnackBar(
            context,
            "The selected pump and shift type is already booked for this day. Please choose a different pump.",
          );
          return;
        }

        // Proceed to add the new shift
        final Shift shift = Shift(
          id: '',
          pumpNumber: _pumpNumber.text,
          pumperName: widget.pumper.name,
          shiftType: _shiftType.text,
          date: DateTime(
            _selectedDate.value.year,
            _selectedDate.value.month,
            _selectedDate.value.day,
          ),
        );

        await ShiftService().createNewShift(shift);
        showSnackBar(context, "Successfully added shift detail.");
      } catch (error) {
        showSnackBar(context, "Failed to add shift.");
      }
    } else {
      showSnackBar(context, "Please fill all fields.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black),
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset("assets/img1.png"),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, Mr. ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.pumper.name,
                      style: TextStyle(
                        fontSize: 20,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  "Book Shift Schedule",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "Fill in the details below to book a shift schedule.",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                Divider(color: Colors.white54, height: 20),

                // Date selection
                ValueListenableBuilder<DateTime>(
                  valueListenable: _selectedDate,
                  builder: (context, date, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Date: ${date.toLocal().toString().split(" ")[0]}",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _selectDate(context),
                          icon: Icon(Icons.calendar_today),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 15),

                // Pump Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[800],
                    labelText: "Select a Pump",
                    labelStyle: TextStyle(color: Colors.white, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  value: _selectedPump,
                  items:
                      ['Pump 01', 'Pump 02', 'Pump 03', 'Pump 04']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPump = newValue;
                      _pumpNumber.text = newValue ?? "";
                    });
                  },
                ),
                SizedBox(height: 15),

                // Shift Type Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[800],
                    labelText: "Select Shift Type",
                    labelStyle: TextStyle(color: Colors.white, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  value: _selectedShiftType,
                  items:
                      ['Day Shift 🌞', 'Night Shift 🌙']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedShiftType = newValue;
                      _shiftType.text = newValue ?? "";
                    });
                  },
                ),
                SizedBox(height: 10),

                // Submit button
                Center(
                  child: CustomButton(
                    labelText: "Add Schedule",
                    onPressed: () => _submitForm(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
