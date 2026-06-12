import 'package:flutter/material.dart';
import '../models/device.dart';
import '../widgets/bottom_nav.dart';
import 'room_devices_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});
  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final store = DeviceStore();

  final Map<String, IconData> roomIcons = {
    'Living room': Icons.weekend_outlined,
    'Bedroom': Icons.bed_outlined,
    'Kitchen': Icons.kitchen_outlined,
    'Bathroom': Icons.bathtub_outlined,
    'Utility': Icons.build_outlined,
  };

  final Map<String, Color> roomColors = {
    'Living room': const Color(0xFF6C63FF),
    'Bedroom': const Color(0xFF1D9E75),
    'Kitchen': const Color(0xFFEF9F27),
    'Bathroom': const Color(0xFF378ADD),
    'Utility': const Color(0xFFA78BFA),
  };

  @override
  Widget build(BuildContext context) {
    final rooms = store.rooms;
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Rooms', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add, color: Colors.white60, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('${rooms.length} rooms · ${store.devices.length} devices', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: rooms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final room = rooms[i];
                    final list = store.devicesInRoom(room);
                    final active = list.where((d) => d.isOn).length;
                    final icon = roomIcons[room] ?? Icons.home_outlined;
                    final color = roomColors[room] ?? const Color(0xFF6C63FF);
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDevicesScreen(room: room))).then((_) => setState((){})),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                              child: Icon(icon, color: color, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(room, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text('${list.length} devices · $active active', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: active > 0 ? const Color(0xFF1D9E75).withOpacity(0.15) : const Color(0xFF16213E),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(active > 0 ? 'Active' : 'Inactive', style: TextStyle(color: active > 0 ? const Color(0xFF5DCAA5) : Colors.white38, fontSize: 10)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}
