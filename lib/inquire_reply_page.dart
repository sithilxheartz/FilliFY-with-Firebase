import 'package:fillify_with_firebase/inquire_model.dart';
import 'package:fillify_with_firebase/inquire_srvice.dart';
import 'package:flutter/material.dart';

class AdminReplyPage extends StatefulWidget {
  @override
  _AdminReplyPageState createState() => _AdminReplyPageState();
}

class _AdminReplyPageState extends State<AdminReplyPage> {
  final InquireService _inquireService = InquireService();
  TextEditingController _replyController = TextEditingController();

  // Handle admin reply submission
  void _submitReply(String inquiryId) async {
    String replyText = _replyController.text.trim();
    if (replyText.isNotEmpty) {
      await _inquireService.addReply(inquiryId, replyText);
      _replyController.clear(); // Clear the reply field
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Reply submitted successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Inquiries")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Inquiries and Admin Reply Section
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
                              SizedBox(height: 5),
                              if (inquiry.status == 'replied') ...[
                                SizedBox(height: 5),
                                Text(
                                  "Admin Reply:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "${inquiry.reply}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Time: ${inquiry.replyTimestamp?.toDate().toString() ?? ''},",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                              if (inquiry.status == 'pending') ...[
                                TextField(
                                  controller: _replyController,
                                  decoration: InputDecoration(
                                    labelText: ' Reply to customer inquire...',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 4,
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    _submitReply(inquiry.inquiryId);
                                  },
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
                                    "Submit Reply",
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
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
