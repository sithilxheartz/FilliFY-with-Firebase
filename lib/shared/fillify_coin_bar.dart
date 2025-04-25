import 'package:fillify_with_firebase/utils/colors.dart';
import 'package:flutter/material.dart';

class FillifyCoinBar extends StatelessWidget {
  const FillifyCoinBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.2),
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
              children: [
                Text(
                  "Shop More, Earn More",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "Rs.1999+ Purchase = 10 FilliFY Coin",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                ),
                SizedBox(height: 1),
                Text(
                  "Get 10% Discounts with FilliFY Coins",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ],
            ),
            SizedBox(width: 60),
            Icon(Icons.discount_outlined, size: 30),
          ],
        ),
      ),
    );
  }
}
