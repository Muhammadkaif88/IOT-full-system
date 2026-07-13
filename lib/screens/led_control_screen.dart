import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/device.dart';
import '../services/led_service.dart';

class LedControlScreen extends StatefulWidget {
  final Device device;
  const LedControlScreen({super.key, required this.device});
  @override
  State<LedControlScreen> createState() => _LedControlScreenState();
}

class _LedControlScreenState extends State<LedControlScreen> {
  final led = LedService();
  bool _connected = false;
  bool _connecting = true;
  final _ipController = TextEditingController();

  Color selectedColor = const Color(0xFFFF4500);
  int selectedEffect = 0;
  double brightness = 80;
  double speed = 50;

  final List<Map<String, dynamic>> effects = [
    {'name': 'solid',     'label': 'Solid',     'icon': Icons.circle},
    {'name': 'rainbow',   'label': 'Rainbow',   'icon': Icons.gradient},
    {'name': 'breathing', 'label': 'Breathing', 'icon': Icons.waves},
    {'name': 'strobe',    'label': 'Strobe',    'icon': Icons.flash_on},
    {'name': 'chase',     'label': 'Chase',     'icon': Icons.arrow_forward},
    {'name': 'meteor',    'label': 'Meteor',    'icon': Icons.star},
    {'name': 'fire',      'label': 'Fire',      'icon': Icons.local_fire_department},
    {'name': 'twinkle',   'label': 'Twinkle',   'icon': Icons.auto_awesome},
    {'name': 'comet',     'label': 'Comet',     'icon': Icons.trending_flat},
    {'name': 'aurora',    'label': 'Aurora',    'icon': Icons.blur_on},
    {'name': 'party',     'label': 'Party',     'icon': Icons.celebration},
  ];

  final List<Color> presets = const [
    Color(0xFFFF0000), Color(0xFFFF4500), Color(0xFFFF8C00), Color(0xFFFFD700),
    Color(0xFFADFF2F), Color(0xFF00FF7F), Color(0xFF00BFFF), Color(0xFF7B68EE),
    Color(0xFFFF1493), Color(0xFFFFFFFF), Color(0xFFFF69B4), Color(0xFF00FFFF),
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await led.loadSavedIp();
    _ipController.text = led._espIp;
    await _connect();
  }

  Future<void> _connect() async {
    setState(() { _connecting = true; });
    final ok = await led.ping();
    if (mounted) setState(() { _connected = ok; _connecting = false; });
  }

