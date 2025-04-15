import 'package:flutter/material.dart';
import '../database_helper.dart';

class LostFoundPage extends StatefulWidget {
  @override
  _LostFoundPageState createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

  bool isReportingFound = true;
  List<Map<String, dynamic>> _matchingItems = [];
  bool _noMatchesFound = false;

  void _submitReport() async {
    String itemName = _itemNameController.text.trim();
    String description = _descriptionController.text.trim();
    String location = _locationController.text.trim();
    String date = _dateTimeController.text.trim();

    if (itemName.isEmpty || location.isEmpty || date.isEmpty) {
      _showError("Please fill all required fields!");
      return;
    }

    try {
      final result = await DatabaseHelper().reportItem(
        itemName,
        description,
        location,
        date,
      );
      _showSuccess(result);
      _clearForm();
    } catch (e) {
      _showError("Failed to submit. Try again.");
    }
  }

  void _searchLostItem() async {
    String itemName = _itemNameController.text.trim();
    String description = _descriptionController.text.trim();
    String location = _locationController.text.trim();
    String date = _dateTimeController.text.trim();

    if (itemName.isEmpty || location.isEmpty || date.isEmpty) {
      _showError("Please fill all required fields!");
      return;
    }

    try {
      final matchedItems = await DatabaseHelper().searchLostItem(
        itemName,
        description,
        location,
        date,
      );
      setState(() {
        _matchingItems = matchedItems;
        _noMatchesFound = matchedItems.isEmpty;
      });
    } catch (e) {
      _showError("Search failed. Try again.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _clearForm() {
    _itemNameController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _dateTimeController.clear();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report Lost & Found Items',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D4A45),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select an option:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isReportingFound,
                      onChanged: (value) {
                        setState(() {
                          isReportingFound = value!;
                          _matchingItems.clear();
                          _noMatchesFound = false;
                        });
                      },
                      activeColor: Colors.teal,
                    ),
                    const Text(
                      "Report Found Item",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: isReportingFound,
                      onChanged: (value) {
                        setState(() {
                          isReportingFound = value!;
                          _matchingItems.clear();
                          _noMatchesFound = false;
                        });
                      },
                      activeColor: Colors.teal,
                    ),
                    const Text(
                      "Report Lost Item",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInputField("Item Name", _itemNameController),
            const SizedBox(height: 10),
            _buildInputField("Description", _descriptionController),
            const SizedBox(height: 10),
            _buildInputField("Lost Location", _locationController),
            const SizedBox(height: 10),
            TextField(
              controller: _dateTimeController,
              readOnly: true,
              decoration: _inputDecoration("Date"),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  _dateTimeController.text =
                      "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                }
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: isReportingFound ? _submitReport : _searchLostItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D4A45),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isReportingFound ? "Submit" : "Search",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!isReportingFound)
              Expanded(
                child: _matchingItems.isNotEmpty
                    ? ListView.builder(
                        itemCount: _matchingItems.length,
                        itemBuilder: (context, index) {
                          final item = _matchingItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            child: ListTile(
                              leading: const Icon(Icons.inventory_2,
                                  color: Colors.green),
                              title: Text("Item: ${item['itemName']}"),
                              subtitle: Text(
                                  "Description: ${item['description']}\nLocation: ${item['location']}\nDate: ${item['date']}"),
                            ),
                          );
                        },
                      )
                    : _noMatchesFound
                        ? const Text(
                            "No matching item found.",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          )
                        : const SizedBox(),
              ),
          ],
        ),
      ),
    );
  }
}
