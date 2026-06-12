import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;
  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late Device d;
  double brightness = 80;
  double fanSpeed = 3;
  double curtainPos = 100;
  double tankLevel = 73;
  bool pumpAuto = true;

  @override
  void initState() {
    super.initState();
    d = widget.device;
    brightness = (d.brightness ?? 80).toDouble();
    if (d.type == 'water') tankLevel = 73;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: Text(d.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Switch(
              value: d.isOn,
              onChanged: (v) => setState(() {
                d.isOn = v;
                if (!v) d.sub = d.type == 'curtain' ? 'Closed' : 'Off';
              }),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _deviceCard(),
            const SizedBox(height: 16),
            if (d.type == 'light') _lightControls(),
            if (d.type == 'fan') _fanControls(),
            if (d.type == 'curtain') _curtainControls(),
            if (d.type == 'water') _waterControls(),
            const SizedBox(height: 16),
            _infoStats(),
          ],
        ),
      ),
    );
  }

  Widget _deviceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: d.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: d.color.withOpacity(0.15), borderRadius: BorderRadius.circular(18)),
            child: Icon(d.icon, color: d.color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(d.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(d.room, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: d.isOn ? const Color(0xFF1D9E75).withOpacity(0.15) : Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              d.isOn ? 'Online' : 'Offline',
              style: TextStyle(color: d.isOn ? const Color(0xFF5DCAA5) : Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _lightControls() {
    return _sectionCard(title: 'BRIGHTNESS', children: [
      Row(
        children: [
          const Icon(Icons.brightness_low, color: Colors.white38, size: 18),
          Expanded(
            child: Slider(
              value: brightness,
              min: 0,
              max: 100,
              activeColor: d.color,
              onChanged: d.isOn
                  ? (v) => setState(() {
                        brightness = v;
                        d.brightness = v.round();
                        d.sub = '${v.round()}%';
                      })
                  : null,
            ),
          ),
          const Icon(Icons.brightness_high, color: Colors.white38, size: 18),
        ],
      ),
      Center(child: Text('${brightness.round()}%', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600))),
      const SizedBox(height: 8),
      const Text('MQTT topic', style: TextStyle(color: Colors.white38, fontSize: 10)),
      const SizedBox(height: 2),
      Text(d.mqttTopic, style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace')),
    ]);
  }

  Widget _fanControls() {
    return _sectionCard(title: 'FAN SPEED', children: [
      Row(
        children: List.generate(5, (i) {
          final speed = i + 1;
          final active = fanSpeed.round() == speed;
          return Expanded(
            child: GestureDetector(
              onTap: d.isOn
                  ? () => setState(() {
                        fanSpeed = speed.toDouble();
                        d.sub = 'Speed $speed';
                      })
                  : null,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active ? d.color.withOpacity(0.25) : const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: active ? d.color : Colors.white12),
                ),
                child: Center(
                    child: Text('$speed', style: TextStyle(color: active ? Colors.white : Colors.white38, fontWeight: FontWeight.w600))),
              ),
            ),
          );
        }),
      ),
      const SizedBox(height: 12),
      Text('Speed ${fanSpeed.round()} of 5', style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ]);
  }

  Widget _curtainControls() {
    return _sectionCard(title: 'CURTAIN POSITION', children: [
      Row(
        children: [
          const Text('Closed', style: TextStyle(color: Colors.white38, fontSize: 11)),
          Expanded(
            child: Slider(
              value: curtainPos,
              min: 0,
              max: 100,
              activeColor: d.color,
              onChanged: d.isOn
                  ? (v) => setState(() {
                        curtainPos = v;
                        d.sub = v.round() == 0 ? 'Closed' : (v.round() == 100 ? 'Open' : '${v.round()}% open');
                      })
                  : null,
            ),
          ),
          const Text('Open', style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
      Center(child: Text('${curtainPos.round()}%', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600))),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: d.isOn ? () => setState(() { curtainPos = 0; d.sub = 'Closed'; }) : null,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('Close', style: TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: d.isOn ? () => setState(() { curtainPos = 100; d.sub = 'Open'; }) : null,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('Open', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _waterControls() {
    return _sectionCard(title: 'WATER TANK', children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 90,
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFF378ADD), width: 2), borderRadius: BorderRadius.circular(10)),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FractionallySizedBox(
                  heightFactor: tankLevel / 100,
                  widthFactor: 1,
                  child: Container(decoration: BoxDecoration(color: const Color(0xFF378ADD).withOpacity(0.4), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${tankLevel.round()}%', style: const TextStyle(color: Color(0xFF378ADD), fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(tankLevel > 90 ? 'Tank full' : tankLevel < 20 ? 'Tank low!' : 'Level normal',
                    style: TextStyle(color: tankLevel < 20 ? const Color(0xFFE24B4A) : const Color(0xFF5DCAA5), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          const Icon(Icons.settings_suggest_outlined, color: Colors.white38, size: 18),
          const SizedBox(width: 8),
          const Text('Auto pump mode', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Switch(value: pumpAuto, onChanged: (v) => setState(() => pumpAuto = v)),
        ],
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: pumpAuto ? null : () => setState(() => tankLevel = (tankLevel + 10).clamp(0, 100)),
          icon: const Icon(Icons.water_drop, size: 18),
          label: const Text('Run pump now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF378ADD),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    ]);
  }

  Widget _infoStats() {
    return Row(
      children: [
        _infoTile('38°C', 'Board temp'),
        _infoTile('4.2W', 'Power use'),
        _infoTile('12h', 'On today'),
      ],
    );
  }

  Widget _infoTile(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
