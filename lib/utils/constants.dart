class ApiConfig {
  // Gunakan IP 10.0.2.2 jika kamu menggunakan Android Studio Emulator.
  // IP ini adalah jembatan khusus agar emulator bisa mengakses localhost laptopmu.
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Tips: Jika nanti kamu run Flutter di HP asli lewat kabel USB,
  // ganti IP di atas dengan IPv4 laptopmu (misal: 'http://192.168.1.5:8000/api')
}
