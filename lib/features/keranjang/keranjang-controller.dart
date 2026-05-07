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

  List<Map<String, dynamic>> get items => _items;
  bool get isLoading => _isLoading;

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
    _notify();

    try {
      final response = await ApiService.getKeranjang();
      final rawItems = response['items'] as List<dynamic>? ?? [];

      _items = rawItems.map((item) => {
        'id_item':  item['id_item'],
        'id_menu':  item['id_menu'],
        'nama':     item['nama'] ?? '',
        'harga':    double.parse(item['harga_satuan'].toString()).toInt(),
        'jumlah':   item['jumlah'],
        'imageUrl': item['foto'] ?? '',
      }).toList().cast<Map<String, dynamic>>();

    } catch (e) {
      print('Error loading keranjang: $e');
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
    int? idMenu,
  }) async {
    // Tolak jika idMenu tidak valid — jangan pakai fallback lokal
    final int resolvedIdMenu = idMenu ?? 0;
    if (resolvedIdMenu <= 0) {
      print('Error: idMenu tidak valid ($resolvedIdMenu)');
      return false;
    }

    _isLoading = true;
    _notify();

    try {
      final response = await ApiService.tambahKeKeranjang(
        idMenu: resolvedIdMenu,
        jumlah: jumlah,
      );

      if (response['status'] == 'success' || response['message'] != null) {
        // Reload dari server agar id_item sinkron
        await loadKeranjang();
        return true;
      }
      return false;
    } catch (e) {
      // FIX: Hapus fallback lokal — error harus terlihat, bukan disembunyikan
      // Item lokal tanpa id_item menyebabkan checkout selalu "Keranjang kosong"
      print('Error adding to cart: $e');
      return false;
    } finally {
      _isLoading = false;
      _notify();
    }
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
        await ApiService.ubahJumlahItem(idItem: item['id_item'], jumlah: baru);
      }
      item['jumlah'] = baru;
    } catch (e) {
      print('Error updating quantity: $e');
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
          await ApiService.ubahJumlahItem(idItem: item['id_item'], jumlah: baru);
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
      await ApiService.hapusDariKeranjang(0); // DELETE tanpa id_item = clear all
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
    required String namaPembeli,
    required String alamat,
    required String metodeBayar,
    String catatan    = '',
    File?  buktiBayar,
  }) async {
    _isLoading = true;
    _notify();

    try {
      final response = await ApiService.checkout(
        namaPembeli: namaPembeli,
        alamat:      alamat,
        metodeBayar: metodeBayar,
        catatan:     catatan,
        buktiBayar:  buktiBayar,
      );

      if (response['status'] == 'success') {
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
    return _items.fold(
      0,
      (sum, e) => sum + (e['harga'] as int) * (e['jumlah'] as int),
    );
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