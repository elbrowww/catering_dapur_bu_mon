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
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
        gradient: LinearGradient(
          colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
          stops: [0.17, 0.47, 0.60],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItemOwner(
            imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F41c7cf60-ea32-4d94-bee6-64ca1ce79f76.png',
            iconWidth: 26,
            iconHeight: 29,
            label: 'Dashboard',
            isSelected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          _NavItemOwner(
            imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2Fdd675b4e-972d-4f12-9048-ab9f603cfdab.png',
            iconWidth: 28,
            iconHeight: 28,
            label: 'Pesanan',
            isSelected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          _NavItemOwner(
            imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F15a22875-ff29-4bf1-a688-0556d35ad4a3.png',
            iconWidth: 28,
            iconHeight: 28,
            label: 'Kelola Menu',
            isSelected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
          ),
          _NavItemOwner(
            imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2Fe8676855-e2a8-48ba-aa19-98addd6f04fd.png',
            iconWidth: 33,
            iconHeight: 27,
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
  final String imageUrl;
  final double iconWidth;
  final double iconHeight;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemOwner({
    required this.imageUrl,
    required this.iconWidth,
    required this.iconHeight,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.75,
              child: Image.network(
                imageUrl,
                width: iconWidth,
                height: iconHeight,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 4),
            Opacity(
              opacity: 0.8,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  color: const Color(0xFFFFF8EF),
                  fontSize: 7,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}