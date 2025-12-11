import 'package:uuid/uuid.dart';

class BudgetModel {
  final String id;
  final String nama;
  final String kategori;
  final double jumlahAnggaran;
  final DateTime tanggalMulai;
  final DateTime tanggalAkhir;
  double totalDipakai;
  final bool notif90Sent;
  final bool notif100Sent;
  final bool notifEndSent;

  BudgetModel({
    String? id,
    required this.nama,
    required this.kategori,
    required this.jumlahAnggaran,
    required this.tanggalMulai,
    required this.tanggalAkhir,
    this.totalDipakai = 0,
    this.notif90Sent = false,
    this.notif100Sent = false,
    this.notifEndSent = false,
  }) : id = id ?? const Uuid().v4();
}
