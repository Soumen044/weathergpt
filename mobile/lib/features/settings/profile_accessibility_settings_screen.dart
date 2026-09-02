import 'package:flutter/material.dart';
import '../../data/app_state_scope.dart';
import '../profile/personal_profile_screen.dart';

class ProfileAccessibilitySettingsScreen extends StatefulWidget {
  const ProfileAccessibilitySettingsScreen({super.key});

  @override
  State<ProfileAccessibilitySettingsScreen> createState() => _ProfileAccessibilitySettingsScreenState();
}

class _ProfileAccessibilitySettingsScreenState extends State<ProfileAccessibilitySettingsScreen> {
  bool readAloud = false;
  bool reducedMotion = false;
  String temperatureUnit = "Celsius (°C)";

  String _fontSizeLabel(double scale) {
    if (scale <= 0.9) return "Small";
    if (scale <= 1.0) return "Normal";
    if (scale <= 1.15) return "Large";
    return "Extra Large";
  }

  double _fontSizeValue(String label) {
    switch (label) {
      case "Small":
        return 0.9;
      case "Large":
        return 1.15;
      case "Extra Large":
        return 1.3;
      case "Normal":
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Accessibility Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Personal Profile Quick Card
          Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFFF9933))),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFF9933),
                radius: 24,
                child: Text('🇮🇳', style: TextStyle(fontSize: 20)),
              ),
              title: const Text('User Profile & Personalization', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(
                'Role: ${appState.occupation.toUpperCase()} • Location: ${appState.location}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              trailing: const Icon(Icons.edit, color: Color(0xFFFF9933)),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PersonalProfileScreen()));
              },
            ),
          ),
          const SizedBox(height: 20),

          const Text('ACCESSIBILITY & VISION CONTROLS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Read Aloud (Text-to-Speech)', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Automatically synthesize voice output for WeatherGPT advisories', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            value: readAloud,
            activeColor: const Color(0xFFFF9933),
            onChanged: (val) => setState(() => readAloud = val),
          ),
          SwitchListTile(
            title: const Text('High Contrast Theme Mode', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Maximum visual legibility with high contrast colors', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            value: appState.highContrast,
            activeColor: const Color(0xFFFF9933),
            onChanged: (val) => appState.setHighContrast(val),
          ),
          SwitchListTile(
            title: const Text('Reduced Motion & Animations', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Disable decorative transitions and subtle motion effects', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            value: reducedMotion,
            activeColor: const Color(0xFFFF9933),
            onChanged: (val) => setState(() => reducedMotion = val),
          ),
          ListTile(
            title: const Text('Text Size Scaling', style: TextStyle(color: Colors.white)),
            subtitle: Text(_fontSizeLabel(appState.textSizeScale), style: const TextStyle(color: Color(0xFFFF9933))),
            trailing: PopupMenuButton<String>(
              onSelected: (val) => appState.setTextSizeScale(_fontSizeValue(val)),
              itemBuilder: (context) => ["Small", "Normal", "Large", "Extra Large"].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
            ),
          ),
          const Divider(color: Colors.white24, height: 32),

          const Text('PREFERENCES & SYSTEM INTEGRATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Occupation Persona', style: TextStyle(color: Colors.white)),
            subtitle: Text(appState.occupation.toUpperCase(), style: const TextStyle(color: Color(0xFFFF9933))),
            trailing: PopupMenuButton<String>(
              onSelected: (val) => appState.setOccupation(val),
              itemBuilder: (context) => ["general", "farmer", "fisherman", "driver", "disaster_responder", "tourist"]
                  .map((o) => PopupMenuItem(value: o, child: Text(o.toUpperCase())))
                  .toList(),
            ),
          ),
          ListTile(
            title: const Text('Temperature Unit', style: TextStyle(color: Colors.white)),
            subtitle: Text(temperatureUnit, style: const TextStyle(color: Color(0xFFFF9933))),
            trailing: PopupMenuButton<String>(
              onSelected: (val) => setState(() => temperatureUnit = val),
              itemBuilder: (context) => ["Celsius (°C)", "Fahrenheit (°F)"].map((u) => PopupMenuItem(value: u, child: Text(u))).toList(),
            ),
          ),
          const ListTile(
            title: Text('Primary Meteorological Provider', style: TextStyle(color: Colors.white)),
            subtitle: Text('IMD Sync + Open-Meteo ECMWF IFS (0.1°)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ),
          const ListTile(
            title: Text('Multilingual Language Model', style: TextStyle(color: Colors.white)),
            subtitle: Text('BHASHINI Anuvaad 22 Official Indian Languages', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ),

          const Divider(color: Colors.white24, height: 32),

          const Text('PRIVACY & DATA TRANSPARENCY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Location Privacy: Coarse PIN-level localization only. Exact GPS coordinates are processed locally on device.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 6),
                Text('• Voice Input: Audio clips are processed temporarily for BHASHINI speech recognition and never stored.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 6),
                Text('• Data Transparency: Weather facts strictly match IMD & ECMWF synoptic observations. No fabricated metrics.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
