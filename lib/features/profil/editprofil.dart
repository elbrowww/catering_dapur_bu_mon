import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _namaController   = TextEditingController();
  final _noTelpController = TextEditingController();
  final _alamatController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving  = false;

  static const _gradientColors = [
    Color(0xFFD05122),
    Color(0xFFEE8B2E),
    Color(0xFFFBA839),
  ];
  static const _gradientStops = [0.17, 0.47, 0.60];

  @override
  void initState() {
    super.initState();
    _loadProfil();
    _namaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _loadProfil() async {
    try {
      final data = await ApiService.getProfil();
      setState(() {
        _namaController.text   = data['nama']    ?? '';
        _noTelpController.text = data['no_telp'] ?? '';
        _alamatController.text = data['alamat']  ?? '';
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

  Future<void> _simpanProfil() async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tidak boleh kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ApiService.editProfil(
        nama:   _namaController.text.trim(),
        noTelp: _noTelpController.text.trim(),
        alamat: _alamatController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 3,
          ),
        ],
      ),
      child: maxLines == 1
          ? SizedBox(
              height: 48,
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                readOnly: readOnly,
                style: GoogleFonts.alexandria(
                  color: readOnly ? Colors.black54 : Colors.black,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.alexandria(
                    color: Colors.black.withOpacity(0.3),
                    fontSize: 15,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  border: InputBorder.none,
                ),
              ),
            )
          : TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: readOnly,
              maxLines: maxLines,
              style: GoogleFonts.alexandria(
                color: readOnly ? Colors.black54 : Colors.black,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.alexandria(
                  color: Colors.black.withOpacity(0.3),
                  fontSize: 15,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                border: InputBorder.none,
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.alexandria(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: sw,
                height: sh,
                child: Container(
                  width: sw,
                  height: sh,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFAC3715),
                        Color(0xFFD05122),
                        Color(0xFFEE8B2E),
                      ],
                      stops: [0.21, 0.56, 0.83],
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [

                      // Panel putih bawah
                      Positioned(
                        left: 0,
                        top: sh * 0.372,
                        child: Container(
                          width: sw,
                          height: sh,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(46),
                          ),
                        ),
                      ),

                      // Foto profil
                      Positioned(
                        left: sw * 0.313,
                        top: sh * 0.080,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(75),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 10,
                                top: 10,
                                child: Image.network(
                                  'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F988b443c-cf48-42ae-9b9d-4ea1a53dfaa5.png',
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Ikon edit foto
                      Positioned(
                        left: sw * 0.572,
                        top: sh * 0.195,
                        child: Image.network(
                          'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2Fc6f7abf4-bbd0-4265-9843-7332090b758c.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        left: sw * 0.585,
                        top: sh * 0.202,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2Fdbc746d275f5080798ce1a4d831e54481b78d1c4Create%20profile%20-%20empty.png?alt=media&token=d572421f-71e8-4990-b603-9eb3f8d1352b',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Nama user (reaktif)
                      Positioned(
                        left: sw * 0.05,
                        right: sw * 0.05,
                        top: sh * 0.270,
                        child: Text(
                          _namaController.text.isEmpty
                              ? '-'
                              : _namaController.text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Form fields
                      Positioned(
                        left: sw * 0.087,
                        top: sh * 0.395,
                        right: sw * 0.087,
                        bottom: 16,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.055, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // No Telepon
                              _buildLabel('No Telepon'),
                              const SizedBox(height: 5),
                              _buildTextField(
                                controller: _noTelpController,
                                hint: '08123456789',
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 14),

                              // Nama
                              _buildLabel('Nama'),
                              const SizedBox(height: 5),
                              _buildTextField(
                                controller: _namaController,
                                hint: 'Nama lengkap',
                                keyboardType: TextInputType.name,
                              ),
                              const SizedBox(height: 14),

                              // Alamat
                              _buildLabel('Alamat'),
                              const SizedBox(height: 5),
                              _buildTextField(
                                controller: _alamatController,
                                hint: 'Jalan, Kelurahan, Kecamatan...',
                                maxLines: 3,
                              ),
                              const SizedBox(height: 24),

                              // Tombol Konfirmasi
                              GestureDetector(
                                onTap: _isSaving ? null : _simpanProfil,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: double.infinity,
                                  height: 48,
                                  decoration: ShapeDecoration(
                                    gradient: LinearGradient(
                                      colors: _isSaving
                                          ? [
                                              const Color(0xFFD05122)
                                                  .withOpacity(0.6),
                                              const Color(0xFFEE8B2E)
                                                  .withOpacity(0.6),
                                              const Color(0xFFFBA839)
                                                  .withOpacity(0.6),
                                            ]
                                          : const [
                                              Color(0xFFD05122),
                                              Color(0xFFEE8B2E),
                                              Color(0xFFFBA839),
                                            ],
                                      stops: _gradientStops,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x4FD05122),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isSaving
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            'Konfirmasi',
                                            style: GoogleFonts.alexandria(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Tombol Batal
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: double.infinity,
                                  height: 48,
                                  decoration: ShapeDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFAC3715),
                                        Color(0xFFD05122),
                                        Color(0xFFAC3715),
                                      ],
                                      stops: [0.17, 0.43, 0.61],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x4FAC3715),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Batal',
                                      style: GoogleFonts.alexandria(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}