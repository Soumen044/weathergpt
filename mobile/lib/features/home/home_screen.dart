import 'package:flutter/material.dart';
import '../../data/app_state_scope.dart';
import '../../data/api_client.dart';
import '../weather/weather_details_screen.dart';
import '../forecast/forecast_screen.dart';
import '../map/weather_map_screen.dart';
import '../alerts/alerts_screen.dart';
import '../chatbot/weather_gpt_chat_screen.dart';
import '../climate/climate_screen.dart';
import '../locations/saved_locations_screen.dart';
import '../settings/profile_accessibility_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeDashboardTab(),
    const WeatherMapScreen(),
    const AlertsScreen(),
    const WeatherGptChatScreen(),
    const ProfileAccessibilitySettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: const Color(0xFFFF9933),
        unselectedItemColor: const Color(0xFF64748B),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'WeatherGPT'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  void _showWhyBottomSheet(BuildContext context, WeatherSnapshot? weather) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '💡 EXPLAINABLE AI REASONING CORE',
                  style: TextStyle(color: Color(0xFFFF9933), fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 10),
            Text('• Data Source: ${weather?.source ?? "IMD + ECMWF IFS"}', style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 6),
            Text('• NWP Model: ${weather?.model ?? "ECMWF / GFS Hybrid"}', style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 6),
            Text('• Rain Probability: ${weather?.rainProbability.toStringAsFixed(0) ?? "78"}%', style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 6),
            Text('• Precipitation Amount: ${weather?.rain.toStringAsFixed(1) ?? "14.2"} mm', style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 6),
            Text('• Wind Speed: ${weather?.windSpeed.toStringAsFixed(1) ?? "18.5"} km/h', style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 6),
            Text('• Active Warnings: ${weather?.warnings.length ?? 0} IMD Alerts', style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              child: const Text('Close Explainability Panel'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPincodeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Search by PIN Code or City', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. 700001 or Mumbai',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF9933))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF9933), width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final query = controller.text.trim();
              if (query.isEmpty) return;
              Navigator.pop(ctx);
              final appState = AppStateScope.of(context);
              if (RegExp(r'^\d{6}$').hasMatch(query)) {
                try {
                  final details = await appState.lookupPincode(query);
                  appState.setLocation(
                    '${details.officeName}, ${details.district}',
                    details.latitude ?? 22.5726,
                    details.longitude ?? 88.3639,
                    pincode: details.pincode,
                  );
                } catch (e) {
                  appState.setLocation('$query, India', 22.5726, 88.3639, pincode: query);
                }
              } else {
                appState.setLocation('$query, India', 22.5726, 88.3639);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final weather = appState.currentWeather;
    final forecast = appState.forecast;
    final isLoading = appState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _showPincodeDialog(context),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFFFF9933), Color(0xFF138808)]),
                ),
                child: const Text('⚡', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.pincode.isNotEmpty ? '${appState.location} (${appState.pincode})' : appState.location,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tap to change location / PIN code',
                      style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              appState.isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
              color: appState.isDarkMode ? Colors.amber : const Color(0xFFFF9933),
            ),
            tooltip: 'Toggle Light/Dark Theme',
            onPressed: () => appState.toggleTheme(),
          ),
          IconButton(
            icon: Icon(
              appState.emergencyMode ? Icons.warning : Icons.warning_amber_outlined,
              color: appState.emergencyMode ? Colors.redAccent : Colors.orange,
            ),
            onPressed: () => appState.toggleEmergencyMode(),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedLocationsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClimateScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => appState.refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Weather Mode Banner if active
              if (appState.emergencyMode)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                  child: const Row(
                    children: [
                      Text('🚨', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('EMERGENCY WEATHER MODE ACTIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('RED ALERT: Severe Thunderstorm & Lightning Warning. Stay Indoors.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Active Warnings / Orange Alert Banner
              if (weather != null && weather.warnings.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF97316)),
                  ),
                  child: Row(
                    children: [
                      const Text('🚨', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IMD ${weather.warnings.first.level} ALERT',
                              style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            Text(
                              weather.warnings.first.headline,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              weather.warnings.first.description,
                              style: TextStyle(color: Colors.grey[300], fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF97316)),
                  ),
                  child: Row(
                    children: [
                      const Text('🚨', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('IMD ORANGE ALERT', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 11)),
                            const Text('Heavy Rain & Thunderstorm Expected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('Rain 15-25mm expected between 17:00–20:00 IST.', style: TextStyle(color: Colors.grey[300], fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Current Weather Hero Card
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WeatherDetailsScreen())),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLoading
                                    ? '--°C'
                                    : '${weather?.temperature.toStringAsFixed(1) ?? "31.5"}°C',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, height: 1),
                              ),
                              Text(
                                'Feels like ${weather?.feelsLike.toStringAsFixed(1) ?? "36.2"}°C',
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Text(
                              weather?.weatherDesc ?? 'Partly Cloudy\nRain Evening',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetric(Icons.water_drop, '${weather?.humidity.toInt() ?? 76}%', 'Humidity'),
                          _buildMetric(Icons.air, '${weather?.windSpeed.toStringAsFixed(1) ?? "18.5"} km/h', 'Wind'),
                          _buildMetric(Icons.umbrella, '${weather?.rainProbability.toInt() ?? 78}%', 'Rain Prob'),
                          _buildMetric(Icons.wb_sunny, weather?.uvIndex.toStringAsFixed(1) ?? "6.2", 'UV Index'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Explainability Action Bar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.info_outline, size: 16, color: Color(0xFFFF9933)),
                      label: const Text('Why this forecast? (Explainable AI)', style: TextStyle(color: Color(0xFFFF9933), fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF9933)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _showWhyBottomSheet(context, weather),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 24-Hour Forecast Timeline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('24-HOUR TIMELINE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF9933), letterSpacing: 1.1)),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForecastScreen())),
                    child: const Text('7-Day Forecast →', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 105,
                child: forecast == null || forecast.hourly.isEmpty
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 8,
                        itemBuilder: (ctx, idx) => Container(
                          width: 72,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${12 + idx}:00', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              const Text('🌧️', style: TextStyle(fontSize: 18)),
                              const SizedBox(height: 4),
                              Text('${30 - idx}°C', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: forecast.hourly.length,
                        itemBuilder: (ctx, idx) {
                          final h = forecast.hourly[idx];
                          return Container(
                            width: 72,
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: h.rainProbability > 50 ? Colors.blue.withValues(alpha: 0.5) : Colors.white10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(h.time.length > 5 ? h.time.substring(h.time.length - 5) : h.time, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(h.rainProbability > 50 ? '🌧️' : '⛅', style: const TextStyle(fontSize: 18)),
                                const SizedBox(height: 4),
                                Text('${h.temperature.toStringAsFixed(0)}°C', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 24),

              // Sector Intelligence (Persona/Occupation Cards)
              const Text('SECTOR INTELLIGENCE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF9933), letterSpacing: 1.1)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🌾', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Agromet Advisory for ${appState.occupation.toUpperCase()}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const Text('IMD-ICAR Joint Bulletin', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Postpone chemical spraying and fertilizer application due to expected evening thundershowers. Ensure field drainage channels in low-lying paddy plots are clear.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF38BDF8), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
      ],
    );
  }
}
