import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// CUSTOM NAVBAR — dipanggil hanya di MainScreen (main.dart)
// Ukuran lebih kecil, style tetap sama
// ============================================================
class CustomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Ukuran yang dikecilkan
    const double navbarHeight = 58;        // dari 74
    const double floatingButtonSize = 58;  // dari 74
    const double floatingButtonOverflow = 14; // dari 19

    return SizedBox(
      height: navbarHeight + floatingButtonOverflow,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ── Background navbar ───────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.network(
              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2F819d1fc8-515c-4122-ace5-c686e91e69f2.png',
              width: double.infinity,
              height: navbarHeight,
              fit: BoxFit.fill,
            ),
          ),

          // ── Item-item navbar ────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: navbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Beranda
                  _NavItem(
                    imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2F926b6b16-c814-48cf-83de-4f77d2b94e81.png',
                    label: 'Beranda',
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemTapped(0),
                  ),
                  // Menu
                  _NavItem(
                    imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2Fff4e5249-22f8-4055-9aff-c5a214832c31.png',
                    label: 'Menu',
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemTapped(1),
                  ),
                  // Ruang kosong untuk tombol Keranjang floating
                  const SizedBox(width: floatingButtonSize),
                  // Aktivitas
                  _NavItem(
                    imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2F50486553-c951-4d00-be98-8cc687c3d262.png',
                    label: 'Aktivitas',
                    isSelected: selectedIndex == 3,
                    onTap: () => onItemTapped(3),
                  ),
                  // Profil
                  _NavItem(
                    imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2F23a06cf1-12c9-4e4f-80dd-c7efe281e136.png',
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
            bottom: navbarHeight - floatingButtonSize + floatingButtonOverflow,
            child: GestureDetector(
              onTap: () => onItemTapped(2),
              child: SizedBox(
                width: floatingButtonSize,
                height: floatingButtonSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Lingkaran background
                    Image.network(
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2F15c28a9d-fde2-4190-b98b-2aa5967307a3.png',
                      width: floatingButtonSize,
                      height: floatingButtonSize,
                      fit: BoxFit.contain,
                    ),
                    // Ikon keranjang
                    Positioned(
                      top: 10, // dari 14
                      child: Image.network(
                        'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2Ffba6dd6d-919f-435f-9f11-bdf00eb3c959.png',
                        width: 28,  // dari 35
                        height: 27, // dari 34
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Label Keranjang
                    Positioned(
                      bottom: 8, // dari 12
                      child: Opacity(
                        opacity: 0.8,
                        child: Text(
                          'Keranjang',
                          style: GoogleFonts.lora(
                            color: const Color(0xFFFFF8EF),
                            fontSize: 8, // dari 10
                          ),
                        ),
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
  final String imageUrl;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.imageUrl,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52, // dari 64
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.75,
              child: Image.network(
                imageUrl,
                width: 24, // dari 30
                height: 24, // dari 30
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 3), // dari 4
            Opacity(
              opacity: 0.8,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  color: const Color(0xFFFFF8EF),
                  fontSize: 10, // dari 12
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}