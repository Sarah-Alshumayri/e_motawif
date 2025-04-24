import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:e_motawif_new/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String? selectedMotawif;
  List<String> selectedPilgrims = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xFF0D4A45),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildChartSection(),
            const SizedBox(height: 24),
            _buildMotawifManagementSection(),
            const SizedBox(height: 24),
            _buildPilgrimManagementSection(),
            const SizedBox(height: 24),
            _buildAssignmentSection(),
            const SizedBox(height: 24), // Add spacing if you want
            _buildExportCsvButton(), // 👈 Add this here!
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper().getAdminStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!['status'] != 'success') {
          return const Center(child: Text("Failed to load statistics"));
        }

        final stats = snapshot.data!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard("Total Pilgrims", stats['total_pilgrims'].toString(),
                Icons.people),
            _buildStatCard("Total Motawifs", stats['total_motawifs'].toString(),
                Icons.person_pin),
            _buildStatCard("Unassigned",
                stats['unassigned_pilgrims'].toString(), Icons.error_outline),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: Container(
        width: 110,
        height: 110,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.teal, size: 30),
            const SizedBox(height: 10),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getPilgrimDistribution(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No data for chart.");
        }

        final data = snapshot.data!;
        final barGroups = <BarChartGroupData>[];
        final titles = <String>[];

        for (int i = 0; i < data.length; i++) {
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: data[i]['total_pilgrims'] * 1.0, width: 20)
              ],
            ),
          );
          titles.add(data[i]['motawif_name']);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilgrims per Motawif",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          return Text(
                              index >= 0 && index < titles.length
                                  ? titles[index]
                                  : '',
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMotawifManagementSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getMotawifs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No Motawifs found.");
        }

        final motawifs = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Motawif Management",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...motawifs.map((motawif) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(motawif['name']),
                  subtitle: Text(
                      "ID: ${motawif['user_id']}\nEmail: ${motawif['email']}\nAssigned Pilgrims: ${motawif['assigned_count']}"),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildPilgrimManagementSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getPilgrims(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No Pilgrims found.");
        }

        final pilgrims = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilgrim Management",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...pilgrims.map((p) {
              final statusColor =
                  p['status'] == 'Unassigned' ? Colors.red : Colors.green;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(p['name']),
                  subtitle: Text(
                    "ID: ${p['user_id']}\nEmail: ${p['email']}\nStatus: ${p['status']}${p['motawif_name'] != null ? '\nAssigned to: ${p['motawif_name']}' : ''}",
                  ),
                  trailing: p['status'] != 'Unassigned'
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          tooltip: "Unassign Pilgrim",
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Unassign Pilgrim"),
                                content: Text(
                                    "Are you sure you want to unassign ${p['name']}?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text("Unassign"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final result = await DatabaseHelper()
                                  .unassignPilgrim(p['user_id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: result['success']
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              );
                              setState(() {}); // refresh UI
                            }
                          },
                        )
                      : Icon(Icons.circle, color: statusColor, size: 16),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildAssignmentSection() {
    return StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder(
          future: Future.wait([
            DatabaseHelper().getMotawifList(),
            DatabaseHelper().getUnassignedPilgrims(),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Text("Failed to load assignment data.");
            }

            final motawifs = snapshot.data![0] as List<Map<String, dynamic>>;
            final pilgrims = snapshot.data![1] as List<Map<String, dynamic>>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Assign Pilgrims to Motawifs",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedMotawif,
                  hint: const Text("Select Motawif"),
                  items: motawifs
                      .map((motawif) => DropdownMenuItem<String>(
                            value: motawif['user_id'],
                            child: Text(motawif['name']),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedMotawif = value;
                  }),
                ),
                const SizedBox(height: 10),
                const Text("Select Pilgrims:"),
                ...pilgrims.map((pilgrim) {
                  return CheckboxListTile(
                    title: Text(pilgrim['name']),
                    value: selectedPilgrims.contains(pilgrim['user_id']),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          selectedPilgrims.add(pilgrim['user_id']);
                        } else {
                          selectedPilgrims.remove(pilgrim['user_id']);
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedMotawif == null || selectedPilgrims.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Please select both Motawif and Pilgrims"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final result = await DatabaseHelper()
                        .assignPilgrimsToMotawif(
                            selectedMotawif!, selectedPilgrims);

                    final List<dynamic> details = result['details'] ?? [];
                    String feedback = '';
                    for (var pilgrim in details) {
                      final id = pilgrim['user_id'];
                      final status = pilgrim['status'];
                      switch (status) {
                        case 'assigned':
                          feedback += '✅ $id assigned successfully.\n';
                          break;
                        case 'already_assigned':
                          feedback += 'ℹ️ $id already assigned.\n';
                          break;
                        case 'not_found':
                          feedback += '❌ $id not found.\n';
                          break;
                        default:
                          feedback += '⚠️ $id unknown error.\n';
                      }
                    }

                    // Clear selection after assigning
                    setState(() {
                      selectedPilgrims.clear();
                      selectedMotawif = null;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(feedback.trim()),
                      backgroundColor: Colors.teal,
                      duration: const Duration(seconds: 4),
                    ));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text("Assign"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildExportCsvButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.download),
      label: const Text("Export Assignments as CSV"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      onPressed: () {
        const url = 'http://10.0.2.2/e_motawif_new/export_assignments_csv.php';
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
    );
  }
}
