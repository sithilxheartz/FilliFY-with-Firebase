import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class OrderHistoryReportPage extends StatefulWidget {
  @override
  _OrderHistoryReportPageState createState() => _OrderHistoryReportPageState();
}

class _OrderHistoryReportPageState extends State<OrderHistoryReportPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = ''; // For searching/filtering orders
  String _selectedTimeRange = 'Last 7 Days'; // Default selected range
  DateTime? _startDate;
  DateTime? _endDate;

  // Fetch data stream for real-time data from the service
  Stream<List<Map<String, dynamic>>> _fetchOrderHistoryData() {
    return _firestore
        .collection('OrderHistory')
        .where('orderDate', isGreaterThanOrEqualTo: _startDate)
        .where('orderDate', isLessThanOrEqualTo: _endDate)
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((doc) => doc.data()).toList();
        });
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

  // Convert order data into rows for the DataTable
  List<DataRow> _getOrderHistoryRows(List<Map<String, dynamic>> orders) {
    List<DataRow> rows = [];
    orders.forEach((order) {
      rows.add(
        DataRow(
          cells: [
            DataCell(
              Text(
                order['orderDate'].toDate().toString().split(' ')[0] ?? 'N/A',
              ),
            ),
            DataCell(Text(order['customerName'] ?? 'Unknown')),
            DataCell(Text(order['totalPrice'].toString())),
            DataCell(Text(order['cartItems'].length.toString() ?? '0')),
          ],
        ),
      );
    });
    return rows;
  }

  // Calculate product-wise sales
  Map<String, Map<String, double>> _getProductWiseSales(
    List<Map<String, dynamic>> orders,
  ) {
    Map<String, Map<String, double>> productSales = {};

    orders.forEach((order) {
      var cartItems = order['cartItems'] as List<dynamic>;

      cartItems.forEach((item) {
        String productName = item['productName'] ?? 'Unknown Product';
        double productPrice = item['price'] ?? 0.0;
        int quantity = item['quantity'] ?? 0;

        if (!productSales.containsKey(productName)) {
          productSales[productName] = {'totalQuantity': 0, 'totalAmount': 0};
        }

        productSales[productName]!['totalQuantity'] =
            (productSales[productName]!['totalQuantity'] ?? 0) + quantity;
        productSales[productName]!['totalAmount'] =
            (productSales[productName]!['totalAmount'] ?? 0) +
            (productPrice * quantity);
      });
    });

    return productSales;
  }

  // Generate and download the PDF
  Future<void> _generatePdf(List<Map<String, dynamic>> orders) async {
    final pdf = pw.Document();

    Map<String, Map<String, double>> productWiseSales = _getProductWiseSales(
      orders,
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
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
                'Oil Product Sales Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Date Range: $_selectedTimeRange',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.blueGrey),
              ),
              pw.SizedBox(height: 10),

              // Product-wise sales table
              pw.Text(
                'Total Sold Products',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Product', 'Total Quantity', 'Total Sales (Rs.)'],
                  ...productWiseSales.entries.map(
                    (entry) => [
                      entry.key,
                      entry.value['totalQuantity'].toString(),
                      entry.value['totalAmount']!.toStringAsFixed(2),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Customer Order History',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Date', 'Customer', 'Total Price', 'Items'],
                  ...orders.map(
                    (order) => [
                      order['orderDate'].toDate().toString().split(' ')[0] ??
                          'N/A',
                      order['customerName'] ?? 'Unknown',
                      order['totalPrice'].toString(),
                      order['cartItems'].length.toString(),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/order_history_report.pdf');
    await file.writeAsBytes(await pdf.save());
    Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "Order-History-Report.pdf",
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
          'Oil Sales Report',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchOrderHistoryData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> orders = snapshot.data!;

          // Get product-wise sales data
          Map<String, Map<String, double>> productWiseSales =
              _getProductWiseSales(orders);

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
                          _setDateRange(newValue!);
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
                  Text(
                    'Total Sold Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  DataTable(
                    columnSpacing: 30,
                    columns: [
                      DataColumn(
                        label: Text(
                          'Product',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Quantity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Sales (Rs.)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows:
                        productWiseSales.entries.map((entry) {
                          return DataRow(
                            cells: [
                              DataCell(Text(entry.key)),
                              DataCell(
                                Text(entry.value['totalQuantity'].toString()),
                              ),
                              DataCell(
                                Text(
                                  entry.value['totalAmount']!.toStringAsFixed(
                                    2,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _generatePdf(orders);
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
                  Text(
                    'Customer Order History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  DataTable(
                    columnSpacing: 25,
                    columns: [
                      DataColumn(
                        label: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Items',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: _getOrderHistoryRows(orders),
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
