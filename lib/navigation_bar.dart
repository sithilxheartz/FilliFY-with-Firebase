import 'package:fillify_with_firebase/fuel_stock_page.dart';
import 'package:fillify_with_firebase/management_page.dart';
import 'package:fillify_with_firebase/oil_shop_page.dart';
import 'package:fillify_with_firebase/shift_page.dart';
import 'package:flutter/material.dart';

class HomeBar extends StatefulWidget {
  const HomeBar({super.key});

  @override
  State<HomeBar> createState() => _HomeBarState();
}

class _HomeBarState extends State<HomeBar> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  static const List<Widget> _pages = [
    ShopPage(),
    FuelStockPage(),
    ShiftPage(),
    ManagementPage(),
  ];

  final List<IconData> icons = [
    Icons.store,
    Icons.local_gas_station,
    Icons.calendar_month_sharp,
    Icons.settings,
  ];

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
    return segmentWidth * index + (segmentWidth - 50) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 13, right: 13, bottom: 13),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
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
                    top: 10,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
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
                          height: 70,
                          child: Center(
                            child: Icon(
                              icons[index],
                              size: 36,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
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
