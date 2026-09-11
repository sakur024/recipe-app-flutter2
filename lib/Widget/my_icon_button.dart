import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback pressed;
  final bool hasBadge;

  const MyIconButton({
    super.key,
    required this.icon,
    required this.pressed,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.white,
        fixedSize: const Size(50, 50),
        elevation: 0,
      ),
      onPressed: pressed,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: Colors.black87),
          if (hasBadge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                height: 9,
                width: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
