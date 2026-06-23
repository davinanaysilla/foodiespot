import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/tempat_makan_model.dart';
import '../../services/tempat_makan_service.dart';
import '../../utils/constants.dart';

class EditTempatMakanPage extends StatefulWidget {
  final TempatMakanModel tempatMakan;
  const EditTempatMakanPage({super.key, required this.tempatMakan});

  @override
  State<EditTempatMakanPage> createState() => _EditTempatMakanPageState();
}

class _EditTempatMakanPageState extends State<EditTempatMakanPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _descCtrl;
  File? _newSelectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.tempatMakan.name);
    _addressCtrl = TextEditingController(text: widget.tempatMakan.address);
    _descCtrl = TextEditingController(text: widget.tempatMakan.description);
  }

  String _resolveImageUrl(String url) {
    if (url.startsWith('http')) return url;
    String rootUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    return '$rootUrl/storage/$url';
  }

  void _simpanEdit() async {
    if (_nameCtrl.text.isEmpty ||
        _addressCtrl.text.isEmpty ||
        _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua kolom wajib diisi!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await TempatMakanService().editTempatMakan(
        id: widget.tempatMakan.id,
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageFile: _newSelectedImage,
      );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Informasi warung berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Informasi Warung"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Ubah Foto Sampul",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                );
                if (pickedFile != null) {
                  setState(() => _newSelectedImage = File(pickedFile.path));
                }
              },
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _newSelectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _newSelectedImage!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : (widget.tempatMakan.imageUrl != null &&
                            widget.tempatMakan.imageUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _resolveImageUrl(widget.tempatMakan.imageUrl!),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, _) => const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image,
                                      color: Colors.grey, size: 40),
                                  SizedBox(height: 8),
                                  Text("Gagal memuat gambar",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo,
                                  color: Colors.grey, size: 40),
                              SizedBox(height: 8),
                              Text(
                                "Klik untuk ganti gambar sampul",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Nama Warung / Resto",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Alamat Lengkap",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _simpanEdit,
                    child: const Text(
                      "Simpan Perubahan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
