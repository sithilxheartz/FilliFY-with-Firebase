import 'package:fillify_with_firebase/models/pumper_model.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/service/pumper_service.dart';

class AdminApprovePage extends StatelessWidget {
  const AdminApprovePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pumperService = PumperService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Pending Registrations",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: StreamBuilder<List<Pumper>>(
          stream: pumperService.getPendingRegistrations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.teal),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "No pending registrations.",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final pendingUsers = snapshot.data!;
            return ListView.builder(
              itemCount: pendingUsers.length,
              itemBuilder: (context, index) {
                final user = pendingUsers[index];
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      user.email,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 30,
                          ),
                          onPressed: () {
                            pumperService.approveUser(
                              user.id,
                            ); // Approve the user
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red, size: 30),
                          onPressed: () {
                            pumperService.declineUser(
                              user.id,
                            ); // Decline the user
                          },
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
    );
  }
}
