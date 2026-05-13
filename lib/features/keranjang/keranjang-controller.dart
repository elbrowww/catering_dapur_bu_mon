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
// LOAD KERANJANG DARI SERVER (DIPERBAIKI - Tanpa animasi saat reload)
// ============================================================
Future<void> loadKeranjang({bool showLoading = true}) async {
  print('🔄 [Controller] Loading keranjang dari server... showLoading: $showLoading');
  
  // 🔥 Hanya tampilkan loading indicator jika showLoading = true
  if (showLoading) {
    _isLoading = true;
    _errorMessage = null;
    _notify();
  }

  try {
    final response = await ApiService.getKeranjang();
    
    print('📦 [Controller] Load keranjang response: $response');
    
    // Reset items sebelum diisi
    final List<Map<String, dynamic>> newItems = [];
    
    if (response is Map<String, dynamic>) {
      final rawItems = response['items'] as List<dynamic>? ?? [];
      print('📦 [Controller] Jumlah item dari server: ${rawItems.length}');
      
      for (var item in rawItems) {
        // Parse id_item - bisa int atau String
        final idItemRaw = item['id_item'];
        int idItem = 0;
        if (idItemRaw is int) {
          idItem = idItemRaw;
        } else if (idItemRaw is String) {
          idItem = int.tryParse(idItemRaw) ?? 0;
        }
        
        // Parse id_menu
        final idMenuRaw = item['id_menu'];
        int idMenu = 0;
        if (idMenuRaw is int) {
          idMenu = idMenuRaw;
        } else if (idMenuRaw is String) {
          idMenu = int.tryParse(idMenuRaw) ?? 0;
        }
        
        // Parse harga
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
        
        // Parse jumlah - bisa int atau String
        final jumlahRaw = item['jumlah'];
        int jumlah = 1;
        if (jumlahRaw is int) {
          jumlah = jumlahRaw;
        } else if (jumlahRaw is String) {
          jumlah = int.tryParse(jumlahRaw) ?? 1;
        }
        
        // Parse stok
        final stokRaw = item['stok'];
        int stok = 999;
        if (stokRaw is int) {
          stok = stokRaw;
        } else if (stokRaw is String) {
          stok = int.tryParse(stokRaw) ?? 999;
        }
        
        final parsedItem = {
          'id_item': idItem,
          'id_menu': idMenu,
          'nama': item['nama'] ?? item['nama_menu'] ?? 'Menu',
          'harga': rawHarga.toInt(),
          'jumlah': jumlah,
          'imageUrl': item['foto'] ?? item['imageUrl'] ?? '',
          'stok': stok,
        };
        
        newItems.add(parsedItem);
        print('✅ [Controller] Item ditambahkan: ${parsedItem['nama']}, id_item: $idItem, jumlah: $jumlah');
      }
    }
    
    _items = newItems;
    print('✅ [Controller] Keranjang loaded: ${_items.length} items');
    
  } catch (e) {
    print('❌ [Controller] Error loading keranjang: $e');
    if (showLoading) {
      _errorMessage = e.toString();
    }
    _items = [];
  } finally {
    if (showLoading) {
      _isLoading = false;
    }
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
  
  // Validasi jumlah minimal 1 (jangan sampai 0, karena akan dihapus)
  if (jumlahBaru <= 0) {
    return await hapusItem(index);
  }
  
  // Cek stok (jika ada info stok)
  final stok = item['stok'] as int? ?? 999;
  if (jumlahBaru > stok) {
    _errorMessage = 'Stok tidak mencukupi. Maksimal $stok item.';
    _notify();
    print('❌ Stok melebihi batas: $jumlahBaru > $stok');
    return false;
  }
  
  _isLoading = true;
  _notify();
  
  try {
    final idItem = item['id_item'] as int?;
    print('🔄 Updating item: idItem=$idItem, index=$index, jumlahBaru=$jumlahBaru');
    
    if (idItem != null && idItem != 0) {
      // Coba panggil API
      final result = await ApiService.ubahJumlahItem(
        idItem: idItem, 
        jumlah: jumlahBaru
      );
      print('✅ API update response: $result');
    } else {
      print('⚠️ idItem null atau 0, hanya update lokal');
    }
    
    // 🔥 UPDATE LOKAL (yang terpenting)
    _items[index]['jumlah'] = jumlahBaru;
    print('✅ Jumlah diperbarui menjadi: ${_items[index]['jumlah']}');
    _notify(); // 🔥 Pastikan UI refresh
    
    return true;
    
  } catch (e) {
    print('❌ Error updating quantity: $e');
    _errorMessage = e.toString();
    
    // 🔥 Tetap update lokal agar UI responsif
    _items[index]['jumlah'] = jumlahBaru;
    _notify();
    return false;
  } finally {
    _isLoading = false;
    _notify();
  }
}

// ============================================================
// KURANG SATU (DIPERBAIKI DENGAN DEBUG)
// ============================================================
Future<bool> kurangSatu(int index) async {
  print('🔽 kurangSatu dipanggil untuk index: $index');
  
  if (index >= _items.length) {
    print('❌ Index out of range: $index, items length: ${_items.length}');
    return false;
  }
  
  final item = _items[index];
  final int sekarang = item['jumlah'] as int;
  print('📊 Item: ${item['nama']}, jumlah sekarang: $sekarang');
  
  if (sekarang > 1) {
    final int baru = sekarang - 1;
    print('➕ Mengurangi dari $sekarang menjadi $baru');
    return await updateJumlah(index, baru);
  } else {
    print('🗑️ Jumlah = 1, akan menghapus item');
    return await hapusItem(index);
  }
}

// ============================================================
// TAMBAH SATU (DIPERBAIKI)
// ============================================================
Future<bool> tambahSatu(int index) async {
  print('🔼 tambahSatu dipanggil untuk index: $index');
  
  if (index >= _items.length) return false;
  
  final item = _items[index];
  final int sekarang = item['jumlah'] as int;
  final stok = item['stok'] as int? ?? 999;
  
  print('📊 Item: ${item['nama']}, jumlah: $sekarang, stok: $stok');
  
  if (sekarang >= stok) {
    print('❌ Stok habis!');
    _errorMessage = 'Stok hanya tersisa $stok item';
    _notify();
    return false;
  }
  
  final int baru = sekarang + 1;
  print('➕ Menambah dari $sekarang menjadi $baru');
  return await updateJumlah(index, baru);
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