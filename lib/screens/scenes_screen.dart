import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class ScenesScreen extends StatefulWidget {
  const ScenesScreen({super.key});
  @override
  State<ScenesScreen> createState() => _ScenesScreenState();
}

class _ScenesScreenState extends State<ScenesScreen> {
  int activeScene = 0;

  final List<Map<String, dynamic>> scenes = [
    {'name': 'Morning', 'icon': Icons.wb_sunny_outlined, 'sub': 'Lights 60% · Fan off', 'color': Color(0xFFEF9F27)},
    {'name': 'Night mode', 'icon': Icons.nightlight_outlined, 'sub': 'Dim lights · Fan 1', 'color': Color(0xFFA78BFA)},
    {'name': 'Movie', 'icon': Icons.movie_outlined, 'sub': 'Lights off · Curtain', 'color': Color(0xFF378ADD)},
    {'name': 'Away', 'icon': Icons.no_meeting_room_outlined, 'sub': 'All off · Auto only', 'color': Color(0xFFE24B4A)},
  ];

  double living = 60, bedroom = 40, fanSpeed = 2, curtain = 100;

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
                  const Text('Scenes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Text('+ New', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('QUICK SCENES', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5),
                itemCount: scenes.length,
                itemBuilder: (_, i) {
                  final s = scenes[i];
                  final active = i == activeScene;
                  final color = s['color'] as Color;
                  return GestureDetector(
                    onTap: () => setState(() => activeScene = i),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: active ? color.withOpacity(0.12) : const Color(0xFF1E1E32),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: active ? color : Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(s['icon'] as IconData, color: color, size: 24),
                          const Spacer(),
                          Text(s['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(s['sub'] as String, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              const Text('DEVICE CONTROL', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                child: Column(
                  children: [
                    Text('${scenes[activeScene]['name']} scene settings', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    _slider('Living', living, (v) => setState(() => living = v)),
                    _slider('Bedroom', bedroom, (v) => setState(() => bedroom = v)),
                    _slider('Fan speed', fanSpeed, (v) => setState(() => fanSpeed = v), max: 5, suffix: 'Spd '),
                    _slider('Curtain', curtain, (v) => setState(() => curtain = v)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged, {double max = 100, String suffix = ''}) {
    final display = suffix.isNotEmpty ? '$suffix${value.round()}' : '${value.round()}%';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12))),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(activeTrackColor: const Color(0xFF6C63FF), thumbColor: const Color(0xFF6C63FF)),
              child: Slider(value: value, min: 0, max: max, onChanged: onChanged),
            ),
          ),
          SizedBox(width: 50, child: Text(display, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white60, fontSize: 12))),
        ],
      ),
    );
  }
}
