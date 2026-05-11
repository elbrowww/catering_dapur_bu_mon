// ============================================================
// KERANJANG CONTROLLER — Singleton shared state with API
// ============================================================
import 'dart:io';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class KeranjangController {
  static final KeranjangController instance = KeranjangController._internal();
  KeranjangController._internal();

  List<Map<String, dynamic>> _items = [];
  final List<void Function()> _listeners = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void addListener(void Function() fn) => _listeners.add(fn);
  void removeListener(void Function() fn) => _listeners.remove(fn);
  void _notify() {
    for (final fn in _listeners) fn();
  }

  // ============================================================
  // LOAD KERANJANG DARI SERVER
  // ============================================================
  Future<void> loadKeranjang() async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      final response = await ApiService.getKeranjang();
      
      print('📦 Load keranjang response: $response');
      
      // 🔥 Response adalah Map dengan key 'items'
      if (response is Map<String, dynamic>) {
        final rawItems = response['items'] as List<dynamic>? ?? [];
        
        _items = rawItems.map((item) {
          // Parse harga dengan aman
          double rawHarga = 0;
          final hargaSatuan = item['harga_satuan'];
          if (hargaSatuan != null) {
            if (hargaSatuan is int) {
              rawHarga = hargaSatuan.toDouble();
            } else if (hargaSatuan is double) {
              rawHarga = hargaSatuan;
            } else if (hargaSatuan is String) {
              rawHarga = double.tryParse(hargaSatuan) ?? 0;
            } else if (hargaSatuan is num) {
              rawHarga = hargaSatuan.toDouble();
            }
          }
          
          return {
            'id_item': item['id_item'] ?? 0,
            'id_menu': item['id_menu'] ?? 0,
            'nama': item['nama'] ?? item['nama_menu'] ?? 'Menu',
            'harga': rawHarga.toInt(),
            'jumlah': item['jumlah'] is int 
                ? item['jumlah'] 
                : (int.tryParse(item['jumlah']?.toString() ?? '1') ?? 1),
            'imageUrl': item['foto'] ?? item['imageUrl'] ?? '',
            'stok': item['stok'] is int 
                ? item['stok'] 
                : (int.tryParse(item['stok']?.toString() ?? '999') ?? 999),
          };
        }).toList().cast<Map<String, dynamic>>();
      } else {
        _items = [];
      }

      print('✅ Keranjang loaded: ${_items.length} items');
      
    } catch (e) {
      print('❌ Error loading keranjang: $e');
      _errorMessage = e.toString();
      _items = [];
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ============================================================
  // TAMBAH ITEM KE KERANJANG (via API)
  // ============================================================
  Future<bool> tambah({
    required int idMenu,
    required String nama,
    required int harga,
    required String imageUrl,
    required int jumlah,
  }) async {
    // Validasi idMenu
    if (idMenu <= 0) {
      print('❌ Error: idMenu tidak valid ($idMenu)');
      _errorMessage = 'ID Menu tidak valid';
      _notify();
      return false;
    }

    // Cek apakah item sudah ada di keranjang
    final existingIndex = _items.indexWhere((item) => item['id_menu'] == idMenu);
    if (existingIndex != -1) {
      // Jika sudah ada, update jumlah
      final newJumlah = (_items[existingIndex]['jumlah'] as int) + jumlah;
      return await updateJumlah(existingIndex, newJumlah);
    }

    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      final response = await ApiService.tambahKeKeranjang(
        idMenu: idMenu,
        jumlah: jumlah,
      );

      print('📦 Add to cart response: $response');

      if (response['status'] == 'success') {
        // Reload dari server agar sinkron
        await loadKeranjang();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal menambahkan ke keranjang';
        return false;
      }
    } catch (e) {
      print('❌ Error adding to cart: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ============================================================
  // UPDATE JUMLAH ITEM
  // ============================================================
  Future<bool> updateJumlah(int index, int jumlahBaru) async {
    if (index >= _items.length) return false;
    
    final item = _items[index];
    if (jumlahBaru <= 0) {
      return await hapusItem(index);
    }
    
    // Cek stok (jika ada info stok)
    final stok = item['stok'] as int? ?? 999;
    if (jumlahBaru > stok) {
      _errorMessage = 'Stok tidak mencukupi. Maksimal $stok item.';
      _notify();
      return false;
    }
    
    _isLoading = true;
    _notify();
    
    try {
      final idItem = item['id_item'] as int?;
      if (idItem != null && idItem != 0) {
        await ApiService.ubahJumlahItem(
          idItem: idItem, 
          jumlah: jumlahBaru
        );
      }
      
      // Update lokal
      item['jumlah'] = jumlahBaru;
      _notify();
      return true;
      
    } catch (e) {
      print('❌ Error updating quantity: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ============================================================
  // TAMBAH SATU
  // ============================================================
  Future<bool> tambahSatu(int index) async {
    if (index >= _items.length) return false;
    final item = _items[index];
    final int baru = (item['jumlah'] as int) + 1;
    return await updateJumlah(index, baru);
  }

  // ============================================================
  // KURANG SATU
  // ============================================================
  Future<bool> kurangSatu(int index) async {
    if (index >= _items.length) return false;
    final item = _items[index];
    final int sekarang = item['jumlah'] as int;
    
    if (sekarang > 1) {
      final int baru = sekarang - 1;
      return await updateJumlah(index, baru);
    } else {
      return await hapusItem(index);
    }
  }

  // ============================================================
  // HAPUS ITEM
  // ============================================================
  Future<bool> hapusItem(int index) async {
    if (index >= _items.length) return false;
    
    final item = _items[index];
    _isLoading = true;
    _notify();
    
    try {
      final idItem = item['id_item'] as int?;
      if (idItem != null && idItem != 0) {
        await ApiService.hapusDariKeranjang(idItem);
      }
      _items.removeAt(index);
      _notify();
      return true;
      
    } catch (e) {
      print('❌ Error removing item: $e');
      _errorMessage = e.toString();
      // Hapus lokal meskipun API gagal (biar UI responsif)
      _items.removeAt(index);
      _notify();
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ============================================================
  // KOSONGKAN KERANJANG
  // ============================================================
  Future<bool> kosongkan() async {
    _isLoading = true;
    _notify();
    
    try {
      await ApiService.hapusDariKeranjang(0);
      _items.clear();
      _notify();
      return true;
      
    } catch (e) {
      print('❌ Error clearing cart: $e');
      _errorMessage = e.toString();
      _items.clear();
      _notify();
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ============================================================
  // CHECKOUT (dengan tanggal pengiriman)
  // ============================================================
  Future<Map<String, dynamic>> checkout({
    required String namaPembeli,
    required String alamat,
    required String metodeBayar,
    String catatan = '',
    DateTime? tanggalPengiriman,
    String? jamPengiriman,
    String tipePengiriman = 'ambil',
    File? buktiBayar,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      // Format tanggal ke YYYY-MM-DD
      String? tglAntar;
      if (tanggalPengiriman != null) {
        tglAntar = '${tanggalPengiriman.year}-${tanggalPengiriman.month.toString().padLeft(2, '0')}-${tanggalPengiriman.day.toString().padLeft(2, '0')}';
      }
      
      // Format jam (HH:MM:SS)
      String? jamAntar;
      if (jamPengiriman != null && jamPengiriman.isNotEmpty) {
        jamAntar = jamPengiriman;
      }
      
      final response = await ApiService.checkout(
        namaPembeli: namaPembeli,
        alamat: alamat,
        metodeBayar: metodeBayar,
        catatan: catatan,
        tglAntar: tglAntar,
        jamAntar: jamAntar,
        tipePengiriman: tipePengiriman,
        buktiBayar: buktiBayar,
      );

      print('📦 Checkout response: $response');

      if (response['status'] == 'success') {
        _items.clear();
        _notify();
      }

      return response;
      
    } catch (e) {
      print('❌ Error checkout: $e');
      return {
        'status': 'error', 
        'message': e.toString(),
        'success': false,
      };
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ============================================================
  // GETTERS
  // ============================================================
  int get total {
    return _items.fold(
      0,
      (sum, e) => sum + (e['harga'] as int) * (e['jumlah'] as int),
    );
  }

  int get totalItem {
    return _items.fold(0, (sum, e) => sum + (e['jumlah'] as int));
  }

  String formatRupiah(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. $buf';
  }

  void clearError() {
    _errorMessage = null;
    _notify();
  }
}