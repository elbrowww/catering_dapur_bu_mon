import 'package:intl/intl.dart';

class MenuModel {
  // 🔥 TAMBAHKAN INI - Base URL untuk gambar
  // Untuk emulator Android: gunakan 10.0.2.2
  // Untuk device fisik: ganti dengan IP komputer (contoh: 192.168.1.100)
  static const String baseImageUrl = 'http://192.168.1.11/dapur_bu_mon/assets/images/';
  
 // 🔥 TAMBAHKAN GETTER INI - URL lengkap gambar
  String get imageUrl => '$baseImageUrl$foto';

  final int idMenu;
  final String nama;
  final String deskripsi;
  final double harga;
  final String foto;
  final String kategori;
  final int tersedia;
  final int stok;
  final int minPreorderDays;
  final int allowPreorder;
  final String statusOrder;
  final bool isAvailableToday;
  final bool canPreorder;

  MenuModel({
    required this.idMenu,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.foto,
    required this.kategori,
    required this.tersedia,
    required this.stok,
    this.minPreorderDays = 1,
    this.allowPreorder = 1,
    this.statusOrder = 'tersedia',
    this.isAvailableToday = false,
    this.canPreorder = true,
  });

 
  
  // 🔥 Tambahan untuk debugging
  String get imageDebugInfo => 'Image: $foto → URL: $imageUrl';

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    // ... (kode fromJson Anda tetap sama)
    // Saya copy dari file Anda:
    double parseHarga(dynamic value) {
      if (value == null) return 0.0;
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return 0.0;
    }

    int parseStok(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int parseIntValue(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    bool parseBool(dynamic value, {bool defaultValue = false}) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        final lower = value.toLowerCase();
        return lower == '1' || lower == 'true';
      }
      return defaultValue;
    }

    final stokValue = parseStok(json['stok']);
    
    final minDays = parseIntValue(
      json['min_preorder_days'] ?? json['preorder_min_days'],
      defaultValue: stokValue > 0 ? 0 : 1,
    );
    
    final allowPreorderValue = parseBool(
      json['allow_preorder'],
      defaultValue: true,
    ) ? 1 : 0;
    
    final statusFromApi = json['status_order']?.toString() ?? (stokValue > 0 ? 'tersedia' : 'preorder');
    final isAvailableFromApi = parseBool(
      json['is_available_today'],
      defaultValue: stokValue > 0,
    );
    final canPreorderFromApi = parseBool(
      json['can_preorder'],
      defaultValue: allowPreorderValue == 1,
    );

    return MenuModel(
      idMenu: parseIntValue(json['id_menu']),
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: parseHarga(json['harga']),
      foto: json['foto'] ?? '',
      kategori: json['kategori']?.toString() ?? 'Lainnya',
      tersedia: parseIntValue(json['tersedia'], defaultValue: 1),
      stok: stokValue,
      minPreorderDays: minDays,
      allowPreorder: allowPreorderValue,
      statusOrder: statusFromApi,
      isAvailableToday: isAvailableFromApi,
      canPreorder: canPreorderFromApi,
    );
  }

  // ... (rest of your code - formattedHarga, isTersedia, isHabis, labelStok, dll tetap sama)
  String get formattedHarga {
    final numberFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return numberFormat.format(harga);
  }

  bool get isTersedia => tersedia == 1;
  bool get isHabis => stok == 0;
  
  String get labelStok {
    if (stok == 0) return 'Pre-order';
    if (stok <= 5) return 'Stok: $stok (Segera Habis)';
    return 'Stok: $stok';
  }
  
  bool get isAvailableForToday => stok > 0 && !isHabis && isAvailableToday;
  bool get canPreOrder => canPreorder && allowPreorder == 1;
  
  String get statusMessage {
    if (isAvailableForToday) {
      return '✅ Tersedia • Bisa pesan hari ini atau pre-order';
    } else if (canPreOrder) {
      if (minPreorderDays == 1) {
        return '⏰ Pre-order • Minimal H-1 (besok atau setelahnya)';
      } else {
        return '⏰ Pre-order • Minimal H-$minPreorderDays';
      }
    } else {
      return '❌ Tidak tersedia untuk sementara';
    }
  }
  
  int get statusColor {
    if (isAvailableForToday) return 0xFF4CAF50;
    if (canPreOrder) return 0xFFFFA726;
    return 0xFFE53935;
  }
  
  String get shortStatusLabel {
    if (isAvailableForToday) return 'Tersedia';
    if (canPreOrder) return 'Pre-order';
    return 'Habis';
  }
  
  bool canOrderOnDate(DateTime selectedDate) {
    final today = DateTime.now();
    final orderDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysDiff = orderDate.difference(todayDate).inDays;
    
    if (isAvailableForToday) {
      return daysDiff >= 0;
    } else if (canPreOrder) {
      return daysDiff >= minPreorderDays;
    }
    return false;
  }
  
  DateTime get minOrderDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (isAvailableForToday) return today;
    if (canPreOrder) return today.add(Duration(days: minPreorderDays));
    return today.add(const Duration(days: 365));
  }
  
  String getOrderErrorMessage(DateTime selectedDate) {
    final today = DateTime.now();
    final daysDiff = DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    
    if (isAvailableForToday) {
      if (daysDiff < 0) return 'Tidak bisa memesan untuk tanggal yang sudah lewat';
      return '';
    } else if (canPreOrder) {
      if (daysDiff < minPreorderDays) {
        if (minPreorderDays == 1) {
          return 'Menu ini hanya tersedia untuk pre-order minimal H-1 (besok atau setelahnya)';
        } else {
          return 'Menu ini hanya tersedia untuk pre-order minimal H-$minPreorderDays';
        }
      }
      return '';
    }
    return 'Menu tidak tersedia untuk dipesan';
  }
  
  int get warnaStok {
    if (stok == 0) return 0xFFE53935;
    if (stok <= 5) return 0xFFFFA726;
    return 0xFF4CAF50;
  }
  

  /// 🔥 Copy with method untuk update sebagian field
  MenuModel copyWith({
    int? idMenu,
    String? nama,
    String? deskripsi,
    double? harga,
    String? foto,
    String? kategori,
    int? tersedia,
    int? stok,
    int? minPreorderDays,
    int? allowPreorder,
    String? statusOrder,
    bool? isAvailableToday,
    bool? canPreorder,
  }) {
    return MenuModel(
      idMenu: idMenu ?? this.idMenu,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      harga: harga ?? this.harga,
      foto: foto ?? this.foto,
      kategori: kategori ?? this.kategori,
      tersedia: tersedia ?? this.tersedia,
      stok: stok ?? this.stok,
      minPreorderDays: minPreorderDays ?? this.minPreorderDays,
      allowPreorder: allowPreorder ?? this.allowPreorder,
      statusOrder: statusOrder ?? this.statusOrder,
      isAvailableToday: isAvailableToday ?? this.isAvailableToday,
      canPreorder: canPreorder ?? this.canPreorder,
    );
  }
}