import 'package:flutter/material.dart';
import 'dart:async'; // ⏰ for Timer
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';

Future<Map<String, dynamic>?> fetchDua(String ritualName) async {
  final url = Uri.parse('http://10.0.2.2/e_motawif_new/get_dua.php');

  try {
    final response = await http.post(url, body: {'ritual_name': ritualName});
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success']) {
        return json['data'];
      }
    }
  } catch (e) {
    print('Error fetching dua: $e');
  }

  return null;
}

class RitualGuidancePage extends StatefulWidget {
  @override
  _RitualGuidancePageState createState() => _RitualGuidancePageState();
}

class _RitualGuidancePageState extends State<RitualGuidancePage> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> rituals = [
    {
      'title': 'Ihram',
      'description': 'State of spiritual purity before Hajj/Umrah.',
      'icon': Icons.accessibility_new,
      'unlockDate': '2025-04-25'
    },
    {
      'title': 'Tawaf',
      'description': 'Circling the Kaaba seven times.',
      'icon': Icons.sync,
      'unlockDate': '2025-06-05'
    },
    {
      'title': 'Sa’i',
      'description': 'Walking between Safa and Marwah.',
      'icon': Icons.directions_walk,
      'unlockDate': '2025-06-06'
    },
    {
      'title': 'Arafat',
      'description': 'Standing at Mount Arafat in prayer.',
      'icon': Icons.place,
      'unlockDate': '2025-06-07'
    },
    {
      'title': 'Muzdalifah',
      'description': 'Collecting pebbles for Jamarat.',
      'icon': Icons.grain,
      'unlockDate': '2025-06-07'
    },
    {
      'title': 'Jamarat',
      'description': 'Stoning of the pillars.',
      'icon': Icons.terrain,
      'unlockDate': '2025-06-08'
    },
    {
      'title': 'Tawaf Al-Ifadah',
      'description': 'Final Tawaf before leaving Mecca.',
      'icon': Icons.repeat,
      'unlockDate': '2025-06-10'
    },
  ];

  DateTime today = DateTime.now();

  void _openGoogleMaps() async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=21.4225,39.8262');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  bool isUnlocked(String dateStr) {
    final unlockDate = DateTime.parse(dateStr);
    return today.isAfter(unlockDate) || today.isAtSameMomentAs(unlockDate);
  }

  void nextStep() {
    if (_currentStep < rituals.length - 1) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void scheduleInAppReminder(
      BuildContext context, String title, DateTime scheduledTime) {
    final now = DateTime.now();
    final delay = scheduledTime.difference(now);

    if (delay.isNegative) {
      return; // Don't schedule if time is in the past
    }

    Timer(delay, () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("⏰ Ritual Reminder"),
          content: Text("Time for: $title"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Got it!"),
            )
          ],
        ),
      );
    });
  }

  void previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = isUnlocked(rituals[_currentStep]['unlockDate']);
    final progress = (_currentStep + 1) / rituals.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ritual Guidance', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Color(0xFF0D4A45),
            ),
            SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                child: Card(
                  key: ValueKey<int>(_currentStep),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: unlocked ? Colors.white : Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(rituals[_currentStep]['icon'],
                            size: 60, color: Colors.teal),
                        SizedBox(height: 20),
                        Text(rituals[_currentStep]['title'],
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text(
                          rituals[_currentStep]['description'],
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: unlocked ? _openGoogleMaps : null,
                          icon: Icon(Icons.map),
                          label: Text("View Location"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0D4A45),
                            foregroundColor: Colors.white, // ✅ ADD THIS
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: unlocked
                              ? () async {
                                  // 🔄 Show Loading Dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  final dua = await fetchDua(
                                      rituals[_currentStep]['title']);

                                  // ✅ Close Loading Dialog
                                  Navigator.pop(context);

                                  // 🔽 Show Result or Error Dialog
                                  if (dua != null) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text("Companion Dua"),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('📜 Arabic:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(dua['dua_arabic'] ?? ''),
                                              SizedBox(height: 8),
                                              Text('🔤 Transliteration:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(dua['dua_transliteration'] ??
                                                  ''),
                                              SizedBox(height: 8),
                                              Text('🌍 Translation:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  dua['dua_translation'] ?? ''),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("Close"),
                                          )
                                        ],
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text("No Dua Found"),
                                        content: Text(
                                            "No dua available for this ritual yet."),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("Close"),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: Icon(Icons.menu_book),
                          label: Text("Show Dua"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0D4A45),
                            foregroundColor: Colors.white, // ✅ ADD THIS
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: unlocked
                              ? () async {
                                  TimeOfDay? picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );

                                  if (picked != null) {
                                    final now = DateTime.now();
                                    final scheduledDate = DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                      picked.hour,
                                      picked.minute,
                                    );

                                    scheduleInAppReminder(
                                        context,
                                        rituals[_currentStep]['title'],
                                        scheduledDate);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'In-app reminder set for ${picked.format(context)}'),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: Icon(Icons.alarm),
                          label: Text("Set Reminder"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: previousStep,
                  child: Text("Back"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: nextStep,
                  child: Text("Next"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0D4A45),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
