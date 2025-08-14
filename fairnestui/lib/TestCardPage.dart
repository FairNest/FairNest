// lib/test_room_components_card_page.dart
import 'package:flutter/material.dart';
import 'package:fairnestui/components/RoomComponentsCard.dart';

class TestRoomComponentsCardPage extends StatelessWidget {
  const TestRoomComponentsCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EEE5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Test Room Components Cards',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return RoomComponentsCard(
            title: 'Room #${index + 1} - Wonderful Trio Casa',
            description:
                'We’re early risers, prefer a quiet space, and rotate chores weekly. '
                'Friendly vibes, clean kitchen, and calm evenings. Index: $index',
            memberCount: (index % 3) + 1,
            memberMax: 3,
            compatibilityPct: 70 + index * 5,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomDetailPage(
                    title: 'Room #${index + 1} Detail',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RoomDetailPage extends StatelessWidget {
  final String title;
  const RoomDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'This is the detail page for $title.',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
