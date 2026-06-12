import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/device.dart';

class LedControlScreen extends StatefulWidget {
  final Device device;
  const LedControlScreen({super.key, required this.device});

  @override
  State<LedControlScreen> createState() => _LedControlScreenState();
}

class _LedControlScreenState extends State<LedControlScreen> {
  Color selectedColor = const Color(0xFFFF4500);
  int selectedEffect = 0;
  double brightness = 80;
  double speed = 55;
  double sensitivity = 65;
  bool musicMode = false;

  final List<Map<String, dynamic>> effects = [
    {'name': 'Solid', 'icon': Icons.circle, 'pro': false},
    {'name': 'Rainbow', 'icon': Icons.gradient, 'pro': false},
    {'name': 'Breathing', 'icon': Icons.waves, 'pro': false},
    {'name': 'Strobe', 'icon': Icons.flash_on, 'pro': false},
    {'name': 'Chase', 'icon': Icons.arrow_forward, 'pro': false},
    {'name': 'Meteor', 'icon': Icons.star, 'pro': false},
    {'name': 'Fire', 'icon': Icons.local_fire_department, 'pro': true},
    {'name': 'Twinkle', 'icon': Icons.auto_awesome, 'pro': true},
    {'name': 'Comet', 'icon': Icons.trending_flat, 'pro': true},
    {'name': 'Ripple', 'icon': Icons.water, 'pro': true},
    {'name': 'Wipe', 'icon': Icons.format_color_fill, 'pro': true},
    {'name': 'Scan', 'icon': Icons.search, 'pro': true},
    {'name': 'Fade', 'icon': Icons.gradient, 'pro': true},
    {'name': 'Pulse', 'icon': Icons.bolt, 'pro': true},
    {'name': 'Juggle', 'icon': Icons.shuffle, 'pro': true},
    {'name': 'Popcorn', 'icon': Icons.grain, 'pro': true},
    {'name': 'Fireworks', 'icon': Icons.celebration, 'pro': true},
    {'name': 'Aurora', 'icon': Icons.blur_on, 'pro': true},
    {'name': 'Matrix', 'icon': Icons.code, 'pro': true},
    {'name': 'Candle', 'icon': Icons.local_fire_department, 'pro': true},
    {'name': 'Party', 'icon': Icons.album, 'pro': true},
    {'name': 'Sunrise', 'icon': Icons.wb_sunny, 'pro': true},
  ];

  final List<Color> presets = const [
    Color(0xFFFF0000), Color(0xFFFF4500), Color(0xFFFF8C00), Color(0xFFFFD700),
    Color(0xFFADFF2F), Color(0xFF00FF7F), Color(0xFF00BFFF), Color(0xFF7B68EE),
    Color(0xFFFF1493), Color(0xFFFFFFFF), Color(0xFFFF69B4), Color(0xFF00FFFF),
  ];

  final List<Map<String, dynamic>> musicModes = const [
    {'name': 'Beat pulse', 'icon': Icons.graphic_eq},
    {'name': 'Spectrum', 'icon': Icons.equalizer},
    {'name': 'Ripple', 'icon': Icons.water},
    {'name': 'VU meter', 'icon': Icons.speed},
    {'name': 'Strobe', 'icon': Icons.flash_on},
    {'name': 'Colour shift', 'icon': Icons.color_lens},
  ];
  int selectedMusicMode = 0;

