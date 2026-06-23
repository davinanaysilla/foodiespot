import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart' show PolylineLayer, Polyline;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../models/tempat_makan_model.dart';
import '../../utils/constants.dart';
import '../tempat_makan/detail_tempat_makan_page.dart';

class PetaPage extends StatefulWidget {
  final List<TempatMakanModel> tempatMakanList;
  const PetaPage({super.key, required this.tempatMakanList});

  @override
  State<PetaPage> createState() => _PetaPageState();
}

class _PetaPageState extends State<PetaPage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  LatLng? _userLocation;
  TempatMakanModel? _selectedPlace;
  bool _isLoadingLocation = false; // peta langsung tampil, GPS background
  bool _gpsActive = false; // true jika GPS berhasil
  int _selectedCardIndex = -1;
  StreamSubscription<Position>? _locationStream;

  // ── ROUTING STATE ────────────────────────────────────────────────────────
  List<LatLng> _routePoints = []; // koordinat jalur rute
  bool _isFetchingRoute = false; // loading rute
  TempatMakanModel? _routeDestination; // tujuan rute aktif saat ini

  // Chip filter
  final List<String> _chipFilters = [
    'Buka Sekarang',
    'Kopi & Roti',
    'Rating 4.5+',
    'Terdekat',
  ];
  final Set<String> _activeChips = {'Buka Sekarang'};

  // Default center Jakarta
  static const LatLng _defaultCenter = LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    // Langsung set ke Jakarta dulu, GPS dicari di background
    _userLocation = _defaultCenter;
    _initLocation();
  }

  @override
  void dispose() {
    _locationStream?.cancel();
    _mapController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── INISIALISASI LOKASI (NON-BLOCKING) ─────────────────────────────────
  Future<void> _initLocation() async {
    try {
      // 1. Cek service aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return; // peta tetap tampil di Jakarta

      // 2. Cek & minta permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      // 3. Coba posisi terakhir (INSTAN, tidak timeout)
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null && mounted) {
          final loc = LatLng(last.latitude, last.longitude);
          setState(() {
            _userLocation = loc;
            _gpsActive = true;
          });
          _mapController.move(loc, 15.0);
        }
      } catch (_) {}

      // 4. Mulai stream lokasi realtime (terus update)
      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // update tiap bergerak 10m
      );
      _locationStream = Geolocator.getPositionStream(locationSettings: settings)
          .listen((position) {
        if (!mounted) return;
        final loc = LatLng(position.latitude, position.longitude);
        setState(() {
          _userLocation = loc;
          _gpsActive = true;
        });
      }, onError: (_) {
        // Diam saja jika stream error, peta tetap tampil
      });
    } catch (_) {
      // Tidak tampilkan error — peta tetap tampil
    }
  }

  // ─── TOMBOL MY LOCATION (retry manual) ──────────────────────────────────
  Future<void> _goToMyLocation() async {
    if (_userLocation != null && _gpsActive) {
      _mapController.move(_userLocation!, 16.0);
      return;
    }
    // Coba ambil posisi sekali
    setState(() => _isLoadingLocation = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _userLocation = loc;
        _gpsActive = true;
        _isLoadingLocation = false;
      });
      _mapController.move(loc, 16.0);
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
      _showSnack(
          'GPS tidak tersedia. Aktifkan lokasi di pengaturan.', Colors.orange);
    }
  }

  // ─── HITUNG JARAK ANTARA DUA TITIK ──────────────────────────────────────
  String _formatDistance(TempatMakanModel item) {
    if (_userLocation == null ||
        item.latitude == null ||
        item.longitude == null) {
      return '';
    }

    final distanceInMeters = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      item.latitude!,
      item.longitude!,
    );

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  // ─── TAMPILKAN RUTE DI DALAM PETA (via OSRM, gratis & tanpa API key) ────
  Future<void> _openNavigation(TempatMakanModel item) async {
    if (item.latitude == null || item.longitude == null) {
      _showSnack('Koordinat restoran tidak tersedia', Colors.orange);
      return;
    }

    // Jika rute yang sama sudah ditampilkan, hapus (toggle off)
    if (_routeDestination?.id == item.id && _routePoints.isNotEmpty) {
      setState(() {
        _routePoints = [];
        _routeDestination = null;
      });
      return;
    }

    if (_userLocation == null || !_gpsActive) {
      _showSnack(
        'GPS belum aktif. Aktifkan lokasi untuk melihat rute.',
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isFetchingRoute = true;
      _routePoints = [];
      _routeDestination = item;
    });

    try {
      // OSRM public API — driving route
      final origin = '${_userLocation!.longitude},${_userLocation!.latitude}';
      final dest = '${item.longitude!},${item.latitude!}';
      final url =
          'https://router.project-osrm.org/route/v1/driving/$origin;$dest?overview=full&geometries=geojson';

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;

        final points = coords
            .map((c) =>
                LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
            .toList();

        if (!mounted) return;
        setState(() {
          _routePoints = points;
          _isFetchingRoute = false;
        });

        // Sesuaikan kamera agar rute terlihat seluruhnya
        if (points.length >= 2) {
          final lats = points.map((p) => p.latitude);
          final lngs = points.map((p) => p.longitude);
          final south = lats.reduce((a, b) => a < b ? a : b);
          final north = lats.reduce((a, b) => a > b ? a : b);
          final west = lngs.reduce((a, b) => a < b ? a : b);
          final east = lngs.reduce((a, b) => a > b ? a : b);
          final bounds = LatLngBounds(
            LatLng(south - 0.002, west - 0.002),
            LatLng(north + 0.002, east + 0.002),
          );
          _mapController.fitCamera(
            CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
          );
        }

        _showSnack('Rute ke ${item.name} ditampilkan di peta 🗺️',
            const Color(0xFF8B5E2A));
      } else {
        throw Exception('Gagal mengambil rute');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingRoute = false;
        _routeDestination = null;
      });
      _showSnack('Gagal memuat rute. Periksa koneksi internet.', Colors.red);
    }
  }

  // ─── HAPUS RUTE ───────────────────────────────────────────────────────────
  void _clearRoute() {
    setState(() {
      _routePoints = [];
      _routeDestination = null;
    });
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── RESOLVE IMAGE URL ───────────────────────────────────────────────────
  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$url';
  }

  // ─── FILTER RESTORAN YANG PUNYA KOORDINAT ────────────────────────────────
  List<TempatMakanModel> get _mappedPlaces => widget.tempatMakanList
      .where((p) => p.latitude != null && p.longitude != null)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── PETA FLUTTER MAP (OpenStreetMap) ──────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation ?? _defaultCenter,
              initialZoom: 14.0,
              minZoom: 5,
              maxZoom: 19,
              onTap: (_, __) {
                setState(() {
                  _selectedPlace = null;
                  _selectedCardIndex = -1;
                });
              },
            ),
            children: [
              // Tile Layer OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.foodiespot.app',
                maxZoom: 19,
              ),

              // ── RUTE POLYLINE ────────────────────────────────────────
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Shadow
                    Polyline(
                      points: _routePoints,
                      color: Colors.black.withValues(alpha: 0.15),
                      strokeWidth: 8.0,
                    ),
                    // Garis rute utama
                    Polyline(
                      points: _routePoints,
                      color: const Color(0xFF8B5E2A),
                      strokeWidth: 5.0,
                    ),
                    // Garis putih tipis di tengah
                    Polyline(
                      points: _routePoints,
                      color: Colors.white.withValues(alpha: 0.5),
                      strokeWidth: 2.0,
                    ),
                  ],
                ),

              // ── MARKER RESTORAN ──────────────────────────────────────
              MarkerLayer(
                markers: _mappedPlaces.asMap().entries.map((entry) {
                  final i = entry.key;
                  final place = entry.value;
                  final isSelected = _selectedPlace?.id == place.id;

                  return Marker(
                    point: LatLng(place.latitude!, place.longitude!),
                    width: isSelected ? 160 : 120,
                    height: isSelected ? 56 : 42,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlace = place;
                          _selectedCardIndex = i;
                        });
                        // Geser kamera ke marker
                        _mapController.move(
                          LatLng(place.latitude!, place.longitude!),
                          16.0,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 12 : 8,
                          vertical: isSelected ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF8B5E2A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF8B5E2A)
                                : const Color(0xFFE8D5A3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restaurant_rounded,
                              size: isSelected ? 16 : 14,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF8B5E2A),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                place.name.length > (isSelected ? 14 : 10)
                                    ? '${place.name.substring(0, isSelected ? 14 : 10)}…'
                                    : place.name,
                                style: TextStyle(
                                  fontSize: isSelected ? 12 : 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF2C1A0E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // ── MARKER LOKASI USER ───────────────────────────────────
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF8B5E2A)
                                  .withValues(alpha: 0.15),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF8B5E2A),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B5E2A)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              // OSM Attribution (wajib sesuai lisensi)
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // ── TOP OVERLAY: SEARCH + CHIPS ────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: Color(0xFFC49A5A), size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF2C1A0E)),
                            decoration: InputDecoration(
                              hintText: 'Cari restoran di peta...',
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onSubmitted: (query) {
                              final found = widget.tempatMakanList
                                  .where((p) =>
                                      p.name
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) &&
                                      p.latitude != null &&
                                      p.longitude != null)
                                  .toList();
                              if (found.isNotEmpty) {
                                final place = found.first;
                                setState(() {
                                  _selectedPlace = place;
                                  _selectedCardIndex =
                                      _mappedPlaces.indexOf(place);
                                });
                                _mapController.move(
                                  LatLng(place.latitude!, place.longitude!),
                                  16.0,
                                );
                              } else {
                                _showSnack('Restoran tidak ditemukan di peta',
                                    Colors.orange);
                              }
                            },
                          ),
                        ),
                        if (_searchCtrl.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() => _searchCtrl.clear());
                            },
                            child: Icon(Icons.close,
                                color: Colors.grey[400], size: 18),
                          ),
                      ],
                    ),
                  ),

                  // Chip Filters
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      itemCount: _chipFilters.length,
                      itemBuilder: (ctx, i) {
                        final chip = _chipFilters[i];
                        final active = _activeChips.contains(chip);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (active) {
                                _activeChips.remove(chip);
                              } else {
                                _activeChips.add(chip);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF8B5E2A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              chip,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? Colors.white
                                    : const Color(0xFF2C1A0E),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── GPS STATUS BADGE (kecil, tidak mengganggu) ─────────────────
          Positioned(
            top: 110,
            right: 16,
            child: AnimatedOpacity(
              opacity: _isLoadingLocation ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6)
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF8B5E2A))),
                    SizedBox(width: 6),
                    Text('GPS...',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8B5E2A),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),

          // ── PANEL DETAIL SELECTED PLACE ────────────────────────────────
          if (_selectedPlace != null)
            Positioned(
              bottom: 150,
              left: 16,
              right: 16,
              child: _buildDetailPanel(_selectedPlace!),
            ),

          // ── LOADING RUTE INDICATOR ────────────────────────────────────
          if (_isFetchingRoute)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF8B5E2A),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Menghitung rute...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C1A0E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── TOMBOL HAPUS RUTE (muncul jika ada rute aktif) ────────────
          if (_routePoints.isNotEmpty)
            Positioned(
              top: 120,
              left: 16,
              child: GestureDetector(
                onTap: _clearRoute,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Hapus Rute',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── BOTTOM: MY LOCATION + CARD SCROLL ────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Tombol My Location
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 12),
                  child: Column(
                    children: [
                      // Zoom In
                      _mapControlBtn(
                        Icons.add,
                        () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Zoom Out
                      _mapControlBtn(
                        Icons.remove,
                        () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // My Location
                      _mapControlBtn(
                        _gpsActive
                            ? Icons.my_location_rounded
                            : Icons.location_searching_rounded,
                        () => _goToMyLocation(),
                        color: _gpsActive
                            ? const Color(0xFF8B5E2A)
                            : Colors.grey[600]!,
                      ),
                    ],
                  ),
                ),

                // Info tempat jika ada yang punya koordinat = 0
                if (_mappedPlaces.isEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFF8B5E2A), size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Restoran belum memiliki koordinat lokasi.\nOwner perlu menambahkan koordinat di dashboard.',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF666666)),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Horizontal Scroll Cards restoran
                if (_mappedPlaces.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      itemCount: _mappedPlaces.length,
                      itemBuilder: (ctx, i) =>
                          _buildBottomCard(_mappedPlaces[i], i),
                    ),
                  ),

                // Jika semua data tidak ada koordinat, tampilkan semua di card
                if (_mappedPlaces.isEmpty && widget.tempatMakanList.isNotEmpty)
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      itemCount: widget.tempatMakanList.length,
                      itemBuilder: (ctx, i) =>
                          _buildBottomCard(widget.tempatMakanList[i], i),
                    ),
                  ),
              ],
            ),
          ),

          // GPS indicator sudah dipindahkan ke badge kecil di kanan atas
        ],
      ),
    );
  }

  // ─── PANEL DETAIL TEMPAT (muncul ketika marker dipilih) ──────────────────
  Widget _buildDetailPanel(TempatMakanModel place) {
    final imageUrl = _resolveImageUrl(place.imageUrl);
    final distance = _formatDistance(place);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Foto
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _thumbPlaceholder())
                : _thumbPlaceholder(),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1A0E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFF5A623), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      place.rating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1A0E)),
                    ),
                    if (distance.isNotEmpty) ...[
                      Text(' • ',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12)),
                      const Icon(Icons.directions_walk_rounded,
                          size: 13, color: Color(0xFF8B5E2A)),
                      const SizedBox(width: 2),
                      Text(distance,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  place.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Tombol aksi
          Column(
            children: [
              // Detail
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          DetailTempatMakanPage(tempatMakan: place)),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5ECD7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF8B5E2A), size: 20),
                ),
              ),
              const SizedBox(height: 6),
              // Navigasi — tampilkan rute di dalam peta
              GestureDetector(
                onTap: () => _openNavigation(place),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _routeDestination?.id == place.id &&
                            _routePoints.isNotEmpty
                        ? Colors.red.shade600
                        : const Color(0xFF8B5E2A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _routeDestination?.id == place.id && _routePoints.isNotEmpty
                        ? Icons.close_rounded
                        : Icons.directions_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM CARD RESTORAN (horizontal scroll) ─────────────────────────────
  Widget _buildBottomCard(TempatMakanModel item, int index) {
    final selected = _selectedCardIndex == index;
    final imageUrl = _resolveImageUrl(item.imageUrl);
    final distance = _formatDistance(item);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlace = item;
          _selectedCardIndex = index;
        });
        if (item.latitude != null && item.longitude != null) {
          _mapController.move(LatLng(item.latitude!, item.longitude!), 16.0);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 220,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF8B5E2A) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.12 : 0.07),
              blurRadius: selected ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _thumbSmall())
                  : _thumbSmall(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? const Color(0xFF8B5E2A)
                          : const Color(0xFF2C1A0E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFF5A623), size: 13),
                      const SizedBox(width: 3),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      if (distance.isNotEmpty)
                        Text(
                          ' • $distance',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Buka hingga 22:00',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TOMBOL KONTROL MAP (zoom/location) ──────────────────────────────────
  Widget _mapControlBtn(IconData icon, VoidCallback? onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color ?? const Color(0xFF2C1A0E), size: 20),
      ),
    );
  }

  Widget _thumbPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: const Color(0xFFE8D5A3),
      child: const Icon(Icons.restaurant_menu_rounded,
          color: Color(0xFF8B5E2A), size: 28),
    );
  }

  Widget _thumbSmall() {
    return Container(
      width: 60,
      height: 60,
      color: const Color(0xFFE8D5A3),
      child: const Icon(Icons.restaurant_menu_rounded,
          color: Color(0xFF8B5E2A), size: 24),
    );
  }
}
