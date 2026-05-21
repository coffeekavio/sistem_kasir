import 'package:flutter/material.dart';

// Data transaksi dummy
final List<Map<String, dynamic>> transaksiList = [
  {
    "id": "TRX001",
    "date": DateTime.now(),
    "time": "09:30",
    "items": "Espresso x2, Cappuccino x1",
    "total": 65000,
    "method": "Tunai",
    "status": "Selesai",
    "member": "Ahmad Budiman",
  },
  {
    "id": "TRX002",
    "date": DateTime.now(),
    "time": "10:15",
    "items": "Latte x3",
    "total": 72000,
    "method": "Kartu Kredit",
    "status": "Selesai",
    "member": "Siti Nurhaliza",
  },
  {
    "id": "TRX003",
    "date": DateTime.now(),
    "time": "11:45",
    "items": "Americano x1, Snack Pastry x2",
    "total": 48000,
    "method": "QRIS",
    "status": "Selesai",
    "member": "-",
  },
  {
    "id": "TRX004",
    "date": DateTime.now().subtract(Duration(days: 1)),
    "time": "14:20",
    "items": "Fresh Juice x2, Coffee x1",
    "total": 55000,
    "method": "Tunai",
    "status": "Selesai",
    "member": "Budi Santoso",
  },
  {
    "id": "TRX005",
    "date": DateTime.now().subtract(Duration(days: 1)),
    "time": "15:30",
    "items": "Mochaccino x2",
    "total": 54000,
    "method": "Kartu Debit",
    "status": "Selesai",
    "member": "-",
  },
  {
    "id": "TRX006",
    "date": DateTime.now().subtract(Duration(days: 2)),
    "time": "09:00",
    "items": "Espresso x1, Cappuccino x2",
    "total": 70000,
    "method": "QRIS",
    "status": "Selesai",
    "member": "Rini Wijaya",
  },
  {
    "id": "TRX007",
    "date": DateTime.now().subtract(Duration(days: 3)),
    "time": "16:45",
    "items": "Iced Tea x3, Dessert x2",
    "total": 85000,
    "method": "Tunai",
    "status": "Selesai",
    "member": "Hendra Kusuma",
  },
];

final List<String> paymentMethods = [
  "Tunai",
  "Kartu Kredit",
  "Kartu Debit",
  "QRIS",
  "E-Wallet",
];

// Helper untuk method icon
IconData getMethodIcon(String method) {
  switch (method) {
    case "Tunai":
      return Icons.attach_money;
    case "Kartu Kredit":
      return Icons.credit_card;
    case "Kartu Debit":
      return Icons.credit_card;
    case "QRIS":
      return Icons.qr_code_2;
    case "E-Wallet":
      return Icons.mobile_friendly;
    default:
      return Icons.payment;
  }
}

// Helper untuk method color
Color getMethodColor(String method) {
  switch (method) {
    case "Tunai":
      return Colors.green;
    case "Kartu Kredit":
      return Colors.blue;
    case "Kartu Debit":
      return Colors.indigo;
    case "QRIS":
      return Color(0xFFC67C4E);
    case "E-Wallet":
      return Colors.purple;
    default:
      return Colors.grey;
  }
}
