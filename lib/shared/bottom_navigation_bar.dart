import 'package:fillify_with_firebase/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/fuel_stock_page.dart';
import 'package:fillify_with_firebase/management_page.dart';
import 'package:fillify_with_firebase/oil_shop_page.dart';
import 'package:fillify_with_firebase/pages_shift_module/shift_view_page.dart';

class HomeBar extends StatefulWidget {
  const HomeBar({super.key});

  @override
  State<HomeBar> createState() => _HomeBarState();
}

class _HomeBarState extends State<HomeBar> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  // Updated the _pages list without using const.
  static final List<Widget> _pages = [
    ShopPage(),
    FuelStockPage(), // No const here, dynamic widget
    ShiftPage(),
    ManagementPage(),
  ];

  final List<IconData> icons = [
    Icons.store,
    Icons.local_gas_station,
    Icons.calendar_month_sharp,
    Icons.settings,
  ];

  final List<String> iconNames = ["Shop", "Fuel", "Shifts", "Settings"];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _onTapItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateIndicatorPosition(int index, double width) {
    final segmentWidth = width / icons.length;
    return segmentWidth * index +
        (segmentWidth - 70) / 2; // Adjust the position
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1), // Dark background for the bar
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final posX = _calculateIndicatorPosition(
                _selectedIndex,
                constraints.maxWidth,
              );
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: posX,
                    top: 0,
                    child: Container(
                      width: 70, // Adjust width of indicator
                      height: 3, // Small height to look sleek
                      decoration: BoxDecoration(
                        color: Colors.white, // Active indicator color
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(icons.length, (index) {
                      bool isSelected = _selectedIndex == index;
                      return GestureDetector(
                        onTap: () => _onTapItem(index),
                        child: SizedBox(
                          width: constraints.maxWidth / icons.length,
                          height: 75,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icons[index],
                                size: 29,
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                              ),

                              Text(
                                iconNames[index],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
