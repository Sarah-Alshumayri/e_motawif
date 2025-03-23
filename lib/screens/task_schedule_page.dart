import 'package:flutter/material.dart';
import '../database_helper.dart';

class Task {
  String id;
  String title;
  String assignedTo;
  String status;
  DateTime date;
  bool reminder;
  bool completed;
  String motawifId;

  Task({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.status,
    required this.date,
    this.reminder = false,
    this.completed = false,
    required this.motawifId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'], // ✅ Fix field name
      assignedTo: json['assigned_to'],
      status: json['status'],
      date: DateTime.parse(json['date']),
      reminder: json['reminder'] == "1",
      completed: json['completed'] == "1",
      motawifId: json['motawif_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motawif_id': motawifId,
      'title': title, // ✅ Fix field name
      'assigned_to': assignedTo,
      'status': status,
      'date': date.toIso8601String().split('T')[0],
      'reminder': reminder ? "1" : "0",
      'completed': completed ? "1" : "0",
    };
  }
}

class TaskSchedulePage extends StatefulWidget {
  @override
  _TaskSchedulePageState createState() => _TaskSchedulePageState();
}

class _TaskSchedulePageState extends State<TaskSchedulePage> {
  List<Task> tasks = [];
  final Color primaryColor = const Color(0xFF0D4A45);
  final dbHelper = DatabaseHelper();

  String motawifId =
      "E12345"; // 🔁 Replace with real ID from login/user session

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    List<dynamic> taskData = await dbHelper.getTasks(motawifId);
    setState(() {
      tasks = taskData.map((json) => Task.fromJson(json)).toList();
    });
  }

  void _saveTask(Task task) async {
    var result = await dbHelper.saveTask(task.toJson());
    if (result['status'] == 'success') {
      _loadTasks();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving task: ${result['message']}")),
      );
    }
  }

  void _deleteTask(Task task) async {
    var result = await dbHelper.deleteTask(task.id);
    if (result['status'] == 'success') {
      _loadTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting task: ${result['message']}")),
      );
    }
  }

  void _addOrEditTask({Task? existingTask}) {
    TextEditingController titleController =
        TextEditingController(text: existingTask?.title ?? '');
    TextEditingController assignedToController =
        TextEditingController(text: existingTask?.assignedTo ?? '');
    String selectedStatus = existingTask?.status ?? 'In Progress';
    DateTime selectedDate = existingTask?.date ?? DateTime.now();
    bool reminder = existingTask?.reminder ?? false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existingTask == null ? "Add New Task" : "Edit Task"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                TextField(
                  controller: assignedToController,
                  decoration:
                      const InputDecoration(labelText: 'Assign to Pilgrim'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: ['In Progress', 'Urgent', 'Completed']
                      .map((status) =>
                          DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedStatus = value ?? 'In Progress'),
                  decoration: const InputDecoration(labelText: 'Task Status'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                        "Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: const Text("Pick Date"),
                    )
                  ],
                ),
                CheckboxListTile(
                  title: const Text("Set Reminder"),
                  value: reminder,
                  onChanged: (val) => setState(() => reminder = val ?? false),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final newTask = Task(
                    id: existingTask?.id ?? '',
                    title: titleController.text,
                    assignedTo: assignedToController.text,
                    status: selectedStatus,
                    date: selectedDate,
                    reminder: reminder,
                    completed: existingTask?.completed ?? false,
                    motawifId: motawifId,
                  );
                  _saveTask(newTask);
                }
              },
              child: Text(existingTask == null ? "Add" : "Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusColor(String status) {
    switch (status) {
      case 'Urgent':
        return const Icon(Icons.warning, color: Colors.red);
      case 'In Progress':
        return const Icon(Icons.timelapse, color: Colors.orange);
      case 'Completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      default:
        return const Icon(Icons.info_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Task & Schedule",
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTask(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text("No tasks added yet."))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, index) {
                final task = tasks[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: _getStatusColor(task.status),
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Assigned to: ${task.assignedTo}"),
                        Text(
                            "Date: ${task.date.toLocal().toString().split(' ')[0]}"),
                        if (task.reminder) const Text("🔔 Reminder set"),
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 10,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _addOrEditTask(existingTask: task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task),
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
