import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pengajuan_owner_model.dart';
import '../utils/constants.dart';
import 'dart:io';

class PengajuanOwnerService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Cek apakah ada pengajuan aktif
  Future<PengajuanOwnerModel?> cekStatus() async {
    String? token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/pengajuan-owner'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        return PengajuanOwnerModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengecek status pengajuan: $e');
    }
  }

  // Kirim pengajuan baru (DENGAN KTP DAN ALAMAT)
  Future<void> ajukan(
    String namaToko,
    String deskripsiToko,
    String alamat,
    File ktpImage,
  ) async {
    String? token = await _getToken();
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/pengajuan-owner'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Masukkan teks
      request.fields['nama_toko'] = namaToko;
      request.fields['deskripsi_toko'] = deskripsiToko;
      request.fields['alamat'] = alamat;

      // Masukkan gambar KTP
      request.files.add(
        await http.MultipartFile.fromPath('ktp_image', ktpImage.path),
      );

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        try {
          final data = json.decode(response.body);
          throw Exception(data['message'] ?? 'Gagal mengajukan kemitraan');
        } catch (e) {
          throw Exception(
            'Terjadi kesalahan di server (Error ${response.statusCode})',
          );
        }
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Batalkan pengajuan
  Future<void> batalkan() async {
    String? token = await _getToken();
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/pengajuan-owner'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal membatalkan pengajuan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
