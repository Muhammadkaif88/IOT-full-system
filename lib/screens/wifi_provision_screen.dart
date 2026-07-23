import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WifiProvisionScreen extends StatefulWidget {
  final String deviceName;
  final String apSsid; // ESP32 hotspot name
  const WifiProvisionScreen({super.key, required this.deviceName, required this.apSsid});
  @override
  State<WifiProvisionScreen> createState() => _WifiProvisionScreenState();
}

class _WifiProvisionScreenState extends State<WifiProvisionScreen> {
  final _ssidCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _passVisible = false;
  bool _sending = false;
  bool _done = false;
  String _status = '';
  int _step = 0; // 0=info, 1=credentials, 2=done

  Future<void> _sendCredentials() async {
    if (_ssidCtrl.text.trim().isEmpty) return;
    setState(() { _sending = true; _status = 'Sending to device...'; });
    try {
      // ESP32 AP mode IP is always 192.168.4.1
      final res = await http.post(
        Uri.parse('http://192.168.4.1/wifi-setup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ssid': _ssidCtrl.text.trim(), 'password': _passCtrl.text}),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        setState(() { _done = true; _step = 2; _status = 'Success! Device rebooting...'; });
      } else {
        setState(() { _status = 'Device error. Try again.'; });
      }
    } catch (e) {
      setState(() { _status = 'Cannot reach device.\nMake sure you are connected to\n"${widget.apSsid}" WiFi.'; });
    }
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(title: Text('Setup ${widget.deviceName}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _step == 0 ? _stepInfo() : _step == 1 ? _stepCredentials() : _stepDone(),
      ),
    );
  }

  Widget _stepInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1E1E32), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.wifi_tethering, color: Color(0xFF6C63FF), size: 36),
          const SizedBox(height: 12),
          Text('Setup ${widget.deviceName}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Follow these steps to connect your device to WiFi:', style: TextStyle(color: Colors.white54, fontSize: 13)),
        ]),
      ),
      const SizedBox(height: 20),
      _step_item('1', 'Device power on cheyyu', 'LED blink cheyyum — setup mode'),
      _step_item('2', 'Phone Settings → WiFi open cheyyu', 'Connect to "${widget.apSsid}"'),
      _step_item('3', 'App il back cheyyu', 'Next tap → WiFi credentials enter cheyyam'),
      const Spacer(),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => setState(() => _step = 1),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: const Text('Next — Enter WiFi details', style: TextStyle(color: Colors.white)),
        ),
      ),
    ],
  );

  Widget _step_item(String num, String title, String sub) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.2), shape: BoxShape.circle), child: Center(child: Text(num, style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 13, fontWeight: FontWeight.w600)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ])),
    ]),
  );

  Widget _stepCredentials() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF1D9E75).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1D9E75).withOpacity(0.3))),
        child: Row(children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF5DCAA5), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text('"${widget.apSsid}" il connect aayengilum?\nAyengil next cheyyu.', style: const TextStyle(color: Color(0xFF5DCAA5), fontSize: 12))),
        ]),
      ),
      const SizedBox(height: 20),
      const Text('Home WiFi Name', style: TextStyle(color: Colors.white60, fontSize: 12)),
      const SizedBox(height: 6),
      TextField(
        controller: _ssidCtrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Your WiFi name',
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: const Icon(Icons.wifi, color: Colors.white38),
          filled: true, fillColor: const Color(0xFF1E1E32),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6C63FF))),
        ),
      ),
      const SizedBox(height: 14),
      const Text('WiFi Password', style: TextStyle(color: Colors.white60, fontSize: 12)),
      const SizedBox(height: 6),
      TextField(
        controller: _passCtrl,
        obscureText: !_passVisible,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38),
          suffixIcon: IconButton(onPressed: () => setState(() => _passVisible = !_passVisible), icon: Icon(_passVisible ? Icons.visibility_off : Icons.visibility, color: Colors.white38)),
          filled: true, fillColor: const Color(0xFF1E1E32),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6C63FF))),
        ),
      ),
      if (_status.isNotEmpty) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFE24B4A).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(_status, style: const TextStyle(color: Color(0xFFE24B4A), fontSize: 12)),
        ),
      ],
      const Spacer(),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _sending ? null : _sendCredentials,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: _sending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Send to Device', style: TextStyle(color: Colors.white)),
        ),
      ),
    ],
  );

  Widget _stepDone() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: const Color(0xFF1D9E75).withOpacity(0.15), shape: BoxShape.circle),
        child: const Icon(Icons.check_circle, color: Color(0xFF1D9E75), size: 48),
      ),
      const SizedBox(height: 20),
      const Text('Device connected!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('${widget.deviceName} home WiFi il connect aakum.\nOLED il IP address kaanikkum.', style: const TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
      const SizedBox(height: 32),
      ElevatedButton(
        onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: const Text('Go to Dashboard', style: TextStyle(color: Colors.white)),
      ),
    ]),
  );
}
