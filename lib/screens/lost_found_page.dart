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
  bool _noMatchesFound = false; // Track when no matches are found

  void _submitReport() async {
    print("Submitting item...");

    String itemName = _itemNameController.text.trim();
    String description = _descriptionController.text.trim();
    String location = _locationController.text.trim();
    String date = _dateTimeController.text.trim();
    String status = isReportingFound ? 'found' : 'lost';

    if (itemName.isEmpty || location.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all required fields!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await DatabaseHelper.instance.insertItem({
        'itemName': itemName,
        'description': description,
        'location': location,
        'date': date,
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Your item has been submitted!"),
          backgroundColor: Colors.green,
        ),
      );

      _itemNameController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _dateTimeController.clear();
    } catch (e) {
      print("Database insert error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit. Try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _searchLostItem() async {
    print("Searching for item...");

    String searchItem = _itemNameController.text.trim();
    if (searchItem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Enter an item name to search."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<Map<String, dynamic>> matchedItems =
        await DatabaseHelper.instance.searchMatchingItems(searchItem);

    setState(() {
      _matchingItems = matchedItems;
      _noMatchesFound = matchedItems.isEmpty; // Set flag if no match found
    });

    print("Search results: $_matchingItems");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Lost & Found Items',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D4A45),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text("Report Found Item"),
                    value: true,
                    groupValue: isReportingFound,
                    onChanged: (value) {
                      setState(() {
                        isReportingFound = value as bool;
                        _matchingItems.clear();
                        _noMatchesFound = false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text("Report Lost Item"),
                    value: false,
                    groupValue: isReportingFound,
                    onChanged: (value) {
                      setState(() {
                        isReportingFound = value as bool;
                        _matchingItems.clear();
                        _noMatchesFound = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(labelText: "Item Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: "Location"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateTimeController,
              decoration: const InputDecoration(labelText: "Date"),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateTimeController.text =
                        pickedDate.toString().split(' ')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: isReportingFound ? _submitReport : _searchLostItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isReportingFound ? 'Submit' : 'Search',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!isReportingFound) // Only show results when searching
              Expanded(
                child: _matchingItems.isNotEmpty
                    ? ListView.builder(
                        itemCount: _matchingItems.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 5),
                            child: ListTile(
                              leading: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              title: Text(
                                "Item: ${_matchingItems[index]['itemName']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Description: ${_matchingItems[index]['description']}\n"
                                "Location: ${_matchingItems[index]['location']}\n"
                                "Date: ${_matchingItems[index]['date']}",
                              ),
                            ),
                          );
                        },
                      )
                    : _noMatchesFound
                        ? const Center(
                            child: Text(
                              "No matching item found.",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          )
                        : const SizedBox(), // Show nothing initially
              ),
          ],
        ),
      ),
    );
  }
}
