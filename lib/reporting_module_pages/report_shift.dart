import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/reporting_module_pages/report_shift_service.dart';
import 'package:fillify_with_firebase/models/shift_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ShiftReportPage extends StatefulWidget {
  @override
  _ShiftReportPageState createState() => _ShiftReportPageState();
}

class _ShiftReportPageState extends State<ShiftReportPage> {
  final ShiftReportService _shiftReportService = ShiftReportService();

  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _endDate = DateTime.now();
  List<Shift> _shifts = [];
  Map<String, int> _pumperShiftCount =
      {}; // To store the total shifts for each pumper

  // Fetch shifts and pumper shift count within the selected date range
  void _fetchShiftData() async {
    try {
      // Fetch shift data for all pumpers within the selected date range
      final shifts = await _shiftReportService.getShiftsByDateRange(
        _startDate,
        _endDate,
      );

      // Fetch pumper shift count within the selected date range
      final pumperShiftCount = await _shiftReportService.getShiftsCountByPumper(
        _startDate,
        _endDate,
      );

      setState(() {
        _shifts = shifts;
        _pumperShiftCount = pumperShiftCount;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching shifts data')));
    }
  }

  // Date Picker for selecting the start and end dates
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedStartDate != null) {
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: _endDate,
        firstDate: pickedStartDate,
        lastDate: DateTime.now(),
      );

      if (pickedEndDate != null) {
        setState(() {
          _startDate = pickedStartDate;
          _endDate = pickedEndDate;
        });
      }
    }
  }

  // Method to generate the PDF report
  Future<void> _generatePdfReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FillFY Management',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Shift Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Date Range: ${_startDate.toLocal().toString().split(' ')[0]} to ${_endDate.toLocal().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.blueGrey),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Total Shift Count',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Pumper', 'Total Shifts'],
                  ..._pumperShiftCount.keys.map(
                    (pumper) => [pumper, _pumperShiftCount[pumper].toString()],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Pumper Shift History',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Date', 'Shift Type', 'Pumper'],
                  ..._shifts.map(
                    (shift) => [
                      shift.getFormattedDate(),
                      shift.shiftType,
                      shift.pumperName,
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "Shift-Report.pdf",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shift Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // Date range selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Display selected date range
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date: ${_startDate.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'End Date: ${_endDate.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),

                  ElevatedButton(
                    onPressed: () => _selectDateRange(context),
                    style: ElevatedButton.styleFrom(elevation: 40),
                    child: Text(
                      'Select Dates',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Fetch data button
              Center(
                child: ElevatedButton(
                  onPressed: _fetchShiftData,
                  style: ElevatedButton.styleFrom(elevation: 40),
                  child: Text(
                    'Generate Report',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Display pumper-wise shifts and total shift count
              _pumperShiftCount.isEmpty
                  ? Center(child: Text('Please Select Date Range.'))
                  : Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //  SizedBox(height: 10),
                        // Display the number of stock loads by fuel type
                        Center(
                          child: Text(
                            'Total Shifts',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(),
                        // Display pumper shift count in a table format
                        Center(
                          child: DataTable(
                            columnSpacing: 30,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Pumper',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Shift Count',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows:
                                _pumperShiftCount.keys.map((pumper) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(pumper)),
                                      DataCell(
                                        Text(
                                          _pumperShiftCount[pumper].toString(),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                        SizedBox(height: 10),

                        // Download PDF Button
                        Center(
                          child: ElevatedButton(
                            onPressed: _generatePdfReport,
                            style: ElevatedButton.styleFrom(
                              elevation: 20,
                              backgroundColor: Colors.deepPurple,
                            ),
                            child: Text(
                              'Download Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Display the number of stock loads by fuel type
                        Center(
                          child: Text(
                            'Pumper Shift History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(),
                        // Display shifts in a data table (shift details)
                        DataTable(
                          columnSpacing: 30,
                          columns: [
                            DataColumn(
                              label: Text(
                                'Date',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Shift Type',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Pumper',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows:
                              _shifts.map((shift) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(shift.getFormattedDate()),
                                    ), // Use formatted date here
                                    DataCell(Text(shift.shiftType)),
                                    DataCell(Text(shift.pumperName)),
                                  ],
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
