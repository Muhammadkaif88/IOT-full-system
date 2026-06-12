import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<Map<String, dynamic>> schedules = [
    {'time': '06:00', 'name': 'Morning lights on', 'days': [1,1,1,1,1,0,0], 'on': true},
    {'time': '07:30', 'name': 'Open curtains', 'days': [1,1,1,1,1,1,0], 'on': true},
    {'time': '09:00', 'name': 'Tank pump check', 'days': [1,1,1,1,1,1,1], 'on': true},
    {'time': '22:00', 'name': 'Night mode', 'days': [1,1,1,1,1,1,1], 'on': true},
    {'time': '23:30', 'name': 'All lights off', 'days': [1,1,1,1,1,1,1], 'on': false},
  ];

  final dayLabels = ['M','T','W','T','F','S','S'];

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
              Row(
                children: [
                  const Text('Schedule', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Text('+ Add', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('ACTIVE SCHEDULES', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                  child: ListView.separated(
                    itemCount: schedules.length,
                    separatorBuilder: (_, i) => Divider(color: Colors.white.withOpacity(0.06), height: 1),
                    itemBuilder: (_, i) {
                      final s = schedules[i];
                      final on = s['on'] as bool;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text(s['time'] as String, style: TextStyle(color: on ? Colors.white : Colors.white38, fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['name'] as String, style: TextStyle(color: on ? Colors.white : Colors.white38, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: List.generate(7, (d) {
                                      final active = (s['days'] as List<int>)[d] == 1;
                                      return Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        width: 18, height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: active ? (on ? const Color(0xFF6C63FF) : const Color(0xFF2A2A40)) : const Color(0xFF16213E),
                                        ),
                                        child: Center(child: Text(dayLabels[d], style: TextStyle(fontSize: 9, color: active && on ? Colors.white : Colors.white38))),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Switch(value: on, onChanged: (v) => setState(() => s['on'] = v)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }
}
