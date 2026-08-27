import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'home_screen.dart';
import 'bags_screen.dart';
import 'scanner_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const Color _primaryIndigo = Color(0xFF6366F1);

  final List<Widget> _screens = [
    const HomeScreen(),
    const BagsScreen(),
    const ScannerScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF000000) : Colors.white,
          border: Border(
            top: BorderSide(
              color:
                  isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5E5),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Iconsax.home_2,
                  label: 'Accueil',
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Iconsax.box,
                  label: 'Mes Sacs',
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Iconsax.scan_barcode,
                  label: 'Scanner',
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Iconsax.user,
                  label: 'Profil',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isActive = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? _primaryIndigo
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? _primaryIndigo
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
