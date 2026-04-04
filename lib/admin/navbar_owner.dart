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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
          stops: [0.17, 0.47, 0.60],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItemOwner(
            icon: Icons.home_rounded,
            label: 'Dashboard',
            isSelected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          _NavItemOwner(
            icon: Icons.bar_chart_rounded,
            label: 'Pesanan',
            isSelected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          _NavItemOwner(
            icon: Icons.restaurant_rounded,
            label: 'Kelola Menu',
            isSelected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
          ),
          _NavItemOwner(
            icon: Icons.group_rounded,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.lora(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 10,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}