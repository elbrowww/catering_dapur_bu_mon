import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// CUSTOM NAVBAR — gradasi orange
// ============================================================
class CustomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // Warna gradasi orange
  static const Color _orangeStart = Color(0xFFE8520A);
  static const Color _orangeMid   = Color(0xFFF28C2E);
  static const Color _orangeEnd   = Color(0xFFF5A623);

  static const double _navbarHeight        = 64;
  static const double _floatingButtonSize  = 58;
  static const double _floatingOverflow    = 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _navbarHeight + _floatingOverflow,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ── Background navbar gradasi orange ───────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _navbarHeight,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [_orangeStart, _orangeMid, _orangeEnd],
                ),
              ),
            ),
          ),

          // ── Item-item navbar ────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: _navbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    label: 'Beranda',
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemTapped(0),
                  ),
                  _NavItem(
                    icon: Icons.menu,
                    label: 'Menu',
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemTapped(1),
                  ),
                  // Ruang kosong untuk tombol Keranjang
                  SizedBox(width: _floatingButtonSize),
                  _NavItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Aktivitas',
                    isSelected: selectedIndex == 3,
                    onTap: () => onItemTapped(3),
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    isSelected: selectedIndex == 4,
                    onTap: () => onItemTapped(4),
                  ),
                ],
              ),
            ),
          ),

          // ── Tombol Keranjang floating ───────────────────
          Positioned(
            bottom: _navbarHeight - _floatingButtonSize + _floatingOverflow,
            child: GestureDetector(
              onTap: () => onItemTapped(2),
              child: Container(
                width: _floatingButtonSize,
                height: _floatingButtonSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _orangeStart.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: _orangeStart,
                      size: 22,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Keranjang',
                      style: GoogleFonts.lora(
                        color: _orangeStart.withOpacity(0.75),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget item navbar ─────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
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
        width: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indikator aktif
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
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}