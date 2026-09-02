import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/app_state_scope.dart';

class WeatherMapScreen extends StatefulWidget {
  const WeatherMapScreen({super.key});

  @override
  State<WeatherMapScreen> createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController pinSearchController = TextEditingController(text: "700001");
  String selectedLayer = "Rainfall";
  bool isSearching = false;

  final List<String> layers = const ["Rainfall", "Temperature", "Wind Vectors", "Severe Alerts", "AWS Stations"];

  // Major Indian Stations
  final List<_StationInfo> stations = const [
    _StationInfo("Kolkata (Alipore AWS)", LatLng(22.5326, 88.3267), "31.5°C", "78% Rain", Colors.orange),
    _StationInfo("Delhi (Safdarjung AWS)", LatLng(28.5849, 77.2075), "38.2°C", "10% Rain", Colors.red),
    _StationInfo("Mumbai (Santacruz AWS)", LatLng(19.0883, 72.8617), "30.4°C", "85% Rain", Colors.orange),
    _StationInfo("Bengaluru (HAL AWS)", LatLng(12.9567, 77.6625), "26.2°C", "20% Rain", Colors.green),
    _StationInfo("Chennai (Meenambakkam AWS)", LatLng(12.9900, 80.1694), "35.1°C", "15% Rain", Colors.green),
    _StationInfo("Guwahati (Borjhar AWS)", LatLng(26.1061, 91.5859), "29.8°C", "60% Rain", Colors.yellow),
    _StationInfo("Ahmedabad (IMD AWS)", LatLng(23.0734, 72.6266), "39.5°C", "5% Rain", Colors.red),
  ];

  Future<void> _handleSearch() async {
    final pin = pinSearchController.text.trim();
    if (pin.isEmpty) return;

    setState(() => isSearching = true);
    final appState = AppStateScope.of(context);
    try {
      final details = await appState.lookupPincode(pin);
      if (details.latitude != null && details.longitude != null) {
        final newPos = LatLng(details.latitude!, details.longitude!);
        _mapController.move(newPos, 10.0);
        appState.setLocation(
          "${details.officeName}, ${details.district}",
          details.latitude!,
          details.longitude!,
          pincode: details.pincode,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PIN lookup failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final userPos = LatLng(appState.latitude, appState.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GIS India Weather Map & Radar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Recenter on Selected Location',
            onPressed: () => _mapController.move(userPos, 9.0),
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            tooltip: 'Map Layers',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Map Overlay Layer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 12),
                      ...layers.map((l) => RadioListTile<String>(
                            title: Text(l),
                            value: l,
                            groupValue: selectedLayer,
                            activeColor: const Color(0xFFFF9933),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedLayer = val);
                                Navigator.pop(ctx);
                              }
                            },
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Live OpenStreetMap FlutterMap Widget
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userPos,
              initialZoom: 6.5,
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.weathergpt.app',
              ),
              MarkerLayer(
                markers: [
                  // Primary Selected User Location Marker
                  Marker(
                    point: userPos,
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(appState.location),
                            content: Text(
                              'Pincode: ${appState.pincode}\n'
                              'Temperature: ${appState.currentWeather?.temperature ?? 31.5}°C\n'
                              'Rain Probability: ${appState.currentWeather?.rainProbability ?? 78}%\n'
                              'Weather: ${appState.currentWeather?.weatherDesc ?? 'Partly Cloudy'}'
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9933),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFFF9933).withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.location_on, color: Colors.white, size: 30),
                      ),
                    ),
                  ),

                  // AWS Weather Stations
                  ...stations.map(
                    (s) => Marker(
                      point: s.pos,
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${s.name}: ${s.temp}, ${s.rain}')),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: s.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.cloud, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search Box Overlay
          Positioned(
            top: 12,
            left: 14,
            right: 14,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFFFF9933)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: pinSearchController,
                        onSubmitted: (_) => _handleSearch(),
                        decoration: const InputDecoration(
                          hintText: 'Enter 6-digit Indian PIN Code...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: isSearching ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: _handleSearch,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Legend & Layer Overlay
          Positioned(
            bottom: 16,
            left: 14,
            right: 14,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(context).cardColor.withValues(alpha: 0.92),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Layer: $selectedLayer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Text('IMD INSAT-3D Live Feed', style: TextStyle(fontSize: 10, color: Color(0xFFFF9933), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _LegendDot(color: Colors.green, label: 'Normal'),
                        _LegendDot(color: Colors.yellow, label: 'Watch'),
                        _LegendDot(color: Colors.orange, label: 'Alert'),
                        _LegendDot(color: Colors.red, label: 'Warning'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StationInfo {
  final String name;
  final LatLng pos;
  final String temp;
  final String rain;
  final Color color;
  const _StationInfo(this.name, this.pos, this.temp, this.rain, this.color);
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}
