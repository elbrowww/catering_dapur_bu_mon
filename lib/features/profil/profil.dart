import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/profil/editprofil.dart';
import 'package:catering_dapur_bu_mon/features/auth/login.dart';
import 'package:catering_dapur_bu_mon/features/profil/keamanan.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

const List<Map<String, String>> kDaftarAvatar = [
  {'file': 'tikus.png',   'label': 'Tikus'},
  {'file': 'kerbau.png',  'label': 'Kerbau'},
  {'file': 'macan.png',   'label': 'Macan'},
  {'file': 'kelinci.png', 'label': 'Kelinci'},
  {'file': 'naga.png',    'label': 'Naga'},
  {'file': 'ular.png',    'label': 'Ular'},
  {'file': 'kuda.png',    'label': 'Kuda'},
  {'file': 'kambing.png', 'label': 'Kambing'},
  {'file': 'monyet.png',  'label': 'Monyet'},
  {'file': 'ayam.png',    'label': 'Ayam'},
  {'file': 'anjing.png',  'label': 'Anjing'},
  {'file': 'babi.png',    'label': 'Babi'},
];

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _nama           = '';
  String _avatar         = 'tikus.png';
  bool   _isLoading      = true;
  bool   _isSavingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    try {
      final data = await ApiService.getProfil();
      setState(() {
        _nama      = data['nama']        ?? '';
        _avatar    = data['foto_profil'] ?? 'tikus.png';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil: $e')),
        );
      }
    }
  }

  void _showPilihAvatar() {
    String avatarSementara = _avatar;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih Avatar 🐾',
                style: GoogleFonts.alexandria(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1818),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap avatar yang ingin kamu gunakan',
                style: GoogleFonts.alexandria(
                    fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                itemCount: kDaftarAvatar.length,
                itemBuilder: (_, i) {
                  final namaFile   = kDaftarAvatar[i]['file']!;
                  final label      = kDaftarAvatar[i]['label']!;
                  final isSelected = avatarSementara == namaFile;

                  return GestureDetector(
                    onTap: () =>
                        setSheetState(() => avatarSementara = namaFile),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFFFFF0E8)
                                : Colors.grey[100],
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFD05122)
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFD05122)
                                          .withOpacity(0.30),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                'assets/avatars/$namaFile',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.pets,
                                  color: Color(0xFFD05122),
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          label,
                          style: GoogleFonts.alexandria(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFFD05122)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _isSavingAvatar
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        await _simpanAvatar(avatarSementara);
                      },
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD05122),
                        Color(0xFFEE8B2E),
                        Color(0xFFFBA839),
                      ],
                      stops: [0.17, 0.55, 0.85],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Gunakan Avatar Ini',
                      style: GoogleFonts.alexandria(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFD05122), width: 1.5),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'Batal',
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFFD05122),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _simpanAvatar(String namaAvatar) async {
    setState(() => _isSavingAvatar = true);
    try {
      await ApiService.updateAvatar(namaAvatar: namaAvatar);
      setState(() => _avatar = namaAvatar);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar berhasil dipakai ✅'),
            backgroundColor: const Color(0xFFD05122),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan avatar: $e')),
        );
      }
    } finally {
      setState(() => _isSavingAvatar = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFAC3715),
                      Color(0xFFD05122),
                      Color(0xFFEE8B2E),
                    ],
                    stops: [0.21, 0.56, 0.83],
                  ),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Yakin mau Logout?',
                style: GoogleFonts.alexandria(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1818),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kamu akan keluar dari akun ini.\nSampai jumpa lagi di Dapur Bu Mon! 👋',
                style: GoogleFonts.alexandria(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await ApiService.logout();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                      (route) => false,
                    );
                  }
                },
                child: Container(
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD05122),
                        Color(0xFFEE8B2E),
                        Color(0xFFFBA839),
                      ],
                      stops: [0.17, 0.55, 0.85],
                    ),
                  ),
                  child: Center(
                    child: Text('Ya, Logout',
                        style: GoogleFonts.alexandria(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFD05122), width: 1.5),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text('Batal',
                        style: GoogleFonts.alexandria(
                          color: const Color(0xFFD05122),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEE8B2E),
                  Color(0xFFD05122),
                  Color(0xFFAC3715),
                ],
                stops: [0.17, 0.44, 0.79],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Baris ikon + judul
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profil',
                            style: GoogleFonts.alexandria(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Kelola akun dan preferensimu',
                            style: GoogleFonts.alexandria(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Avatar
                GestureDetector(
                  onTap: _showPilihAvatar,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _isSavingAvatar
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFD05122),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    'assets/avatars/$_avatar',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.pets,
                                      size: 50,
                                      color: Color(0xFFD05122),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Badge edit
                      Positioned(
                        right: 2, bottom: 2,
                        child: Container(
                          width: 28, height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [
                              Color(0xFFD05122),
                              Color(0xFFFBA839),
                            ]),
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Nama
                _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _nama.isEmpty ? '-' : _nama,
                        style: GoogleFonts.alexandria(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Label Akun Saya ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Akun Saya',
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Card Edit Profil ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilPage()),
                );
                _loadProfil();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      spreadRadius: 2,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2F316b1609f20a8554436bf178b307cada634003f6user%201.png?alt=media&token=0dd54a77-ed31-408c-9241-66cd7452900f',
                          width: 38, height: 38,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Edit Profil',
                              style: GoogleFonts.alexandria(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 2),
                          Text('Ubah nama, alamat, dll',
                              style: GoogleFonts.alexandria(
                                  color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.black45, size: 22),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Card Keamanan ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KeamananPage()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      spreadRadius: 2,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2Fd9a301e2d64a9171618781d7bcf96f3b5983ca8fpadlock%201.png?alt=media&token=c787a911-aa18-4b7d-90ba-f77d1988788c',
                          width: 30, height: 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Keamanan & Password',
                              style: GoogleFonts.alexandria(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 2),
                          Text('Ubah password',
                              style: GoogleFonts.alexandria(
                                  color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.black45, size: 22),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Tombol Logout ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GestureDetector(
              onTap: _showLogoutDialog,
              child: Container(
                width: double.infinity,
                height: 47,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      spreadRadius: 3,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD05122),
                      Color(0xFFEE8B2E),
                      Color(0xFFFBA839),
                    ],
                    stops: [0.17, 0.47, 0.60],
                  ),
                ),
                child: Center(
                  child: Text(
                    'Logout',
                    style: GoogleFonts.alexandria(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}