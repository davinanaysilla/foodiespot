import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  // --- REGISTER ---
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        body: {'name': name, 'email': email, 'password': password},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['status'] == 'success') {
        String token = responseData['token'];
        Map<String, dynamic> userMap = responseData['data'];
        await _saveSession(token, userMap);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal mendaftar');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- FUNGSI LOGIN ---
  Future<void> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        body: {'email': email, 'password': password},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        String token = responseData['token'];
        Map<String, dynamic> userMap = responseData['data'];
        await _saveSession(token, userMap);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal login');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    debugPrint("DEBUG LOGOUT: Mencoba logout dengan token: $token");

    if (token != null && token.isNotEmpty) {
      try {
        final response = await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}/logout'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 5));

        debugPrint("DEBUG LOGOUT: Response Status: ${response.statusCode}");
      } catch (e) {
        debugPrint("DEBUG LOGOUT: Error jaringan saat kontak server: $e");
      }
    }

    await prefs.clear();
    debugPrint("DEBUG LOGOUT: Sesi lokal berhasil dibersihkan.");
  }

  // --- FUNGSI UPDATE PROFIL (mendukung upload foto) ---
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    File? photoFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/profile/update'),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      request.fields['name'] = name;
      request.fields['phone'] = phone;

      if (photoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photoFile.path),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        Map<String, dynamic> updatedUserMap = responseData['data'];
        await prefs.setString('user_data', json.encode(updatedUserMap));
        return UserModel.fromJson(updatedUserMap);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal memperbarui profil');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- FUNGSI HAPUS AKUN ---
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        await prefs.clear();
      } else {
        throw Exception(responseData['message'] ?? 'Gagal menghapus akun');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- HELPER: SIMPAN SESI KE HP ---
  Future<void> _saveSession(String token, Map<String, dynamic> userMap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_data', json.encode(userMap));
  }

  // --- HELPER: AMBIL DATA USER YANG SEDANG LOGIN ---
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      return UserModel.fromJson(json.decode(userDataString));
    }
    return null;
  }

  // --- AMBIL TOKEN ---
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- AMBIL PROFIL USER DARI SERVER ---
  Future<UserModel> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan, silakan login kembali.');
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        Map<String, dynamic> userMap = responseData['data'];
        await prefs.setString('user_data', json.encode(userMap));
        return UserModel.fromJson(userMap);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal mengambil data profil terbaru');
      }
    } catch (e) {
      throw Exception('Kesalahan memuat profil: $e');
    }
  }
}
