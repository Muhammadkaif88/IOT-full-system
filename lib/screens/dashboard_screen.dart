import 'package:flutter/material.dart';
import '../models/device.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/device_card.dart';
import 'led_control_screen.dart';
import 'notifications_screen.dart';
import 'device_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final store = DeviceStore();
  String _filter = 'All';

  List<Device> get _filtered {
    if (_filter == 'All') return store.devices;
    if (_filter == 'Lights') return store.devices.where((d) => d.type == 'light' || d.type == 'led').toList();
    if (_filter == 'Climate') return store.devices.where((d) => d.type == 'fan' || d.type == 'curtain').toList();
    if (_filter == 'Water') return store.devices.where((d) => d.type == 'water').toList();
    return store.devices;
  }

  void _onDeviceTap(Device d) {
    if (d.type == 'led') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LedControlScreen(device: d)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceDetailScreen(device: d)))
          .then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(),
              const SizedBox(height: 14),
              _buildStatusCard(),
              const SizedBox(height: 16),
              const Text('DEVICES',
                  style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              _buildFilters(),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final d = _filtered[i];
                    return DeviceCard(
                      device: d,
                      onToggle: () => setState(() {
                        d.isOn = !d.isOn;
                        if (!d.isOn) d.sub = d.type == 'curtain' ? 'Closed' : 'Off';
                        else _restoreSub(d);
                      }),
                      onTap: () => _onDeviceTap(d),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  void _restoreSub(Device d) {
    switch (d.type) {
      case 'light':
        d.sub = '${d.brightness ?? 80}%';
        break;
      case 'fan':
        d.sub = 'Speed 3';
        break;
      case 'curtain':
        d.sub = 'Open';
        break;
      case 'led':
        d.sub = 'Rainbow';
        break;
      case 'water':
        d.sub = '73%';
        break;
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Good morning,', style: TextStyle(color: Colors.white38, fontSize: 12)),
            Text('My Home', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
          ],
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFFE24B4A), shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF6C63FF),
          child: Text('MK', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final active = store.onlineCount;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF1D9E75), shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text('$active devices active', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              const Text('All connected ✓', style: TextStyle(color: Color(0xFF5DCAA5), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statTile('28°C', 'Indoor', const Color(0xFFEF9F27)),
              _statTile('73%', 'Tank', const Color(0xFF378ADD)),
              _statTile('2.4kW', 'Power', const Color(0xFF5DCAA5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Lights', 'Climate', 'Water'];
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final f = filters[i];
          final active = f == _filter;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF6C63FF) : const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? const Color(0xFF6C63FF) : Colors.white12),
              ),
              child: Text(f, style: TextStyle(color: active ? Colors.white : Colors.white60, fontSize: 11)),
            ),
          );
        },
      ),
    );
  }
}
