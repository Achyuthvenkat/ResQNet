import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'broadcast_screen.dart';
import 'chats_screen.dart';
import 'status_screen.dart';
import '../theme.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapScreen(),
    const BroadcastScreen(),
    const ChatsScreen(),
    const StatusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.hub, color: AppTheme.primary),
            const SizedBox(width: 12),
            const Text(
              'MESH ACTIVE',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.primary,
                letterSpacing: -0.02,
              ),
            ),
          ],
        ),
        actions: [
          const Icon(Icons.bluetooth_connected, color: AppTheme.primary),
          const SizedBox(width: 24),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        color: AppTheme.background,
        padding: const EdgeInsets.only(bottom: 24, top: 8, left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.map, 'MAP'),
            _buildNavItem(1, Icons.sensors, 'BROADCAST'),
            _buildNavItem(2, Icons.forum, 'CHATS'),
            _buildNavItem(3, Icons.cell_tower, 'STATUS'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.background : AppTheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: isSelected ? AppTheme.background : AppTheme.surfaceContainerHighest,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
