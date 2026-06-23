import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pengajuan_owner_model.dart';
import '../utils/constants.dart';

class AdminService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // =====================================================
  // PENGAJUAN OWNER
  // =====================================================

  Future<List<PengajuanOwnerModel>> getPendingPengajuan() async {
    final token = await _getToken();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/admin/pengajuan'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((item) => PengajuanOwnerModel.fromJson(item)).toList();
      }
      throw Exception('Gagal memuat daftar pengajuan');
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan atau server: $e');
    }
  }

  Future<void> approvePengajuan(int id) async {
    final token = await _getToken();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/admin/pengajuan/$id/approve'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal menyetujui pengajuan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> rejectPengajuan(int id) async {
    final token = await _getToken();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/admin/pengajuan/$id/reject'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal menolak pengajuan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> hapusPengajuan(int id) async {
    final token = await _getToken();
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/admin/pengajuan/$id'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal menghapus pengajuan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =====================================================
  // DASHBOARD SISTEM
  // =====================================================

  Future<Map<String, dynamic>> getDashboard() async {
    final token = await _getToken();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/admin/dashboard'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body)['data'] as Map<String, dynamic>;
      }
      throw Exception('Gagal memuat dashboard');
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  // =====================================================
  // MANAJEMEN USER
  // =====================================================

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final token = await _getToken();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/admin/users'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Gagal memuat daftar user');
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    final token = await _getToken();
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/admin/users/$id'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal menghapus user');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =====================================================
  // MODERASI REVIEW
  // =====================================================

  Future<List<Map<String, dynamic>>> getAllReviews() async {
    final token = await _getToken();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/admin/reviews'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final data = body['data']['data'] as List? ?? body['data'] as List? ?? [];
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Gagal memuat review');
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  Future<void> deleteReview(int id) async {
    final token = await _getToken();
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/admin/reviews/$id'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal menghapus review');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =====================================================
  // MODERASI FOTO
  // =====================================================

  Future<List<Map<String, dynamic>>> getAllPhotos() async {
    final token = await _getToken();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/admin/photos'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final data = body['data']['data'] as List? ?? body['data'] as List? ?? [];
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Gagal memuat foto');
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  Future<void> deletePhoto(int id) async {
    final token = await _getToken();
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/admin/photos/$id'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal menghapus foto');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =====================================================
  // MANAJEMEN RESTORAN (untuk tab Restoran)
  // =====================================================
  Future<List<Map<String, dynamic>>> getAllRestaurants() async {
    final token = await _getToken();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/tempat-makan'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final data = body['data'] as List? ?? [];
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Gagal memuat data restoran');
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  Future<void> deleteRestaurant(int id) async {
    final token = await _getToken();
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/tempat-makan/$id'),
            headers: _headers(token!),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal menghapus restoran');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