  void _sendCommand() async {
    final hex = '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
    final ok = await led.sendFull(
      on: widget.device.isOn,
      color: hex,
      effect: effects[selectedEffect]['name'] as String,
      brightness: brightness.round(),
      speed: speed.round(),
    );
    if (mounted) {
      setState(() => _connected = ok);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ LED updated!'), backgroundColor: Color(0xFF1D9E75), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  void _showIpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E32),
        title: const Text('ESP32 IP address', style: TextStyle(color: Colors.white, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Serial Monitor il ESP32 IP kaanikkum\n"WiFi OK — 192.168.x.x"', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: _ipController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '192.168.1.100',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF16213E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await led.saveIp(_ipController.text.trim());
              if (context.mounted) Navigator.pop(context);
              await _connect();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text('Connect', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.device;
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('LED Studio'),
        actions: [
          GestureDetector(
            onTap: _showIpDialog,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(children: [
                if (_connecting)
                  const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF9F27)))
                else
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _connected ? const Color(0xFF1D9E75) : const Color(0xFFE24B4A))),
                const SizedBox(width: 5),
                Text(
                  _connecting ? 'Connecting...' : (_connected ? 'Live' : 'Offline — tap to set IP'),
                  style: TextStyle(fontSize: 11, color: _connecting ? const Color(0xFFEF9F27) : (_connected ? const Color(0xFF5DCAA5) : const Color(0xFFE24B4A))),
                ),
                const SizedBox(width: 8),
              ]),
            ),
          ),
          Switch(
            value: d.isOn,
            onChanged: (v) async {
              setState(() { d.isOn = v; d.sub = v ? effects[selectedEffect]['label'] as String : 'Off'; });
              await led.setOn(v);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status banner
          if (!_connected && !_connecting)
            GestureDetector(
              onTap: _showIpDialog,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFE24B4A).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE24B4A).withOpacity(0.3))),
                child: const Row(children: [
                  Icon(Icons.wifi_off, color: Color(0xFFE24B4A), size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text('ESP32 connect alla — IP address set cheyyan tap cheyyu', style: TextStyle(color: Color(0xFFE24B4A), fontSize: 12))),
                  Icon(Icons.arrow_forward_ios, color: Color(0xFFE24B4A), size: 12),
                ]),
              ),
            ),

          // Tube preview
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: !d.isOn ? null : selectedEffect == 1
                    ? const LinearGradient(colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple])
                    : LinearGradient(colors: [selectedColor, selectedColor.withOpacity(0.4)]),
                color: !d.isOn ? const Color(0xFF111122) : null,
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                Text('WS2812B · ESP32 · ${led._espIp}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: d.isOn ? const Color(0xFF1D9E75).withOpacity(0.15) : Colors.white10, borderRadius: BorderRadius.circular(20)),
                child: Text(d.isOn ? 'On' : 'Off', style: TextStyle(color: d.isOn ? const Color(0xFF5DCAA5) : Colors.white38, fontSize: 10)),
              ),
            ]),
          ])),
          const SizedBox(height: 12),

          // Colour
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('COLOUR'),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: _openColorPicker,
                child: Container(
                  width: 90, height: 90,
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: SweepGradient(colors: [Color(0xFFFF0000), Color(0xFFFFFF00), Color(0xFF00FF00), Color(0xFF00FFFF), Color(0xFF0000FF), Color(0xFFFF00FF), Color(0xFFFF0000)])),
                  child: Center(child: Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: selectedColor, border: Border.all(color: Colors.white, width: 2)))),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(height: 24, decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 8),
                Text('#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace')),
                const SizedBox(height: 6),
                Row(children: [_rgb('R', selectedColor.red), const SizedBox(width: 4), _rgb('G', selectedColor.green), const SizedBox(width: 4), _rgb('B', selectedColor.blue)]),
              ])),
            ]),
            const SizedBox(height: 12),
            _lbl('PRESETS'),
            Wrap(spacing: 8, runSpacing: 8, children: presets.map((c) {
              final sel = c.value == selectedColor.value;
              return GestureDetector(
                onTap: () { setState(() => selectedColor = c); _sendCommand(); },
                child: Container(width: 28, height: 28, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: sel ? Colors.white : Colors.transparent, width: 2))),
              );
            }).toList()),
            const SizedBox(height: 12),
            _sld('Brightness', brightness, (v) => setState(() => brightness = v)),
            const SizedBox(height: 6),
            _sld('Speed', speed, (v) => setState(() => speed = v)),
          ])),
          const SizedBox(height: 12),

          // Effects
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('EFFECTS · ${effects.length} total'),
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
                  onTap: () { setState(() { selectedEffect = i; if (d.isOn) d.sub = e['label'] as String; }); _sendCommand(); },
                  child: Container(
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF6C63FF).withOpacity(0.18) : const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: active ? const Color(0xFF6C63FF) : Colors.white10),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(e['icon'] as IconData, size: 18, color: active ? const Color(0xFFA78BFA) : Colors.white54),
                      const SizedBox(height: 3),
                      Text(e['label'] as String, style: TextStyle(fontSize: 9, color: active ? Colors.white70 : Colors.white38)),
                    ]),
                  ),
                );
              },
            ),
          ])),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _sendCommand,
          icon: const Icon(Icons.send_rounded),
          label: const Text('Send to LED'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _connected ? const Color(0xFF6C63FF) : const Color(0xFF2A2A40),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)), child: child);
  Widget _lbl(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)));
  Widget _rgb(String l, int v) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(6)), child: Column(children: [Text('$v', style: const TextStyle(color: Colors.white70, fontSize: 11)), Text(l, style: const TextStyle(color: Colors.white38, fontSize: 8))])));
  Widget _sld(String label, double value, ValueChanged<double> onChanged) => Row(children: [
    SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12))),
    Expanded(child: SliderTheme(data: SliderTheme.of(context).copyWith(activeTrackColor: const Color(0xFF6C63FF), thumbColor: const Color(0xFF6C63FF)), child: Slider(value: value, min: 0, max: 100, onChanged: onChanged))),
    SizedBox(width: 36, child: Text('${value.round()}%', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white60, fontSize: 12))),
  ]);

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E32),
        title: const Text('Pick colour', style: TextStyle(color: Colors.white, fontSize: 14)),
        content: SingleChildScrollView(child: ColorPicker(pickerColor: selectedColor, onColorChanged: (c) => setState(() => selectedColor = c), enableAlpha: false, portraitOnly: true)),
        actions: [TextButton(onPressed: () { Navigator.pop(context); _sendCommand(); }, child: const Text('Done'))],
      ),
    );
  }
}
