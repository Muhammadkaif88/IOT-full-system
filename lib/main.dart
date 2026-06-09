import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SmartNestApp());
}

class SmartNestApp extends StatelessWidget {
  const SmartNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFFA78BFA),
          surface: Color(0xFF1E1E32),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? const Color(0xFF1D9E75)
                : Colors.grey,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? const Color(0xFF1D9E75).withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F1A),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ─── SPLASH SCREEN ───────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'SmartNest',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Control your world',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── DASHBOARD SCREEN ────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  final List<Map<String, dynamic>> devices = [
    {
      'name': 'Living light',
      'icon': Icons.lightbulb_outline,
      'isOn': true,
      'sub': '80%',
      'color': Color(0xFF6C63FF),
    },
    {
      'name': 'Ceiling fan',
      'icon': Icons.air,
      'isOn': true,
      'sub': 'Speed 3',
      'color': Color(0xFF1D9E75),
    },
    {
      'name': 'Smart curtain',
      'icon': Icons.view_agenda_outlined,
      'isOn': true,
      'sub': 'Open',
      'color': Color(0xFF378ADD),
    },
    {
      'name': 'Bedroom light',
      'icon': Icons.lightbulb_outline,
      'isOn': false,
      'sub': 'Off',
      'color': Color(0xFFEF9F27),
    },
    {
      'name': 'LED Tube',
      'icon': Icons.light_mode_outlined,
      'isOn': true,
      'sub': 'Rainbow',
      'color': Color(0xFFA78BFA),
    },
    {
      'name': 'Water tank',
      'icon': Icons.water_drop_outlined,
      'isOn': true,
      'sub': '73%',
      'color': Color(0xFF378ADD),
    },
  ];

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
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 14),
              _buildStatusCard(),
              const SizedBox(height: 16),
              const Text(
                'Devices',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: devices.length,
                  itemBuilder: (_, i) => _buildDeviceCard(i),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Good morning,',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            Text(
              'My Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Spacer(),
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF6C63FF),
          child: const Text(
            'MK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final active = devices.where((d) => d['isOn'] == true).length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1D9E75),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$active devices active',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const Spacer(),
          const Text(
            'All connected ✓',
            style: TextStyle(color: Color(0xFF5DCAA5), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(int i) {
    final d = devices[i];
    final color = d['color'] as Color;
    return GestureDetector(
      onTap: () => setState(() => d['isOn'] = !d['isOn']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E32),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: d['isOn'] == true ? color.withOpacity(0.4) : Colors.white10,
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
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(d['icon'] as IconData, color: color, size: 20),
                ),
                const Spacer(),
                Switch(
                  value: d['isOn'] as bool,
                  onChanged: (v) => setState(() => d['isOn'] = v),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const Spacer(),
            Text(
              d['name'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              d['isOn'] == true ? d['sub'] as String : 'Off',
              style: TextStyle(
                color: d['isOn'] == true
                    ? const Color(0xFF5DCAA5)
                    : Colors.white30,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _navIndex,
      onTap: (i) => setState(() => _navIndex = i),
      backgroundColor: const Color(0xFF1A1A2E),
      selectedItemColor: const Color(0xFFA78BFA),
      unselectedItemColor: Colors.white30,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          label: 'Rooms',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bolt_outlined),
          label: 'Scenes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}
