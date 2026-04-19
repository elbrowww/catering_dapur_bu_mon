// ============================================================
// KERANJANG CONTROLLER — Singleton shared state with API
// Terintegrasi dengan database via ApiService
// ============================================================
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class KeranjangController {
  static final KeranjangController instance = KeranjangController._internal();
  KeranjangController._internal();

  List<Map<String, dynamic>> _items = [];
  final List<void Function()> _listeners = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get items => _items;
  bool get isLoading => _isLoading;

  void addListener(void Function() fn) => _listeners.add(fn);
  void removeListener(void Function() fn) => _listeners.remove(fn);
  void _notify() {
    for (final fn in _listeners) {
      fn();
    }
  }

  // ============================================================
  // LOAD KERANJANG DARI SERVER
  // ============================================================
  Future<void> loadKeranjang() async {
    _isLoading = true;
    _notify();
    
    try {
      final response = await ApiService.getKeranjang();
      
      if (response['status'] == 'success' && response['data'] != null) {
        _items.clear();
        
        for (var item in response['data']) {
          _items.add({
            'id_item': item['id_item'],
            'id_menu': item['id_menu'],
            'nama': item['nama_menu'] ?? item['nama'],
            'harga': (item['harga'] as num).toInt(),
            'jumlah': item['jumlah'],
            'imageUrl': item['foto'] ?? '',
          });
        }
      }
    } catch (e) {
      print('Error loading keranjang: $e');
      // Jika gagal load, tetap pakai data lokal
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ============================================================
  // TAMBAH ITEM KE KERANJANG (via API)
  // ============================================================
  Future<bool> tambah({
    required String nama,
    required int harga,
    required String imageUrl,
    required int jumlah,
    int? idMenu,  // ID menu dari database
  }) async {
    _isLoading = true;
    _notify();
    
    try {
      // Panggil API untuk tambah ke keranjang
      final response = await ApiService.tambahKeKeranjang(
        idMenu: idMenu ?? _getIdMenuFromNama(nama),
        jumlah: jumlah,
      );
      
      if (response['status'] == 'success') {
        // Update lokal state
        final idx = _items.indexWhere((e) => e['nama'] == nama);
        if (idx >= 0) {
          _items[idx]['jumlah'] += jumlah;
        } else {
          _items.add({
            'id_item': response['id_item'],
            'id_menu': idMenu,
            'nama': nama,
            'harga': harga,
            'jumlah': jumlah,
            'imageUrl': imageUrl,
          });
        }
        _notify();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding to cart: $e');
      // Fallback: tambah ke lokal dulu
      final idx = _items.indexWhere((e) => e['nama'] == nama);
      if (idx >= 0) {
        _items[idx]['jumlah'] += jumlah;
      } else {
        _items.add({
          'nama': nama,
          'harga': harga,
          'jumlah': jumlah,
          'imageUrl': imageUrl,
        });
      }
      _notify();
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // Helper: cari id_menu dari nama (fallback)
  int _getIdMenuFromNama(String nama) {
    // Ini hanya fallback, idealnya id_menu dikirim dari halaman menu
    final menuMap = {
      'Ayam Panggang': 1,
      'Ayam Lodho': 2,
      'Tumpeng': 3,
      'Paket Nasi Kotak': 4,
      'Putu Ayu': 5,
      'Klepon': 6,
      'Angsle': 7,
      'Ronde': 8,
      'Ongol-Ongol': 9,
    };
    return menuMap[nama] ?? 0;
  }

  // ============================================================
  // TAMBAH SATU (via API)
  // ============================================================
  Future<void> tambahSatu(int index) async {
    if (index >= _items.length) return;
    
    final item = _items[index];
    final int baru = (item['jumlah'] as int) + 1;
    
    _isLoading = true;
    _notify();
    
    try {
      if (item.containsKey('id_item')) {
        await ApiService.ubahJumlahItem(
          idItem: item['id_item'],
          jumlah: baru,
        );
      }
      
      item['jumlah'] = baru;
    } catch (e) {
      print('Error updating quantity: $e');
      // Tetap update lokal meskipun API error
      item['jumlah'] = baru;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ============================================================
  // KURANG SATU (via API)
  // ============================================================
  Future<void> kurangSatu(int index) async {
    if (index >= _items.length) return;
    
    final item = _items[index];
    final int sekarang = item['jumlah'] as int;
    
    if (sekarang > 1) {
      final int baru = sekarang - 1;
      
      _isLoading = true;
      _notify();
      
      try {
        if (item.containsKey('id_item')) {
          await ApiService.ubahJumlahItem(
            idItem: item['id_item'],
            jumlah: baru,
          );
        }
        item['jumlah'] = baru;
      } catch (e) {
        print('Error updating quantity: $e');
        item['jumlah'] = baru;
      } finally {
        _isLoading = false;
        _notify();
      }
    } else {
      // Hapus item
      await hapusItem(index);
    }
  }

  // ============================================================
  // HAPUS ITEM (via API)
  // ============================================================
  Future<void> hapusItem(int index) async {
    if (index >= _items.length) return;
    
    final item = _items[index];
    
    _isLoading = true;
    _notify();
    
    try {
      if (item.containsKey('id_item')) {
        await ApiService.hapusDariKeranjang(item['id_item']);
      }
      _items.removeAt(index);
    } catch (e) {
      print('Error removing item: $e');
      _items.removeAt(index);
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ============================================================
  // KOSONGKAN KERANJANG (via API)
  // ============================================================
  Future<void> kosongkan() async {
    _isLoading = true;
    _notify();
    
    try {
      // Hapus satu per satu (atau buat endpoint kosongkan semua)
      for (var item in _items) {
        if (item.containsKey('id_item')) {
          try {
            await ApiService.hapusDariKeranjang(item['id_item']);
          } catch (e) {
            print('Error deleting item: $e');
          }
        }
      }
      _items.clear();
    } catch (e) {
      print('Error clearing cart: $e');
      _items.clear();
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ============================================================
  // CHECKOUT (via API)
  // ============================================================
  Future<Map<String, dynamic>> checkout({
    required String metodeBayar,
    String catatan = '',
  }) async {
    _isLoading = true;
    _notify();
    
    try {
      final response = await ApiService.checkout(
        metodeBayar: metodeBayar,
        catatan: catatan,
      );
      
      if (response['status'] == 'success') {
        // Kosongkan keranjang setelah sukses checkout
        _items.clear();
      }
      
      return response;
    } catch (e) {
      print('Error checkout: $e');
      return {'status': 'error', 'message': e.toString()};
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ============================================================
  // GETTERS
  // ============================================================
  int get total {
    return _items.fold(0, (sum, e) => sum + (e['harga'] as int) * (e['jumlah'] as int));
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
}