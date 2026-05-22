import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavbarOwner extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const NavbarOwner({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // Warna sama persis dengan CustomNavbar customer
  static const Color _orangeStart = Color(0xFFE8520A);
  static const Color _orangeMid   = Color(0xFFF28C2E);
  static const Color _orangeEnd   = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_orangeStart, _orangeMid, _orangeEnd],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItemOwner(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isSelected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          _NavItemOwner(
            icon: Icons.receipt_long_outlined,
            label: 'Pesanan',
            isSelected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          _NavItemOwner(
            icon: Icons.restaurant_menu_outlined,
            label: 'Kelola Menu',
            isSelected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
          ),
          _NavItemOwner(
            icon: Icons.people_outline,
            label: 'Data Customer',
            isSelected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
          ),
        ],
      ),
    );
  }
}

class _NavItemOwner extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemOwner({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected
        ? Colors.white
        : Colors.white.withOpacity(0.45);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indikator aktif (garis putih di atas) — sama dengan navbar customer
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 20 : 0,
              height: 2,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                color: iconColor,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}