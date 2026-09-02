import 'package:flutter/material.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  final List<Map<String, String>> daily = const [
    {"day": "Today", "date": "Sep 01", "max": "33°C", "min": "26°C", "pop": "78%", "cond": "Thunderstorm Evening"},
    {"day": "Tomorrow", "date": "Sep 02", "max": "32°C", "min": "25°C", "pop": "65%", "cond": "Moderate Rain"},
    {"day": "Thursday", "date": "Sep 03", "max": "34°C", "min": "27°C", "pop": "30%", "cond": "Partly Sunny"},
    {"day": "Friday", "date": "Sep 04", "max": "35°C", "min": "28°C", "pop": "20%", "cond": "Hot & Humid"},
    {"day": "Saturday", "date": "Sep 05", "max": "31°C", "min": "26°C", "pop": "80%", "cond": "Heavy Monsoonal Rain"},
    {"day": "Sunday", "date": "Sep 06", "max": "30°C", "min": "25°C", "pop": "70%", "cond": "Scattered Showers"},
    {"day": "Monday", "date": "Sep 07", "max": "32°C", "min": "26°C", "pop": "40%", "cond": "Cloudy Breaks"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('7-Day High-Resolution Forecast')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: daily.length,
        itemBuilder: (context, index) {
          final item = daily[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['day']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(item['date']!, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${item['max']} / ${item['min']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF9933))),
                      Text('${item['cond']} • Rain ${item['pop']}', style: const TextStyle(fontSize: 12, color: Colors.blueAccent)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
