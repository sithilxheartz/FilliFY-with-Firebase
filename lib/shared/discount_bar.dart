import 'package:flutter/material.dart';

class DiscountBar extends StatelessWidget {
  const DiscountBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset("assets/applogo.png"),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Shop More, Earn More",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "Rs.1999+ Purchase = 10 FilliFY Coins",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                Text(
                  "Get 10% Discounts with FilliFY Coins",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ],
            ),
            SizedBox(width: 40),
            Icon(Icons.arrow_forward_ios, size: 25),
          ],
        ),
      ),
    );
  }
}
