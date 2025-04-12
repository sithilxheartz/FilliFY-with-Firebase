import 'package:fillify_with_firebase/fuel_stock_page.dart';
import 'package:fillify_with_firebase/pages_shift_module/pumper_register_page.dart';
import 'package:fillify_with_firebase/shared/custom_button.dart';
import 'package:fillify_with_firebase/shared/menu_button.dart';
import 'package:fillify_with_firebase/tank_add_new.dart';
import 'package:fillify_with_firebase/tank_add_sales.dart';
import 'package:fillify_with_firebase/tank_add_stock.dart';
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
              labelText: "Register New Pumper",
              icon: Icons.person_add,
              route: PumperRegisterPage(),
            ),
            MenuButton(
              labelText: "Add New Stock",
              icon: Icons.add_business_outlined,
              route: AddStockPage(),
            ),
            MenuButton(
              labelText: "add new tanks",
              icon: Icons.add,
              route: NewTankPage(),
            ),
            MenuButton(
              labelText: "stock vieewww",
              icon: Icons.add,
              route: FuelStockPage(),
            ),
            // MenuButton(
            //   labelText: "add salessssssssss",
            //   icon: Icons.add,
            //   route: AddSalesPage(),
            // ),
          ],
        ),
      ),
    );
  }
}
