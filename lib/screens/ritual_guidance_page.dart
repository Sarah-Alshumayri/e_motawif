import 'package:flutter/material.dart';

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
      'icon': Icons.accessibility_new
    },
    {
      'title': 'Tawaf',
      'description': 'Circling the Kaaba seven times.',
      'icon': Icons.sync
    },
    {
      'title': 'Sa’i',
      'description': 'Walking between Safa and Marwah.',
      'icon': Icons.directions_walk
    },
    {
      'title': 'Arafat',
      'description': 'Standing at Mount Arafat in prayer.',
      'icon': Icons.place
    },
    {
      'title': 'Muzdalifah',
      'description': 'Collecting pebbles for Jamarat.',
      'icon': Icons.grain
    },
    {
      'title': 'Jamarat',
      'description': 'Stoning of the pillars.',
      'icon': Icons.terrain
    },
    {
      'title': 'Tawaf Al-Ifadah',
      'description': 'Final Tawaf before leaving Mecca.',
      'icon': Icons.repeat
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ritual Guidance', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0D4A45), // Match Services Page color
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < rituals.length - 1) {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  }
                },
                steps: rituals.map((ritual) {
                  return Step(
                    title: Row(
                      children: [
                        Icon(ritual['icon'], color: Colors.teal), // Add Icon
                        SizedBox(
                            width: 10), // Add spacing between icon and text
                        Text(ritual['title']!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    content: Text(
                      ritual['description']!,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    isActive: _currentStep >= rituals.indexOf(ritual),
                    state: _currentStep > rituals.indexOf(ritual)
                        ? StepState.complete
                        : StepState.indexed,
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D4A45),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text("Restart Ritual Steps"),
            ),
          ],
        ),
      ),
    );
  }
}
