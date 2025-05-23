import 'package:fillify_with_firebase/admin_register_page.dart';
import 'package:fillify_with_firebase/inquire_module/inquire_reply_page.dart';
import 'package:fillify_with_firebase/oil_shop_module/product_add_new.dart';
import 'package:fillify_with_firebase/oil_shop_module/product_stock_update.dart';
import 'package:fillify_with_firebase/reporting_module_pages/report_product_orders.dart';
import 'package:fillify_with_firebase/reporting_module_pages/report_shift.dart';
import 'package:fillify_with_firebase/reporting_module_pages/report_fuel_stock.dart';
import 'package:fillify_with_firebase/reporting_module_pages/report_fuel_sales.dart';
import 'package:fillify_with_firebase/shift_module_pages/pumper_register_page.dart';
import 'package:fillify_with_firebase/fuel_stock_module_pages/fuel_add_stock.dart';
import 'package:fillify_with_firebase/utils/colors.dart';
import 'package:flutter/material.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FilliFY Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
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
              label: "Fuel Sales Report",
              icon: Icons.bar_chart,
              route: FuelSalesReportPage(),
            ),
            _buildMenuButton(
              context,
              label: "Order Report",
              icon: Icons.bar_chart,
              route: OrderHistoryReportPage(),
            ),
            _buildMenuButton(
              context,
              label: "Fuel Stock Report",
              icon: Icons.bar_chart,
              route: FuelStockReportPage(),
            ),
            _buildMenuButton(
              context,
              label: "Shift Report",
              icon: Icons.bar_chart,
              route: ShiftReportPage(),
            ),

            _buildMenuButton(
              context,
              label: "Add Fuel Stock",
              icon: Icons.local_gas_station,
              route: AddStockPage(),
            ),
            _buildMenuButton(
              context,
              label: "Add Product Stock",
              icon: Icons.add_shopping_cart_sharp,
              route: ProductStockPage(),
            ),
            _buildMenuButton(
              context,
              label: "Add New Product",
              icon: Icons.add_business_outlined,
              route: AddProductPage(),
            ),

            // _buildMenuButton(
            //   context,
            //   label: "Add New Tank",
            //   icon: Icons.oil_barrel,
            //   route: NewTankPage(),
            // ),
            _buildMenuButton(
              context,
              label: "Customer Inquires",
              icon: Icons.message,
              route: AdminReplyPage(),
            ),
            _buildMenuButton(
              context,
              label: "Add New Admin",
              icon: Icons.person_add,
              route: AdminRegisterPage(),
            ),
            _buildMenuButton(
              context,
              label: "Add New Pumper",
              icon: Icons.person_add,
              route: PumperRegisterPage(),
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
