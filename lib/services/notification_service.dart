import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../utils/constants.dart';

class NotificationService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<NotificationModel>> getNotifications() async {
    String? token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => NotificationModel.fromJson(item)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal memuat notifikasi: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    String? token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Gagal memperbarui status');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> markAllAsRead() async {
    String? token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Gagal memperbarui status');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
