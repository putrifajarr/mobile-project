import 'package:uuid/uuid.dart';

class BudgetModel {
  final String id;
  final String nama;
  final String kategori;
  final double jumlahAnggaran;
  final DateTime tanggalMulai;
  final DateTime tanggalAkhir;
  double totalDipakai;

  BudgetModel({
    String? id,
    required this.nama,
    required this.kategori,
    required this.jumlahAnggaran,
    required this.tanggalMulai,
    required this.tanggalAkhir,
    this.totalDipakai = 0,
  }) : id = id ?? const Uuid().v4();
}
