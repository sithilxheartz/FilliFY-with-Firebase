import 'package:fillify_with_firebase/shift_module_pages/pumper_register_page.dart';
import 'package:fillify_with_firebase/fuel_stock_module_pages/tank_add_new.dart';
import 'package:fillify_with_firebase/fuel_stock_module_pages/fuel_add_stock.dart';
import 'package:fillify_with_firebase/utils/colors.dart';
import 'package:flutter/material.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("management_page")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: GridView.count(
          crossAxisCount: 2, // Two items per row
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 1.3,
          children: [
            _buildMenuButton(
              context,
              label: "Add New Pumper",
              icon: Icons.person_add,
              route: PumperRegisterPage(),
            ),
            _buildMenuButton(
              context,
              label: "Add New Stock",
              icon: Icons.add_business_outlined,
              route: AddStockPage(),
            ),
            _buildMenuButton(
              context,
              label: "Add New Tank (To Remove)",
              icon: Icons.oil_barrel,
              route: NewTankPage(),
            ),
            _buildMenuButton(
              context,
              label: "Reports",
              icon: Icons.bar_chart,
              route: NewTankPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Widget route,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          );
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: primaryColor),
              SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
