import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tempat_makan_model.dart';
import '../utils/constants.dart';

class TempatMakanService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<TempatMakanModel>> getTempatMakan({String search = ''}) async {
    String? token = await _getToken();
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/tempat-makan?search=$search');

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((item) => TempatMakanModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat tempat makan');
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  Future<List<TempatMakanModel>> getMyTempatMakan() async {
    String? token = await _getToken();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/owner/tempat-makan'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((item) => TempatMakanModel.fromJson(item)).toList();
      }
      throw Exception('Gagal memuat daftar warung Anda');
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  // --- TAMBAH WARUNG (MULTIPART REQUEST) ---
  Future<void> addTempatMakan({
    required String name,
    required String address,
    required String description,
    File? imageFile,
  }) async {
    String? token = await _getToken();
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/tempat-makan'),
      );
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['name'] = name;
      request.fields['address'] = address;
      request.fields['description'] = description;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal menambahkan tempat makan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- EDIT WARUNG (MULTIPART REQUEST - METHOD SPOOFING) ---
  Future<void> editTempatMakan({
    required int id,
    required String name,
    required String address,
    required String description,
    File? imageFile,
  }) async {
    String? token = await _getToken();
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/tempat-makan/$id'),
      );
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['_method'] = 'PUT'; // Laravel method spoofing
      request.fields['name'] = name;
      request.fields['address'] = address;
      request.fields['description'] = description;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal memperbarui tempat makan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteTempatMakan(int id) async {
    String? token = await _getToken();
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/tempat-makan/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus tempat makan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
