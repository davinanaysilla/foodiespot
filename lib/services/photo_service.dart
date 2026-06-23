import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo_model.dart';
import '../utils/constants.dart';

class PhotoService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- AMBIL DAFTAR FOTO ---
  Future<List<PhotoModel>> getPhotos(int tempatMakanId) async {
    String? token = await _getToken();

    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/tempat-makan/$tempatMakanId/photos',
            ),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((item) => PhotoModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat galeri foto');
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  // --- UPLOAD FOTO BARU (MULTIPART REQUEST) ---
  Future<void> uploadPhoto(int tempatMakanId, File imageFile) async {
    String? token = await _getToken();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/tempat-makan/$tempatMakanId/photos'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal mengunggah foto');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- HAPUS FOTO ---
  Future<void> deletePhoto(int photoId) async {
    String? token = await _getToken();

    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/photos/$photoId'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal menghapus foto');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
