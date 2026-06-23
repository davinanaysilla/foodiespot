import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_model.dart';
import '../utils/constants.dart';

class ReviewService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- AMBIL DAFTAR REVIEW ---
  Future<List<ReviewModel>> getReviews(int tempatMakanId) async {
    String? token = await _getToken();

    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/tempat-makan/$tempatMakanId/reviews',
            ),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((item) => ReviewModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat review');
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  // --- TAMBAH REVIEW BARU (BISA BAWA FOTO) ---
  Future<void> addReview(
    int tempatMakanId,
    int rating,
    String comment, {
    File? imageFile,
  }) async {
    String? token = await _getToken();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/tempat-makan/$tempatMakanId/reviews'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['rating'] = rating.toString();
      if (comment.isNotEmpty) request.fields['comment'] = comment;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal mengirim review');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- BALAS REVIEW (KHUSUS OWNER) ---
  Future<void> replyReview(int reviewId, String replyText) async {
    String? token = await _getToken();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/reviews/$reviewId/reply'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: {'reply': replyText},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal membalas ulasan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- UPDATE BALASAN REVIEW (KHUSUS OWNER) ---
  Future<void> updateReply(int reviewId, String replyText) async {
    String? token = await _getToken();
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/reviews/$reviewId/reply'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: {'reply': replyText},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal memperbarui balasan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- HAPUS BALASAN REVIEW (KHUSUS OWNER) ---
  Future<void> deleteReply(int reviewId) async {
    String? token = await _getToken();
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/reviews/$reviewId/reply'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal menghapus balasan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- HAPUS REVIEW ---
  Future<void> deleteReview(int reviewId) async {
    String? token = await _getToken();
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/reviews/$reviewId'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal menghapus ulasan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
