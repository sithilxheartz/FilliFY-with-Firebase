import 'package:fillify_with_firebase/service/inquire_service.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/models/inquire_model.dart';
import 'package:fillify_with_firebase/models/customer_model.dart'; // Customer model

class InquireDisplayPage extends StatefulWidget {
  final Customer customer; // Accept customer data

  InquireDisplayPage({required this.customer});

  @override
  _InquireDisplayPageState createState() => _InquireDisplayPageState();
}

class _InquireDisplayPageState extends State<InquireDisplayPage> {
  final InquireService _inquireService = InquireService();
  TextEditingController _inquiryController = TextEditingController();

  // Handle inquiry submission
  void _submitInquiry() async {
    String inquiryText = _inquiryController.text.trim();
    if (inquiryText.isNotEmpty) {
      await _inquireService.addInquiry(
        widget.customer.name,
        inquiryText,
      ); // Use customer name
      _inquiryController.clear(); // Clear the inquiry field
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Inquiry submitted successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inquiry Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inquiry Form
            TextField(
              controller: _inquiryController,
              decoration: InputDecoration(
                labelText: ' Enter your inquiry',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitInquiry,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 20.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 0,
                backgroundColor: Colors.deepPurple,
              ),
              child: Text(
                "Submit Inquiry",
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Display Inquiries
            Expanded(
              child: StreamBuilder<List<InquireModel>>(
                stream: _inquireService.getInquiries(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No inquiries available."));
                  }

                  List<InquireModel> inquiries = snapshot.data!;

                  return ListView.builder(
                    itemCount: inquiries.length,
                    itemBuilder: (context, index) {
                      InquireModel inquiry = inquiries[index];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.people_alt),
                                  SizedBox(width: 8),
                                  Text(
                                    "Mr. ${inquiry.customerName}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Inquiry:",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "${inquiry.inquiry}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Status: ${inquiry.status}",
                                style: TextStyle(color: Colors.green),
                              ),

                              // Show Admin's reply if available
                              if (inquiry.reply != null &&
                                  inquiry.reply!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 12),
                                    Text(
                                      "FilliFY Reply:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      inquiry.reply!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Time: ${inquiry.replyTimestamp?.toDate().toLocal()}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
