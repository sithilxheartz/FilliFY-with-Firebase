import 'package:fillify_with_firebase/pages_shift_module/pumper_register_request_approve_page.dart';
import 'package:fillify_with_firebase/shared/custom_button.dart';
import 'package:fillify_with_firebase/shared/menu_button.dart';
import 'package:fillify_with_firebase/utils/colors.dart';
import 'package:flutter/material.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Not Completed")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            MenuButton(
              labelText: "Pumper Register Requests",
              icon: Icons.person_add,
              route: AdminApprovePage(),
            ),
            MenuButton(
              labelText: "Button 2",
              icon: Icons.add,
              route: AdminApprovePage(),
            ),
            MenuButton(
              labelText: "Button 3",
              icon: Icons.add,
              route: AdminApprovePage(),
            ),
          ],
        ),
      ),
    );
  }
}
