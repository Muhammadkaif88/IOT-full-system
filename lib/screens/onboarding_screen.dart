import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.wifi,
      'title': 'Connect your home',
      'sub': 'All your ESP32 & ESP8266 devices connect over your home WiFi network automatically.'
    },
    {
      'icon': Icons.devices_other,
      'title': 'Add your devices',
      'sub': 'Lights, fans, curtains, water tank — scan the QR code on each SmartNest device to add in seconds.'
    },
    {
      'icon': Icons.bolt,
      'title': 'Automate everything',
      'sub': 'Set schedules, create scenes, and let SmartNest handle the rest. One tap controls it all.'
    },
  ];

  void _goNext() {
    if (_page < 2) {
      _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _goHome();
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(s['icon'] as IconData,
                              color: const Color(0xFFA78BFA), size: 48),
                        ),
                        const SizedBox(height: 28),
                        Text(s['title'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(s['sub'] as String,
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                height: 1.6),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF6C63FF) : const Color(0xFF1E1E32),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(_page < 2 ? 'Next' : 'Get started'),
                    ),
                  ),
                  if (_page == 2) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _goHome,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white60,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Set up later'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
