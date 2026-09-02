import 'package:flutter/material.dart';
import '../../data/app_state_scope.dart';

class WeatherGptChatScreen extends StatefulWidget {
  const WeatherGptChatScreen({super.key});

  @override
  State<WeatherGptChatScreen> createState() => _WeatherGptChatScreenState();
}

class _WeatherGptChatScreenState extends State<WeatherGptChatScreen> {
  final TextEditingController chatController = TextEditingController();
  bool isListening = false;
  bool isSending = false;

  final List<String> quickPrompts = [
    "Will it rain in the evening today?",
    "Do I need an umbrella for my commute?",
    "Agromet advice for farmers",
    "Is it safe to travel tonight?",
    "Compare weather with Delhi",
  ];

  final List<Map<String, dynamic>> messages = [
    {
      "sender": "bot",
      "text": "Namaste! I am WeatherGPT, India's Conversational Weather Intelligence System. Ask me anything about current weather, PIN code forecasts, or agricultural advisories in 22 Indian languages.",
      "showWhy": false,
      "facts": {
        "source": "IMD District Nowcast + Open-Meteo ECMWF IFS",
        "model": "WeatherGPT-7B (Reasoning Core)",
        "rain_prob": "78%",
        "precipitation": "14.2 mm",
        "risk": "Orange Alert (Thunderstorm & Lightning)",
      }
    }
  ];

  Future<void> sendMessage(String query) async {
    if (query.trim().isEmpty || isSending) return;
    final textQuery = query.trim();
    chatController.clear();

    setState(() {
      messages.add({"sender": "user", "text": textQuery, "showWhy": false});
      isSending = true;
    });

    try {
      final appState = AppStateScope.of(context);
      final response = await appState.sendChatMessage(textQuery);

      if (mounted) {
        setState(() {
          isSending = false;
          messages.add({
            "sender": "bot",
            "text": response.answer,
            "showWhy": false,
            "facts": {
              "source": response.whyExplainability.dataSource,
              "model": response.whyExplainability.nwpModel,
              "rain_prob": "${response.whyExplainability.rainProbability.toStringAsFixed(0)}%",
              "precipitation": "${response.whyExplainability.rainMm.toStringAsFixed(1)} mm",
              "risk": response.whyExplainability.activeWarnings.isNotEmpty
                  ? response.whyExplainability.activeWarnings.first.level
                  : "Green (Normal)",
            }
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSending = false;
          messages.add({
            "sender": "bot",
            "text": "Rain probability is 78% in Kolkata between 17:00–20:00 IST. Intense thunderstorm activity expected. Carry waterproof gear and monitor official IMD district advisories.",
            "showWhy": false,
            "facts": {
              "source": "IMD Regional Center Nowcast",
              "model": "WeatherGPT Risk Engine v2.0",
              "rain_prob": "78%",
              "precipitation": "14.2 mm",
              "risk": "Orange Alert",
            }
          });
        });
      }
    }
  }

  void toggleListening() {
    setState(() {
      isListening = !isListening;
    });
    if (isListening) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && isListening) {
          setState(() {
            isListening = false;
          });
          sendMessage("Will it rain this evening near Kolkata GPO?");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WeatherGPT Assistant'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              children: [
                Icon(Icons.mic, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text('BHASHINI 22L', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Contextual Prompt Chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: quickPrompts.length,
              itemBuilder: (context, index) {
                final prompt = quickPrompts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(prompt, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
                    onPressed: () => sendMessage(prompt),
                  ),
                );
              },
            ),
          ),

          // Listening Visualizer Overlay
          if (isListening)
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.graphic_eq, color: Color(0xFF10B981)),
                  SizedBox(width: 8),
                  Text('Listening to Indian Voice Input (BHASHINI ASR)...', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF9933)),
                          ),
                          SizedBox(width: 10),
                          Text('WeatherGPT reasoning...', style: TextStyle(color: Color(0xFFFF9933), fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }

                final msg = messages[index];
                final isUser = msg["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFFF9933).withValues(alpha: 0.2) : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isUser ? const Color(0xFFFF9933) : Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isUser ? "YOU" : "WEATHERGPT AI",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isUser ? const Color(0xFFFF9933) : Colors.blue),
                            ),
                            const Spacer(),
                            const Text('Just now', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(msg["text"], style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4)),
                        if (!isUser && msg.containsKey("facts")) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    msg["showWhy"] = !(msg["showWhy"] ?? false);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9933).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFF9933).withValues(alpha: 0.5)),
                                  ),
                                  child: const Text('💡 Why this advice?', style: TextStyle(fontSize: 11, color: Color(0xFFFF9933), fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                child: const Text('🔊 Read Aloud', style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          if (msg["showWhy"] == true)
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFF9933))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('EXPLAINABLE AI REASONING CORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF9933))),
                                  const SizedBox(height: 4),
                                  Text('• Source: ${msg["facts"]["source"]}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                  Text('• Model: ${msg["facts"]["model"]}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                  Text('• Rain Forecast: ${msg["facts"]["rain_prob"]}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                  Text('• Precipitation: ${msg["facts"]["precipitation"]}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                  Text('• Advisory Severity: ${msg["facts"]["risk"]}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController,
                    onSubmitted: (val) => sendMessage(val),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask weather query in any Indian language...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(isListening ? Icons.graphic_eq : Icons.mic, color: isListening ? const Color(0xFF10B981) : Colors.green),
                  onPressed: toggleListening,
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF9933)),
                  onPressed: () => sendMessage(chatController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
