import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String labelText; // The label text of the button
  final IconData icon; // The icon to be displayed on the button
  final Widget route; // The page to navigate to when the button is pressed

  const MenuButton({
    super.key,
    required this.labelText,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the page (widget) directly
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => route),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 20.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 0,
            backgroundColor: Colors.blue,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon, // Custom icon
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                labelText, // Custom text
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
