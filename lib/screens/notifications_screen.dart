import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = [
      {'title': 'Water tank low alert', 'sub': 'Tank dropped below 20% — pump activated', 'time': '8:14', 'color': Color(0xFFE24B4A)},
      {'title': 'Morning scene activated', 'sub': 'Lights on, curtains open · 6:00 AM', 'time': '6:00', 'color': Color(0xFF1D9E75)},
      {'title': 'Fan left on overnight', 'sub': 'Bedroom fan running · auto-off at 2:00 AM', 'time': '2:00', 'color': Color(0xFFEF9F27)},
    ];
    final yesterday = [
      {'title': 'New device added', 'sub': 'Kitchen light (ESP8266) connected', 'time': '4:32', 'color': Color(0xFF378ADD)},
      {'title': 'All devices online', 'sub': '8/8 devices connected to network', 'time': '9:00', 'color': Color(0xFF1D9E75)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Center(child: Text('Clear all', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 12))))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('TODAY', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _group(today),
            const SizedBox(height: 18),
            const Text('YESTERDAY', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _group(yesterday),
          ],
        ),
      ),
    );
  }

  Widget _group(List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(
        children: items.map((n) {
          final isLast = items.last == n;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(margin: const EdgeInsets.only(top: 4), width: 8, height: 8, decoration: BoxDecoration(color: n['color'] as Color, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(n['sub'] as String, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
                Text(n['time'] as String, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
