import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'report_fuel_sales_service.dart';
import 'report_fuel_sales_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class FuelSalesReportPage extends StatefulWidget {
  @override
  _FuelSalesReportPageState createState() => _FuelSalesReportPageState();
}

class _FuelSalesReportPageState extends State<FuelSalesReportPage> {
  final FuelSaleService _fuelSaleService = FuelSaleService();
  String _searchQuery = ''; // For searching/filtering sales data
  String _selectedTimeRange = 'Last 7 Days'; // Default selected range
  DateTime? _startDate;
  DateTime? _endDate;

  // Fetch data stream for real-time data from the service
  Stream<List<FuelSale>> _fetchFuelSalesData() {
    return _fuelSaleService.getFuelSaleHistoryStream(_startDate, _endDate);
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

  // Convert fuel type sales data into rows for the DataTable
  List<DataRow> _getFuelSalesRows(Map<String, double> fuelTypeSales) {
    List<DataRow> rows = [];
    fuelTypeSales.forEach((fuelType, totalSales) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(fuelType, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataCell(Text(totalSales.toStringAsFixed(2))),
          ],
        ),
      );
    });
    return rows;
  }

  // Convert the full sales data into rows for the DataTable
  List<DataRow> _getSaleHistoryRows(List<FuelSale> salesHistory) {
    List<DataRow> rows = [];
    salesHistory.forEach((sale) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(sale.date.toDate().toString().split(' ')[0] ?? 'N/A'),
            ),
            DataCell(Text(sale.fuelType ?? 'No Fuel Type Available')),
            DataCell(Text(sale.soldQuantity.toString())),
            DataCell(Text(sale.pumperName ?? 'Unknown')),
          ],
        ),
      );
    });
    return rows;
  }

  // Function to generate and download the PDF
  Future<void> _generatePdf(
    List<FuelSale> salesHistory,
    Map<String, double> fuelTypeSales,
  ) async {
    final pdf = pw.Document();

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section with Modern Design
              pw.Text(
                'FilliFY Management',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Fuel Sales Report',
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

              // Add fuel type sales data
              pw.Text(
                'Total Fuel Sale Quantity',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Fuel Type', 'Total Sales (Liters)'],
                  ...fuelTypeSales.entries.map(
                    (entry) => [entry.key, entry.value.toStringAsFixed(2)],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Add fuel sales history
              pw.Text(
                'Fuel Sales History',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Date', 'Fuel Type', 'Qty', 'Pumper'],
                  ...salesHistory.map(
                    (sale) => [
                      sale.date.toDate().toString().split(' ')[0] ?? 'N/A',
                      sale.fuelType ?? 'No Fuel Type Available',
                      sale.soldQuantity.toString(),
                      sale.pumperName ?? 'Unknown',
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
    final file = File('${output.path}/fuel_sales_report.pdf');

    await file.writeAsBytes(await pdf.save());
    Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "Fuel_Sales_Report.pdf",
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
          'Fuel Sales Report',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<FuelSale>>(
        stream: _fetchFuelSalesData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<FuelSale> salesHistory = snapshot.data!;

          // Calculate total sales by fuel type
          Map<String, double> fuelTypeSales = {};
          salesHistory.forEach((sale) {
            String fuelType = sale.fuelType ?? 'Unknown';
            double soldQuantity = sale.soldQuantity ?? 0.0;

            if (fuelTypeSales.containsKey(fuelType)) {
              fuelTypeSales[fuelType] = fuelTypeSales[fuelType]! + soldQuantity;
            } else {
              fuelTypeSales[fuelType] = soldQuantity;
            }
          });

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Dropdown for selecting the time range
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
                  // Display the total sales by fuel type
                  Text(
                    'Total Sold Fuel Quantity',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  DataTable(
                    columnSpacing: 20,
                    columns: [
                      DataColumn(
                        label: Text(
                          'Fuel Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Total Sale',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: _getFuelSalesRows(fuelTypeSales),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _generatePdf(salesHistory, fuelTypeSales);
                      },
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
                  Text(
                    'Fuel Sales History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  // Display the fuel sales history in a DataTable
                  DataTable(
                    columnSpacing: 20,
                    columns: [
                      DataColumn(
                        label: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Fuel Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Qty',
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
                    rows: _getSaleHistoryRows(salesHistory),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
