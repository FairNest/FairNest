import 'package:flutter/material.dart';
import 'package:fairnestui/widgets/app_header.dart';

class TestHeaderPage extends StatelessWidget {
  const TestHeaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EEE5),
      body: Column(
        children: [
          AppHeader(
            title: 'Find Roommate',
            onNotificationTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification tapped!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
