import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'kasir', 'supervisor', 'manager'
  final String? cafeId;
  final DateTime createdAt;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.cafeId,
    required this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'kasir',
      cafeId: json['cafe_id'],
      createdAt: DateTime.now(),
    );
  }
}

class AuthService {
  /// Login dengan Username dan Password (Mendukung Multi-Role & Multi-Tenant)
  static Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await Api.post('/api/auth/login-username', {
        'username': username,
        'password': password,
      });

      if (response['status'] != 'success' || response['user'] == null) {
        throw ApiException('Respons data dari server tidak valid.');
      }

      final user = response['user'];
      // Hanya izinkan role 'kasir' untuk aplikasi ini
      final allowedRoles = ['kasir'];

      if (!allowedRoles.contains(user['role'])) {
        throw ApiException('Role akun Anda tidak dikenali oleh sistem.');
      }

      // Simpan token JWT ke SharedPreferences
      if (response['token'] != null) {
        await Api.saveToken(response['token']);
      }

      // Simpan username untuk keperluan lain
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('user_role', user['role']);
      if (user['id'] != null) {
        await prefs.setString('user_id', user['id'].toString());
      }
      if (user['cafe_id'] != null) {
        await prefs.setString('cafe_id', user['cafe_id']);
      }

      return AuthUser.fromJson(user);
    } catch (e) {
      throw ApiException('Login gagal: $e');
    }
  }

  /// Logout - Membersihkan token dari sesi
  static Future<void> logout() async {
    try {
      await Api.clearToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      await prefs.remove('user_role');
      await prefs.remove('user_id');
      await prefs.remove('cafe_id');
    } catch (e) {
      throw ApiException('Logout gagal: $e');
    }
  }

  /// Mengambil token aktif
  static Future<String?> getToken() async {
    return await Api.getToken();
  }

  /// Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Ambil user info dari preferences
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<String?> getCafeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cafe_id');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}
