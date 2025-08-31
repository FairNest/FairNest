// lib/pages/room_creation/create_room_flow.dart
import 'package:flutter/material.dart';
import 'CreateRoomDetails.dart';

/// Entry point of the room-creation wizard.
/// Uses the RoomCreationController from the app-level Provider.
///
/// Usage:
/// Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomFlow()));
class CreateRoomFlow extends StatelessWidget {
  const CreateRoomFlow({super.key});

  @override
  Widget build(BuildContext context) {
    // No ChangeNotifierProvider here - uses the one from main()
    return const CreateRoomDetails();
  }
}
