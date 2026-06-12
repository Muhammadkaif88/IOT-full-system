import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final d = device;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E32),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: d.isOn ? d.color.withOpacity(0.35) : Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: d.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(d.icon, color: d.color, size: 20),
                ),
                const Spacer(),
                Switch(
                  value: d.isOn,
                  onChanged: (_) => onToggle(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const Spacer(),
            Text(d.name,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(
              d.isOn ? d.sub : 'Off',
              style: TextStyle(
                  color: d.isOn ? const Color(0xFF5DCAA5) : Colors.white30,
                  fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
