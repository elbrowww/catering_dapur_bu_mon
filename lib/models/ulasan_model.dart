class UlasanModel {
  final int idUlasan;
  final int idPesanan;
  final String namaCustomer;
  final int rating;
  final String komentar;
  final String tanggal;

  const UlasanModel({
    required this.idUlasan,
    required this.idPesanan,
    required this.namaCustomer,
    required this.rating,
    required this.komentar,
    required this.tanggal,
  });

  factory UlasanModel.fromJson(Map<String, dynamic> json) {
    return UlasanModel(
      idUlasan:     json['id_ulasan'] is int
                      ? json['id_ulasan']
                      : int.tryParse(json['id_ulasan'].toString()) ?? 0,
      idPesanan:    json['id_pesanan'] is int
                      ? json['id_pesanan']
                      : int.tryParse(json['id_pesanan'].toString()) ?? 0,
      namaCustomer: json['nama_customer'] ?? '',
      rating:       json['rating'] is int
                      ? json['rating']
                      : int.tryParse(json['rating'].toString()) ?? 0,
      komentar:     json['komentar'] ?? '',
      tanggal:      json['tanggal'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_ulasan':     idUlasan,
        'id_pesanan':    idPesanan,
        'nama_customer': namaCustomer,
        'rating':        rating,
        'komentar':      komentar,
        'tanggal':       tanggal,
      };
}