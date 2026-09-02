import 'package:flutter/material.dart';

class WeatherDetailsScreen extends StatelessWidget {
  const WeatherDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Atmospheric Telemetry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Meteorological Sensors — Kolkata GPO',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: const [
                _DetailTile(title: 'Atmospheric Pressure', value: '1008 hPa', sub: 'Stable Barometer'),
                _DetailTile(title: 'Visibility Distance', value: '8.0 km', sub: 'Hazy Horizon'),
                _DetailTile(title: 'Cloud Cover', value: '78%', sub: 'Nimbostratus Clouds'),
                _DetailTile(title: 'Dew Point', value: '25.4°C', sub: 'High Moisture'),
                _DetailTile(title: 'Sunrise Time', value: '05:22 AM', sub: 'Dawn IST'),
                _DetailTile(title: 'Sunset Time', value: '06:14 PM', sub: 'Dusk IST'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  const _DetailTile({required this.title, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Color(0xFFFF9933), fontSize: 18, fontWeight: FontWeight.bold)),
          Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
