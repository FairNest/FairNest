import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String imagePath;

  const ProfileAvatar({
    Key? key,
    required this.name,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            imagePath,
            width: 70,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Krub', // Your custom font
            fontSize: 10,
            fontWeight: FontWeight.w500, // Medium
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
