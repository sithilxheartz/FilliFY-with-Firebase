import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/service/report_fuel_stock_service.dart';
import 'package:fillify_with_firebase/models/report_fuel_stock_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Import for Pie Chart
import 'dart:io';

class FuelStockReportPage extends StatefulWidget {
  @override
  _FuelStockReportPageState createState() => _FuelStockReportPageState();
}

class _FuelStockReportPageState extends State<FuelStockReportPage> {
  final FuelStockService _fuelStockService = FuelStockService();
  String _searchQuery = ''; // For searching/filtering stock data
  String _selectedTimeRange = 'Last 7 Days'; // Default selected range
  DateTime? _startDate;
  DateTime? _endDate;

  // Fetch data stream for real-time data from the service
  Stream<List<FuelStock>> _fetchFuelStockData() {
    return _fuelStockService.getFuelStockHistoryStream(_startDate, _endDate);
  }

  // Set Date Range based on selection
  void _setDateRange(String range) {
    DateTime today = DateTime.now();
    DateTime startDate;

    if (range == 'Last 7 Days') {
      startDate = today.subtract(Duration(days: 7));
    } else if (range == 'Last 30 Days') {
      startDate = today.subtract(Duration(days: 30));
    } else if (range == 'Last 6 Months') {
      startDate = today.subtract(Duration(days: 180));
    } else {
      startDate = today;
    }

    setState(() {
      _startDate = startDate;
      _endDate = today;
    });
  }

  // Convert fuel stock data into rows for the DataTable
  List<DataRow> _getFuelStockRows(Map<String, double> fuelTypeStock) {
    List<DataRow> rows = [];
    fuelTypeStock.forEach((fuelType, totalStock) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(fuelType, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataCell(Text(totalStock.toStringAsFixed(2))),
          ],
        ),
      );
    });
    return rows;
  }

  // Convert the full sales data into rows for the DataTable
  List<DataRow> _getStockHistoryRows(List<FuelStock> stockHistory) {
    List<DataRow> rows = [];
    stockHistory.forEach((stock) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(stock.date.toDate().toString().split(' ')[0] ?? 'N/A'),
            ),
            DataCell(Text(stock.fuelType ?? 'No Fuel Type Available')),
            DataCell(Text(stock.addedQuantity.toString())),
          ],
        ),
      );
    });
    return rows;
  }

  // Function to generate and download the PDF
  Future<void> _generatePdf(
    List<FuelStock> stockHistory,
    Map<String, double> fuelTypeStock,
  ) async {
    final pdf = pw.Document();

    // Add a page to the PDF
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
              // Report Title
              pw.Text(
                'Fuel Stock Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Include selected date range filter in the PDF
              pw.Text(
                'Date Range: $_selectedTimeRange',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.blueGrey),
              ),
              pw.SizedBox(height: 10),

              // Add fuel stock data
              pw.Text(
                'Total Fuel Stock Quantity',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Fuel Type', 'Total Stock (Liters)'],
                  ...fuelTypeStock.entries.map(
                    (entry) => [entry.key, entry.value.toStringAsFixed(2)],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Add fuel stock history
              pw.Text(
                'Fuel Stock History',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Date', 'Fuel Type', 'Qty'],
                  ...stockHistory.map(
                    (stock) => [
                      stock.date.toDate().toString().split(' ')[0] ?? 'N/A',
                      stock.fuelType ?? 'No Fuel Type Available',
                      stock.addedQuantity.toString(),
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
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/fuel_stock_report.pdf');

    await file.writeAsBytes(await pdf.save());
    Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "Fuel-Stock-Report.pdf",
    );
  }

  @override
  void initState() {
    super.initState();
    // Set default date range to 'Last 7 Days'
    _setDateRange('Last 7 Days');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fuel Stock Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<FuelStock>>(
        stream: _fetchFuelStockData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<FuelStock> stockHistory = snapshot.data!;

          // Calculate total stock by fuel type
          Map<String, double> fuelTypeStock = {};
          stockHistory.forEach((stock) {
            String fuelType = stock.fuelType ?? 'Unknown';
            double addedQuantity = stock.addedQuantity ?? 0.0;

            if (fuelTypeStock.containsKey(fuelType)) {
              fuelTypeStock[fuelType] =
                  fuelTypeStock[fuelType]! + addedQuantity;
            } else {
              fuelTypeStock[fuelType] = addedQuantity;
            }
          });

          // Pie chart data
          List<PieChartSectionData> pieChartSections =
              fuelTypeStock.entries.map((entry) {
                return PieChartSectionData(
                  color:
                      Colors.primaries[fuelTypeStock.keys.toList().indexOf(
                            entry.key,
                          ) %
                          Colors.primaries.length],
                  value: entry.value.toDouble(),
                  title: entry.key,
                  radius: 90,
                  titleStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown for selecting the time range
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 15,
                    ),
                    child: Center(
                      child: DropdownButton<String>(
                        value: _selectedTimeRange,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedTimeRange = newValue!;
                          });
                          _setDateRange(
                            newValue!,
                          ); // Update date range on selection
                        },
                        items:
                            <String>[
                              'Last 7 Days',
                              'Last 30 Days',
                              'Last 6 Months',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Display the total stock by fuel type
                  Center(
                    child: Text(
                      'Total Fuel Loads',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 10),
                  // Pie Chart to show the fuel type loads distribution
                  SizedBox(
                    height: 250,
                    child: PieChart(PieChartData(sections: pieChartSections)),
                  ),
                  SizedBox(height: 10),
                  // Color legend for the pie chart
                  // Container(
                  //   padding: EdgeInsets.symmetric(vertical: 10),
                  //   child: Column(
                  //     children:
                  //         fuelTypeStock.entries.map((entry) {
                  //           return Row(
                  //             children: [
                  //               Container(
                  //                 width: 20,
                  //                 height: 20,
                  //                 color:
                  //                     Colors.primaries[fuelTypeStock.keys
                  //                             .toList()
                  //                             .indexOf(entry.key) %
                  //                         Colors.primaries.length],
                  //               ),
                  //               SizedBox(width: 10),
                  //               Text(entry.key, style: TextStyle(fontSize: 16)),
                  //             ],
                  //           );
                  //         }).toList(),
                  //   ),
                  // ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _generatePdf(stockHistory, fuelTypeStock);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 20,
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: Text(
                        'Download Detailed Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Fuel Stock History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),
                  // Display the fuel stock history in a DataTable
                  DataTable(
                    columnSpacing: 40,
                    columns: [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Fuel Type')),
                      DataColumn(label: Text('Qty')),
                    ],
                    rows: _getStockHistoryRows(stockHistory),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
