import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/models/menu_model.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class DetailMenuPage extends StatefulWidget {
  final MenuModel menu;
  const DetailMenuPage({super.key, required this.menu});

  @override
  State<DetailMenuPage> createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  int _quantity = 1;
  bool _isLoading = false;

  Future<void> _addToCart() async {
    setState(() => _isLoading = true);
    
    try {
      await ApiService.tambahKeKeranjang(
        idMenu: widget.menu.idMenu,
        jumlah: _quantity,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil ditambahkan ke keranjang'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context); // Kembali ke menu
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menu.nama),
        backgroundColor: const Color(0xFFD05122),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: widget.menu.foto.isNotEmpty
                  ? Image.network(
                      widget.menu.foto,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.fastfood,
                        size: 80,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(Icons.fastfood, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Nama & Harga
            Text(
              widget.menu.nama,
              style: GoogleFonts.alexandria(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.menu.formattedHarga,
              style: GoogleFonts.alexandria(
                fontSize: 20,
                color: const Color(0xFFD05122),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Deskripsi
            Text(
              'Deskripsi',
              style: GoogleFonts.alexandria(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.menu.deskripsi.isEmpty ? 'Tidak ada deskripsi' : widget.menu.deskripsi,
              style: GoogleFonts.lora(fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            // Quantity selector
            Row(
              children: [
                Text(
                  'Jumlah:',
                  style: GoogleFonts.alexandria(fontSize: 16),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Tombol Tambah ke Keranjang
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD05122),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Tambah ke Keranjang',
                        style: GoogleFonts.alexandria(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}