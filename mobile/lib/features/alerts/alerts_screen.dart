import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String selectedFilter = "All";
  int selectedCategoryIndex = 0;

  final List<String> categories = const ["Nearby (Kolkata)", "National", "Saved Places"];

  final List<Map<String, String>> alerts = const [
    {
      "level": "RED",
      "district": "Mumbai & Palghar",
      "state": "Maharashtra",
      "title": "Heavy Monsoonal Downpour & Surge",
      "time": "Valid till 23:59 IST",
      "action": "Avoid coastal low-lying roads. Stay indoors. Follow local municipal updates.",
      "source": "IMD Regional Meteorological Centre, Mumbai",
    },
    {
      "level": "ORANGE",
      "district": "Kolkata & Howrah",
      "state": "West Bengal",
      "title": "Severe Thunderstorm & Lightning Warning",
      "time": "Valid till 20:00 IST",
      "action": "Carry rain gear. Avoid standing near high structures, trees or power cables.",
      "source": "IMD Alipore Meteorological Office, Kolkata",
    },
    {
      "level": "ORANGE",
      "district": "Bhubaneswar & Cuttack",
      "state": "Odisha",
      "title": "Coastal Squall & Heavy Rain Watch",
      "time": "Valid till 18:00 IST",
      "action": "Fishermen strictly advised not to venture into deep sea waters.",
      "source": "IMD Cyclone Warning Centre, Bhubaneswar",
    },
    {
      "level": "YELLOW",
      "district": "New Delhi & NCR",
      "state": "Delhi",
      "title": "Heatwave & High Humidity Index",
      "time": "Valid till 17:00 IST",
      "action": "Avoid prolonged direct sun exposure during noon. Maintain hydration.",
      "source": "IMD National Weather Forecasting Centre, New Delhi",
    },
    {
      "level": "GREEN",
      "district": "Bengaluru Urban",
      "state": "Karnataka",
      "title": "Normal Monsoonal Conditions",
      "time": "Valid 24 Hours",
      "action": "No special weather precautions required. Isolated light drizzles possible.",
      "source": "IMD Bengaluru Meteorological Centre",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMD Official Warning Center'),
      ),
      body: Column(
        children: [
          // Category Selector
          Container(
            color: const Color(0xFF0F172A),
            child: Row(
              children: List.generate(categories.length, (idx) {
                final isSelected = idx == selectedCategoryIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => selectedCategoryIndex = idx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: isSelected ? const Color(0xFFFF9933) : Colors.transparent, width: 2.5)),
                      ),
                      child: Text(
                        categories[idx],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFFFF9933) : Colors.white60,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Severity Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["All", "RED", "ORANGE", "YELLOW", "GREEN"].map((f) {
                  final isSel = f == selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(f, style: TextStyle(fontSize: 12, color: isSel ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => selectedFilter = f);
                      },
                      selectedColor: f == "RED" ? Colors.red : (f == "ORANGE" ? Colors.orange : (f == "YELLOW" ? Colors.yellow : (f == "GREEN" ? Colors.green : const Color(0xFFFF9933)))),
                      backgroundColor: const Color(0xFF1E293B),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Alert Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final item = alerts[index];
                if (selectedFilter != "All" && item['level'] != selectedFilter) {
                  return const SizedBox.shrink();
                }
                Color color = Colors.green;
                if (item['level'] == 'RED') color = Colors.red;
                if (item['level'] == 'ORANGE') color = Colors.orange;
                if (item['level'] == 'YELLOW') color = Colors.yellow;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: color, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                              child: Text(item['level']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black)),
                            ),
                            const SizedBox(width: 10),
                            Text('${item['district']}, ${item['state']}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(item['time']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(item['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🛡️ ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  'Action: ${item['action']!}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Source: ${item['source']!}', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
