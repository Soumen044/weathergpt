import 'package:flutter/material.dart';

class SavedLocationsScreen extends StatelessWidget {
  const SavedLocationsScreen({super.key});

  final List<Map<String, String>> places = const [
    {"type": "Home", "name": "Kolkata GPO (700001)", "temp": "31.5°C", "cond": "Rain Evening"},
    {"type": "College", "name": "Jadavpur (700032)", "temp": "31.2°C", "cond": "Thunderstorm"},
    {"type": "Farm", "name": "Burdwan (713101)", "temp": "33.0°C", "cond": "Light Rain"},
    {"type": "Office", "name": "Salt Lake Sector 5 (700091)", "temp": "32.0°C", "cond": "Overcast"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Favorite Locations')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final p = places[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFF9933).withValues(alpha: 0.2),
                child: Text(p['type']![0], style: const TextStyle(color: Color(0xFFFF9933), fontWeight: FontWeight.bold)),
              ),
              title: Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text('${p['type']} • ${p['cond']}', style: const TextStyle(color: Color(0xFF94A3B8))),
              trailing: Text(p['temp']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF9933))),
            ),
          );
        },
      ),
    );
  }
}
