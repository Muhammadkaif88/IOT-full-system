import 'package:flutter/material.dart';
import '../models/device.dart';
import '../widgets/device_card.dart';
import 'led_control_screen.dart';
import 'device_detail_screen.dart';

class RoomDevicesScreen extends StatefulWidget {
  final String room;
  const RoomDevicesScreen({super.key, required this.room});

  @override
  State<RoomDevicesScreen> createState() => _RoomDevicesScreenState();
}

class _RoomDevicesScreenState extends State<RoomDevicesScreen> {
  final store = DeviceStore();

  void _restoreSub(d) {
    switch (d.type) {
      case 'light': d.sub = '${d.brightness ?? 80}%'; break;
      case 'fan': d.sub = 'Speed 3'; break;
      case 'curtain': d.sub = 'Open'; break;
      case 'led': d.sub = 'Rainbow'; break;
      case 'water': d.sub = '73%'; break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = store.devicesInRoom(widget.room);
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(title: Text(widget.room)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.15),
            itemCount: devices.length,
            itemBuilder: (_, i) {
              final d = devices[i];
              return DeviceCard(
                device: d,
                onToggle: () => setState(() {
                  d.isOn = !d.isOn;
                  if (!d.isOn) d.sub = d.type == 'curtain' ? 'Closed' : 'Off';
                  else _restoreSub(d);
                }),
                onTap: () {
                  if (d.type == 'led') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => LedControlScreen(device: d)));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceDetailScreen(device: d))).then((_) => setState((){}));
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
