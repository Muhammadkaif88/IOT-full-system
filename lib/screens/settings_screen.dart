import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
              child: Row(
                children: [
                  const CircleAvatar(radius: 22, backgroundColor: Color(0xFF6C63FF), child: Text('MK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Muhammed Kaif', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                        Text('kaif@example.com', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white38),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('NETWORK & DEVICES', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _group([
              _row(Icons.wifi, 'WiFi network', 'HomeNet_5G', trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 18)),
              _row(Icons.dns_outlined, 'MQTT broker', 'broker.hivemq.com', trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 18)),
              _row(Icons.devices_other, 'Add new device', 'Scan QR or enter device ID', trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 18)),
            ]),
            const SizedBox(height: 16),
            const Text('PREFERENCES', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _group([
              _row(Icons.notifications_outlined, 'Notifications', 'Alerts, warnings, schedules',
                  trailing: Switch(value: notifications, onChanged: (v) => setState(() => notifications = v))),
              _row(Icons.dark_mode_outlined, 'Dark mode', 'Always on',
                  trailing: Switch(value: darkMode, onChanged: (v) => setState(() => darkMode = v))),
            ]),
            const SizedBox(height: 16),
            const Text('ABOUT', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _group([
              _row(Icons.info_outline, 'App version', 'SmartNest v1.0.0'),
              _row(Icons.logout, 'Sign out', '', iconColor: const Color(0xFFE24B4A), titleColor: const Color(0xFFE24B4A)),
            ]),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
    );
  }

  Widget _group(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(children: children),
    );
  }

  Widget _row(IconData icon, String title, String sub, {Widget? trailing, Color? iconColor, Color? titleColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: iconColor ?? Colors.white60),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: titleColor ?? Colors.white, fontSize: 12)),
                if (sub.isNotEmpty) Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
