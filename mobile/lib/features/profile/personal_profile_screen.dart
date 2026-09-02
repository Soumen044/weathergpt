import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  final TextEditingController nameController = TextEditingController(text: "Rahul Sharma");
  String selectedOccupation = "Student";

  final List<String> occupations = [
    "Student",
    "Farmer",
    "Fisherman",
    "Driver",
    "Tourist",
    "Outdoor Worker",
    "Senior Citizen",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalize AI Advisory')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'WeatherGPT customizes weather decisions based on your daily occupation and travel patterns.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Your Name',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Occupation Profile',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: occupations.map((occ) {
                final isSel = occ == selectedOccupation;
                return ChoiceChip(
                  label: Text(occ),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) setState(() => selectedOccupation = occ);
                  },
                  selectedColor: const Color(0xFFFF9933),
                  backgroundColor: const Color(0xFF1E293B),
                  labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF94A3B8)),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Complete Setup & Launch WeatherGPT ➔', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
