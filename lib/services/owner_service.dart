import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class OwnerService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Ambil data dashboard owner dari backend.
  /// Return Map berisi summary, rating_distribution, review_terbaru, per_warung.
  Future<Map<String, dynamic>> getDashboard() async {
    final token = await _getToken();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/owner/dashboard'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body)['data'] as Map<String, dynamic>;
      }
      throw Exception('Gagal memuat data dashboard');
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }
}
