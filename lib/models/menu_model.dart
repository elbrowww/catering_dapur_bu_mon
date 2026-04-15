import 'package:intl/intl.dart';

class MenuModel {
  final int idMenu;
  final String nama;
  final String deskripsi;
  final double harga;
  final String foto;
  final String kategori;
  final int tersedia;

  MenuModel({
    required this.idMenu,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.foto,
    required this.kategori,
    required this.tersedia,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    // Safe price parsing (handle String, int, double, or null)
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
    );
  }

  String get formattedHarga {
    // Format harga ke Rupiah dengan NumberFormat
    final numberFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return numberFormat.format(harga);
  }
  
  bool get isTersedia => tersedia == 1;
}