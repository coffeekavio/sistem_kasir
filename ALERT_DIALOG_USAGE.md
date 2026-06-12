# Dokumentasi Alert Dialog Helper

Alert Dialog Helper adalah utility untuk menampilkan berbagai jenis dialog alert di seluruh aplikasi dengan konsistensi desain.

## Import

```dart
import 'package:kasir/core/components/alert_dialog.dart';
```

## Penggunaan

### 1. Alert Sukses

```dart
AlertDialogHelper.showSuccess(
  context: context,
  title: 'Berhasil!',
  desc: 'Data berhasil disimpan ke database.',
  onOkPress: () {
    // Aksi ketika tombol OK ditekan (opsional)
    Navigator.pop(context);
  },
);
```

### 2. Alert Error

```dart
AlertDialogHelper.showError(
  context: context,
  title: 'Terjadi Kesalahan',
  desc: 'Username atau password salah. Silakan coba lagi.',
  onOkPress: () {
    Navigator.pop(context);
  },
);
```

### 3. Alert Warning

```dart
AlertDialogHelper.showWarning(
  context: context,
  title: 'Perhatian',
  desc: 'Anda yakin ingin menghapus data ini?',
  onOkPress: () {
    Navigator.pop(context);
  },
);
```

### 4. Alert Info

```dart
AlertDialogHelper.showInfo(
  context: context,
  title: 'Informasi',
  desc: 'Promo spesial sedang berlangsung!',
  onOkPress: () {
    Navigator.pop(context);
  },
);
```

### 5. Alert Konfirmasi (Yes/No)

```dart
AlertDialogHelper.showConfirmation(
  context: context,
  title: 'Hapus Data?',
  desc: 'Apakah Anda yakin ingin menghapus data ini?',
  onYesPress: () {
    // Aksi jika Yes ditekan
    Navigator.pop(context);
  },
  onNoPress: () {
    // Aksi jika No ditekan (opsional)
    Navigator.pop(context);
  },
);
```

## Contoh Penggunaan di Login Screen

Sudah diimplementasikan di [login_screen.dart](d:\APL\kasir\lib\features\auth\login_screen.dart) dengan 3 skenario:

1. **Validasi Input Kosong**
   - Menampilkan error jika username/password kosong

2. **Koneksi API Gagal**
   - Menampilkan error khusus ketika ada masalah koneksi ke server
   - Pesan: "Tidak dapat terhubung ke server..."

3. **Username/Password Salah**
   - Menampilkan error ketika kredensial tidak sesuai
   - Pesan: "Username atau password salah..."

4. **Login Sukses**
   - Menampilkan success dialog sebelum navigasi ke menu

## Tips Penggunaan

- Gunakan `showSuccess()` untuk operasi yang berhasil (create, update, delete)
- Gunakan `showError()` untuk error/gagal operasi
- Gunakan `showWarning()` untuk peringatan atau konfirmasi berbahaya
- Gunakan `showInfo()` untuk informasi umum
- Gunakan `showConfirmation()` untuk meminta approval dari user
- `onOkPress` dan `onNoPress` adalah opsional - jika tidak diberikan, akan otomatis menutup dialog
- Selalu gunakan `if (mounted)` sebelum menampilkan dialog di dalam async function

## Parameter

Semua method menerima parameter:

- `context` (required): Build context dari widget
- `title` (required): Judul dialog
- `desc` (required): Deskripsi/pesan dialog
- `onOkPress` / `onYesPress` (optional): Callback ketika tombol OK/Yes ditekan
- `onNoPress` (optional): Callback ketika tombol No ditekan
