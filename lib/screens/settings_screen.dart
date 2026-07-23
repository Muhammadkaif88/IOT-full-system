import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'wifi_provision_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool darkMode = true;

  void _addDevice(String name, String apSsid) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => WifiProvisionScreen(deviceName: name, apSsid: apSsid),
    ));
  }

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
            // Profile card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
              child: Row(children: [
                const CircleAvatar(radius: 22, backgroundColor: Color(0xFF6C63FF), child: Text('MK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Muhammed Kaif', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text('SmartNest home', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ])),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ]),
            ),
            const SizedBox(height: 16),

            // Add new device section
            const Text('ADD DEVICES', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
              child: Column(children: [
                _addDeviceRow(Icons.light_mode_outlined, 'SmartNest LED Tube', 'WS2812B controller', const Color(0xFFA78BFA), () => _addDevice('LED Tube', 'SmartNest-LED')),
                _addDeviceRow(Icons.water_drop_outlined, 'SmartNest Water Tank', 'Level monitor + pump', const Color(0xFF378ADD), () => _addDevice('Water Tank', 'SmartNest-Tank')),
                _addDeviceRow(Icons.lightbulb_outline, 'SmartNest Switch', 'Smart light switch', const Color(0xFF6C63FF), () => _addDevice('Smart Switch', 'SmartNest-Switch')),
                _addDeviceRow(Icons.air, 'SmartNest Fan', 'Fan speed controller', const Color(0xFF1D9E75), () => _addDevice('Fan Controller', 'SmartNest-Fan'), last: true),
              ]),
            ),
            const SizedBox(height: 16),

            // Preferences
            const Text('PREFERENCES', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _group([
              _row(Icons.notifications_outlined, 'Notifications', 'Alerts, warnings, schedules',
                  trailing: Switch(value: notifications, onChanged: (v) => setState(() => notifications = v))),
              _row(Icons.dark_mode_outlined, 'Dark mode', 'Always on',
                  trailing: Switch(value: darkMode, onChanged: (v) => setState(() => darkMode = v))),
            ]),
            const SizedBox(height: 16),

            // About
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

  Widget _addDeviceRow(IconData icon, String name, String sub, Color color, VoidCallback onTap, {bool last = false}) {
    return Container(
      decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
        title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
          child: Text('+ Add', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _group(List<Widget> children) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
    child: Column(children: children),
  );

  Widget _row(IconData icon, String title, String sub, {Widget? trailing, Color? iconColor, Color? titleColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: iconColor ?? Colors.white60)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: titleColor ?? Colors.white, fontSize: 12)),
          if (sub.isNotEmpty) Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ])),
        if (trailing != null) trailing,
      ]),
    );
  }
}