  @override
  Widget build(BuildContext context) {
    final d = widget.device;
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('LED Studio'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Switch(
              value: d.isOn,
              onChanged: (v) => setState(() {
                d.isOn = v;
                d.sub = v ? effects[selectedEffect]['name'] : 'Off';
              }),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tubePreview(),
            const SizedBox(height: 14),
            _colorSection(),
            const SizedBox(height: 14),
            _effectsSection(),
            const SizedBox(height: 14),
            _musicSection(),
            const SizedBox(height: 14),
            _infoStats(),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
        child: child,
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
      );

  Widget _tubePreview() {
    final d = widget.device;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: !d.isOn
                  ? null
                  : selectedEffect == 1
                      ? const LinearGradient(colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple])
                      : LinearGradient(colors: [selectedColor, selectedColor.withOpacity(0.5)]),
              color: !d.isOn ? const Color(0xFF111122) : null,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    const Text('WS2812B · 60 LEDs/m · ESP32', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF1D9E75).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(d.isOn ? 'On' : 'Off', style: TextStyle(color: d.isOn ? const Color(0xFF5DCAA5) : Colors.white38, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('COLOUR'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _openColorPicker,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(colors: [
                      Color(0xFFFF0000), Color(0xFFFFFF00), Color(0xFF00FF00), Color(0xFF00FFFF), Color(0xFF0000FF), Color(0xFFFF00FF), Color(0xFFFF0000)
                    ]),
                  ),
                  child: Center(
                    child: Container(width: 26, height: 26, decoration: BoxDecoration(shape: BoxShape.circle, color: selectedColor, border: Border.all(color: Colors.white, width: 2))),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 22,
                      decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white10)),
                    ),
                    const SizedBox(height: 8),
                    Text('#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace')),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _rgbBox('R', selectedColor.red),
                        const SizedBox(width: 4),
                        _rgbBox('G', selectedColor.green),
                        const SizedBox(width: 4),
                        _rgbBox('B', selectedColor.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _label('PRESETS'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presets.map((c) {
              final sel = c.value == selectedColor.value;
              return GestureDetector(
                onTap: () => setState(() => selectedColor = c),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: sel ? Colors.white : Colors.transparent, width: 2)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _slider('Brightness', brightness, (v) => setState(() => brightness = v)),
        ],
      ),
    );
  }

  Widget _rgbBox(String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(6)),
        child: Column(
          children: [
            Text('$value', style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8)),
          ],
        ),
      ),
    );
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E32),
        title: const Text('Pick a colour', style: TextStyle(color: Colors.white, fontSize: 14)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (c) => setState(() => selectedColor = c),
            enableAlpha: false,
            displayThumbColor: true,
            portraitOnly: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 76, child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12))),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(activeTrackColor: const Color(0xFF6C63FF), thumbColor: const Color(0xFF6C63FF)),
            child: Slider(value: value, min: 0, max: 100, onChanged: onChanged),
          ),
        ),
        SizedBox(width: 36, child: Text('${value.round()}%', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white60, fontSize: 12))),
      ],
    );
  }

  Widget _effectsSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('EFFECTS', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              Text('· ${effects.length} total', style: const TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 10),
          _slider('Speed', speed, (v) => setState(() => speed = v)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.3, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: effects.length,
            itemBuilder: (_, i) {
              final e = effects[i];
              final active = i == selectedEffect;
              return GestureDetector(
                onTap: () => setState(() {
                  selectedEffect = i;
                  if (widget.device.isOn) widget.device.sub = e['name'] as String;
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF6C63FF).withOpacity(0.18) : const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: active ? const Color(0xFF6C63FF) : Colors.white10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(e['icon'] as IconData, size: 18, color: active ? const Color(0xFFA78BFA) : Colors.white54),
                      const SizedBox(height: 3),
                      Text(e['name'] as String, style: TextStyle(fontSize: 9, color: active ? Colors.white70 : Colors.white38)),
                      if (e['pro'] == true)
                        Text('PRO', style: TextStyle(fontSize: 7, color: const Color(0xFFA78BFA).withOpacity(0.7), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _musicSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.mic, color: Color(0xFFA78BFA), size: 16),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Row(
                  children: [
                    Text('Music reactive', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    SizedBox(width: 6),
                    _ProBadge(),
                  ],
                ),
              ),
              Switch(value: musicMode, onChanged: (v) => setState(() => musicMode = v)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF0D1B2E), borderRadius: BorderRadius.circular(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(14, (i) {
                final colors = [Colors.deepOrange, Colors.orange, Colors.amber, Colors.lightGreen, Colors.cyan, Colors.indigo, Colors.pink, Colors.teal, Colors.purpleAccent, Colors.greenAccent, Colors.deepPurple, Colors.deepOrange, Colors.amber, Colors.cyan];
                final h = musicMode ? (15 + (i * 17 + DateTime.now().millisecond) % 85).toDouble() : 8.0;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: h.clamp(8, 50),
                    decoration: BoxDecoration(color: colors[i], borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          const Text('REACTIVE MODE', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.5, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: musicModes.length,
            itemBuilder: (_, i) {
              final m = musicModes[i];
              final active = i == selectedMusicMode;
              return GestureDetector(
                onTap: () => setState(() => selectedMusicMode = i),
                child: Container(
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF6C63FF).withOpacity(0.18) : const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: active ? const Color(0xFF6C63FF) : Colors.white10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m['icon'] as IconData, size: 18, color: active ? const Color(0xFFA78BFA) : Colors.white54),
                      const SizedBox(height: 4),
                      Text(m['name'] as String, style: TextStyle(fontSize: 9, color: active ? Colors.white70 : Colors.white38)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _slider('Sensitivity', sensitivity, (v) => setState(() => sensitivity = v)),
        ],
      ),
    );
  }

  Widget _infoStats() {
    return Row(
      children: [
        _infoTile('38°C', 'ESP32 temp'),
        _infoTile('4.2W', 'Power use'),
        _infoTile('5V', 'Voltage'),
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
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: const Color(0xFFA78BFA).withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFA78BFA).withOpacity(0.3))),
      child: const Text('Pro', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 9)),
    );
  }
}
