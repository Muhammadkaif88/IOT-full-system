import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WaterTankScreen extends StatefulWidget {
  const WaterTankScreen({super.key});
  @override
  State<WaterTankScreen> createState() => _WaterTankScreenState();
}

class _WaterTankScreenState extends State<WaterTankScreen> {
  String _ip = '192.168.1.100';
  bool _connected = false;
  bool _loading = true;

  int _level = 0;
  bool _pumpOn = false;
  bool _autoMode = true;
  bool _sensorOk = true;
  int _dataAge = 0;

  Timer? _pollTimer;
  final _ipCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIp();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadIp() async {
    final prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString('tank_ip') ?? '192.168.1.100';
    _ipCtrl.text = _ip;
    _startPolling();
  }

  Future<void> _saveIp(String ip) async {
    _ip = ip.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tank_ip', _ip);
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _fetchStatus();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchStatus());
  }

  Future<void> _fetchStatus() async {
    try {
      final res = await http.get(Uri.parse('http://$_ip/status')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) setState(() {
          _level    = data['level'] ?? 0;
          _pumpOn   = data['pumpOn'] ?? false;
          _autoMode = data['autoMode'] ?? true;
          _sensorOk = data['sensorOk'] ?? true;
          _dataAge  = data['dataAge'] ?? 0;
          _connected = true;
          _loading  = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _connected = false; _loading = false; });
    }
  }

  Future<void> _sendCommand(Map<String, dynamic> data) async {
    try {
      await http.post(
        Uri.parse('http://$_ip/control'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 3));
      await _fetchStatus();
    } catch (_) {}
  }

  void _showIpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E32),
        title: const Text('Controller IP', style: TextStyle(color: Colors.white, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF378ADD).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Text('OLED display il IP kaanikkum\n"IP: 192.168.x.x"', style: TextStyle(color: Color(0xFF378ADD), fontSize: 11)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ipCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: '192.168.1.100',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF16213E),
                prefixIcon: const Icon(Icons.router, color: Colors.white38, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF378ADD))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () async {
              await _saveIp(_ipCtrl.text);
              if (context.mounted) Navigator.pop(context);
              _startPolling();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF378ADD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Connect', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Water Tank'),
        actions: [
          IconButton(onPressed: _showIpDialog, icon: const Icon(Icons.router_outlined), tooltip: 'Set IP'),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _connected ? const Color(0xFF1D9E75) : const Color(0xFFE24B4A))),
              const SizedBox(width: 4),
              Text(_connected ? 'Live' : 'Offline', style: TextStyle(fontSize: 11, color: _connected ? const Color(0xFF5DCAA5) : const Color(0xFFE24B4A))),
            ])),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF378ADD)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!_connected) _offlineBanner(),
                _levelCard(),
                const SizedBox(height: 12),
                _pumpCard(),
                const SizedBox(height: 12),
                _statsCard(),
              ],
            ),
    );
  }

  Widget _offlineBanner() => GestureDetector(
    onTap: _showIpDialog,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFE24B4A).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE24B4A).withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.wifi_off, color: Color(0xFFE24B4A), size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text('Controller connect alla — IP: $_ip', style: const TextStyle(color: Color(0xFFE24B4A), fontSize: 12))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFE24B4A).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Text('Set IP', style: TextStyle(color: Color(0xFFE24B4A), fontSize: 11))),
      ]),
    ),
  );

  Widget _levelCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF378ADD).withOpacity(0.3))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('WATER LEVEL', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
          const Spacer(),
          if (_dataAge > 8) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFEF9F27).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text('Data $_dataAge s ago', style: const TextStyle(color: Color(0xFFEF9F27), fontSize: 10))),
        ]),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tank visual
            Container(
              width: 56, height: 90,
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFF378ADD), width: 2), borderRadius: BorderRadius.circular(10)),
              child: Stack(alignment: Alignment.bottomCenter, children: [
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 800),
                  heightFactor: _level / 100,
                  widthFactor: 1,
                  child: Container(decoration: BoxDecoration(
                    color: _level < 20 ? const Color(0xFFE24B4A).withOpacity(0.5) : const Color(0xFF378ADD).withOpacity(0.4),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  )),
                ),
              ]),
            ),
            const SizedBox(width: 18),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$_level%', style: TextStyle(color: _level < 20 ? const Color(0xFFE24B4A) : const Color(0xFF378ADD), fontSize: 36, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                _level < 20 ? '⚠ Low water!' : _level > 90 ? 'Tank full' : 'Level normal',
                style: TextStyle(color: _level < 20 ? const Color(0xFFE24B4A) : const Color(0xFF5DCAA5), fontSize: 13),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _level / 100,
                  backgroundColor: const Color(0xFF16213E),
                  valueColor: AlwaysStoppedAnimation(_level < 20 ? const Color(0xFFE24B4A) : const Color(0xFF378ADD)),
                  minHeight: 8,
                ),
              ),
            ])),
          ],
        ),
      ],
    ),
  );

  Widget _pumpCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('PUMP CONTROL', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      // Mode toggle
      Row(children: [
        const Icon(Icons.settings_suggest_outlined, color: Colors.white54, size: 18),
        const SizedBox(width: 8),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Auto mode', style: TextStyle(color: Colors.white, fontSize: 13)),
          Text('ON<20%  OFF>90%', style: TextStyle(color: Colors.white38, fontSize: 10)),
        ])),
        Switch(
          value: _autoMode,
          onChanged: (v) => _sendCommand({'autoMode': v}),
          activeColor: const Color(0xFF1D9E75),
        ),
      ]),
      const Divider(color: Colors.white10, height: 20),
      // Pump ON/OFF
      Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _autoMode ? null : () => _sendCommand({'pumpOn': true}),
            icon: const Icon(Icons.water_drop, size: 18),
            label: const Text('Pump ON'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _pumpOn ? const Color(0xFF378ADD) : const Color(0xFF1A2A3A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _autoMode ? null : () => _sendCommand({'pumpOn': false}),
            icon: const Icon(Icons.stop_circle_outlined, size: 18),
            label: const Text('Pump OFF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: !_pumpOn ? const Color(0xFFE24B4A).withOpacity(0.7) : const Color(0xFF2A1A1A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
      if (_autoMode)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Center(child: Text('Auto mode ON — manual control disabled', style: TextStyle(color: Colors.white38, fontSize: 10))),
        ),
      // Current pump status
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _pumpOn ? const Color(0xFF378ADD).withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _pumpOn ? const Color(0xFF378ADD) : Colors.white30)),
          const SizedBox(width: 8),
          Text('Pump is ${_pumpOn ? "running" : "stopped"}', style: TextStyle(color: _pumpOn ? const Color(0xFF378ADD) : Colors.white54, fontSize: 12)),
          const Spacer(),
          Text(_autoMode ? 'AUTO' : 'MANUAL', style: TextStyle(color: _autoMode ? const Color(0xFF5DCAA5) : const Color(0xFFEF9F27), fontSize: 10)),
        ]),
      ),
    ]),
  );

  Widget _statsCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('SYSTEM STATUS', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w500)),
      const SizedBox(height: 10),
      Row(children: [
        _statTile(_sensorOk ? 'OK' : 'ERROR', 'Sensor', _sensorOk ? const Color(0xFF5DCAA5) : const Color(0xFFE24B4A)),
        _statTile(_connected ? 'Online' : 'Offline', 'WiFi', _connected ? const Color(0xFF5DCAA5) : const Color(0xFFE24B4A)),
        _statTile('${_dataAge}s', 'Data age', _dataAge > 10 ? const Color(0xFFEF9F27) : const Color(0xFF5DCAA5)),
        _statTile(_autoMode ? 'Auto' : 'Manual', 'Mode', const Color(0xFFA78BFA)),
      ]),
    ]),
  );

  Widget _statTile(String value, String label, Color color) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF16213E), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ]),
    ),
  );
}
