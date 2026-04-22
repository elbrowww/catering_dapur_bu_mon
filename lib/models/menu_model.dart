import 'package:intl/intl.dart';

class MenuModel {
  final int idMenu;
  final String nama;
  final String deskripsi;
  final double harga;
  final String foto;
  final String kategori;
  final int tersedia;
  final int stok;

  MenuModel({
    required this.idMenu,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.foto,
    required this.kategori,
    required this.tersedia,
    required this.stok,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    double parseHarga(dynamic value) {
      if (value == null) return 0.0;
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return 0.0;
    }

    return MenuModel(
      idMenu: json['id_menu'] ?? 0,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: parseHarga(json['harga']),
      foto: json['foto'] ?? '',
      kategori: json['kategori'] ?? 'Lainnya',
      tersedia: json['tersedia'] ?? 1,
      stok: int.tryParse(json['stok'].toString()) ?? 0,
    );
  }

  String get formattedHarga {
    final numberFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return numberFormat.format(harga);
  }

  bool get isTersedia => tersedia == 1;

  /// Stok habis jika 0
  bool get isHabis => stok == 0;

  /// Label stok untuk ditampilkan
  String get labelStok {
    if (stok == 0) return 'Stok Habis';
    return 'Stok: $stok';
  }

  /// Warna badge stok
  /// Merah = habis, Orange = hampir habis (≤5), Hijau = aman
  int get warnaStok {
    if (stok == 0) return 0xFFE53935;
    if (stok <= 5) return 0xFFFFA726;
    return 0xFF4CAF50;
  }
}