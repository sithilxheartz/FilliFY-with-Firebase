import 'package:fillify_with_firebase/pages_shift_module/pumper_login_sales.dart';
import 'package:fillify_with_firebase/pages_shift_module/pumper_login_shift.dart';
import 'package:fillify_with_firebase/models/shift_model.dart';
import 'package:fillify_with_firebase/service/shift_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';

class ShiftPage extends StatefulWidget {
  const ShiftPage({super.key});

  @override
  State<ShiftPage> createState() => _ShiftPageState();
}

class _ShiftPageState extends State<ShiftPage> {
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier<DateTime>(
    DateTime.now(),
  );

  // Show date picker and update `_selectedDate`
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      initialDate: _selectedDate.value,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: mainColor,
            hintColor: mainColor,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate.value) {
      _selectedDate.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
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
                      "Pumper's Schedule",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Review the shift details for the day.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              // Date Picker
              ValueListenableBuilder<DateTime>(
                valueListenable: _selectedDate,
                builder: (context, date, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Date : ${DateFormat('yyyy-MM-dd').format(date)}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              // Shift Grid View
              ValueListenableBuilder<DateTime>(
                valueListenable: _selectedDate,
                builder: (context, date, child) {
                  return StreamBuilder<List<Shift>>(
                    stream: ShiftService().getShiftsByDate(date),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height / 5,
                            ),
                            child: const Text(
                              "No shifts available for this date.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        );
                      } else {
                        final shifts = snapshot.data!;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Display 2 cards per row
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 5,
                                childAspectRatio: 1.3,
                              ),
                          itemCount: shifts.length,
                          itemBuilder: (context, index) {
                            final shift = shifts[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                // side: BorderSide(
                                //    color: primaryColor.withOpacity(0.3),
                                //   width: 1,
                                // ),
                              ),
                              elevation: 5,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(18),
                                //   gradient: LinearGradient(
                                //     colors: [mainColor, Colors.white38],
                                //     begin: Alignment.topLeft,
                                //     end: Alignment.bottomRight,
                                //   ),
                                // ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pumper Name
                                    Row(
                                      children: [
                                        Icon(Icons.person, color: Colors.white),
                                        const SizedBox(width: 10),
                                        Text(
                                          shift.pumperName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Pump Number
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_gas_station,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          shift.pumpNumber,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Shift Type
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timelapse_sharp,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          shift.shiftType,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 50,
              width: 140,
              child: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true, // Allows you to control the height
                    backgroundColor:
                        Colors.transparent, // Transparent background
                    builder: (context) {
                      return Container(
                        height:
                            MediaQuery.of(context).size.height *
                            0.75, // Half of the screen height

                        child: Column(
                          children: [
                            // Notch at the top (removed extra white border)
                            Expanded(
                              child:
                                  PumperSignInSales(), // Your login page content
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                backgroundColor: mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_gas_station_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Add Sale",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 50,
              width: 140,
              child: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true, // Allows you to control the height
                    backgroundColor:
                        Colors.transparent, // Transparent background
                    builder: (context) {
                      return Container(
                        height:
                            MediaQuery.of(context).size.height *
                            0.75, // Half of the screen height

                        child: Column(
                          children: [
                            // Notch at the top (removed extra white border)
                            Expanded(
                              child:
                                  PumperSignInShifts(), // Your login page content
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                backgroundColor: mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_calendar_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Book Shift",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
