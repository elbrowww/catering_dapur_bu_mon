// ============================================================
// KERANJANG CONTROLLER — Singleton shared state
// Import file ini di detail_menu.dart dan keranjang.dart
// Taruh di: lib/page/keranjang_controller.dart
// ============================================================
class KeranjangController {
  static final KeranjangController instance = KeranjangController._internal();
  KeranjangController._internal();

  final List<Map<String, dynamic>> items = [];
  final List<void Function()> _listeners = [];

  void addListener(void Function() fn) => _listeners.add(fn);
  void removeListener(void Function() fn) => _listeners.remove(fn);
  void _notify() { for (final fn in _listeners) fn(); }

  // Tambah item — kalau sudah ada namanya, jumlah ditambah saja
  void tambah({
    required String nama,
    required int harga,
    required String imageUrl,
    required int jumlah,
  }) {
    final idx = items.indexWhere((e) => e['nama'] == nama);
    if (idx >= 0) {
      items[idx]['jumlah'] += jumlah;
    } else {
      items.add({'nama': nama, 'harga': harga, 'jumlah': jumlah, 'imageUrl': imageUrl});
    }
    _notify();
  }

  void tambahSatu(int i) { items[i]['jumlah']++; _notify(); }

  void kurangSatu(int i) {
    if (items[i]['jumlah'] > 1) { items[i]['jumlah']--; }
    else { items.removeAt(i); }
    _notify();
  }

  void kosongkan() { items.clear(); _notify(); }

  int get total =>
      items.fold(0, (sum, e) => sum + (e['harga'] as int) * (e['jumlah'] as int));

  String formatRupiah(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. ${buf.toString()}';
  }
}