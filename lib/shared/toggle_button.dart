import 'package:flutter/material.dart';

class SecondButton extends StatelessWidget {
  final String labelText;
  final Color bgColor;

  final VoidCallback onPressed;
  const SecondButton({
    super.key,
    required this.labelText,
    required this.onPressed,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.45,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 0,
            //backgroundColor: Colors.blue,
          ),
          child: Text(
            labelText,
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
