import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:e_motawif_new/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D4A45),
        centerTitle: true,
        iconTheme: const IconThemeData(
            color: Colors.white), // makes back & refresh icons white
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => LoginPage()), // make sure it's imported!
            );
          },
        ),
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // refresh the page
            },
          ),
        ],
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildStatCard("Total Pilgrims",
                  stats['total_pilgrims'].toString(), Icons.people),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildStatCard("Total Motawifs",
                  stats['total_motawifs'].toString(), Icons.person_pin),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildStatCard("Unassigned",
                  stats['unassigned_pilgrims'].toString(), Icons.error_outline),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
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
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
            Row(
              children: const [
                Icon(Icons.admin_panel_settings, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  "Motawif Management",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...motawifs.map((motawif) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(motawif['name']),
                  subtitle: Text(
                      "ID: ${motawif['user_id']}\nEmail: ${motawif['email']}\nAssigned Pilgrims: ${motawif['assigned_count']}"),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showEditDialog(context, motawif), // for Motawif
                        // ✅ only motawif
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(
                            motawif['user_id']), // ✅ only user_id
                      ),
                    ],
                  ),
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
            Row(
              children: const [
                Icon(Icons.admin_panel_settings, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  "Pilgrim Management",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...pilgrims.map((p) {
              final statusColor =
                  p['status'] == 'Unassigned' ? Colors.red : Colors.green;

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(p['name']),
                  subtitle: Text(
                    "ID: ${p['user_id']}\nEmail: ${p['email']}\nStatus: ${p['status']}${p['motawif_name'] != null ? '\nAssigned to: ${p['motawif_name']}' : ''}",
                  ),
                  trailing: Wrap(
                    spacing: 6,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showEditDialog(context, p), // for Pilgrim
                        // ✅ pass only `p`
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(
                            p['user_id']), // ✅ pass only `user_id`
                      ),
                      if (p['status'] != 'Unassigned')
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.orange),
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
                              setState(() {});
                            }
                          },
                        )
                      else
                        Icon(Icons.circle, color: statusColor, size: 16),
                    ],
                  ),
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
                Row(
                  children: const [
                    Icon(Icons.admin_panel_settings, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      "Assign Pilgrims to Motawifs",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        const url = 'http://10.0.2.2/e_motawif_new/export_assignments_csv.php';
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['name'] ?? '');
    final emailController = TextEditingController(text: user['email'] ?? '');
    String role = user['role'] ?? 'pilgrim'; // ✅ avoid null exception

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit User Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            DropdownButtonFormField<String>(
              value: role,
              items: ['pilgrim', 'motawif', 'admin']
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r[0].toUpperCase() + r.substring(1)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) role = value;
              },
              decoration: const InputDecoration(labelText: "Role"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final result = await DatabaseHelper().updateUser(
                user_id: user['user_id'],
                name: nameController.text,
                email: emailController.text,
                role: role,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor:
                      result['success'] ? Colors.green : Colors.red,
                ),
              );

              if (result['success']) {
                setState(() {}); // Refresh UI
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await DatabaseHelper().deleteUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      setState(() {});
    }
  }
}
