import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'UMBC Guide Dogs',
      home: HomeScreen(),
      // add theme/routes here as needed
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // help menu dialog
  void _openHelpMenu(BuildContext context) {
    // string of items mapped to the category selected
    String? selectedInfoText;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text('What are you looking for?'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min, // Prevents the dialog from expanding
              children: [
                DropdownMenu(
                  label: Text('Select Service Category'),
                  enableFilter: true,
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: 'academic', label: 'Academic'),
                    DropdownMenuEntry(value: 'administrative', label: 'Administrative'),
                    DropdownMenuEntry(value: 'financial', label: 'Financial'),
                    DropdownMenuEntry(value: 'food', label: 'Food'),
                    DropdownMenuEntry(value: 'health', label: 'Health'),
                    DropdownMenuEntry(value: 'recreational', label: 'Recreational'),
                    DropdownMenuEntry(value: 'residential', label: 'Residential'),
                    DropdownMenuEntry(value: 'studentservices', label: 'Student Services'),
              
                  ],
                  onSelected: (String? value) async {
                    if (value == null) return;
                    final infoText = await fetchBuildingsByCategory(value);
                    setState(() {
                      selectedInfoText = infoText ?? 'No information available for this category.';
                    });
                  },
                ),

                SizedBox(height: 20), 

                if (selectedInfoText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(selectedInfoText!),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Now MediaQuery.of(context) and showDialog(context) are valid
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final primaryColor = Colors.blue.shade400;

    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: const Text(
              'UMBC GUIDE DOGS',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),

          // SEARCH BAR & HELP MENU
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // HELP MENU 
                Tooltip(
                  message: 'Help Menu',
                  child: IconButton(
                    icon: Icon(Icons.help,
                        color: primaryColor, size: screenHeight * 0.06),
                    onPressed: () => _openHelpMenu(context),
                  ),
                ),

                SizedBox(width: screenWidth * 0.01),

                Expanded(
                  child: SearchBar(
                    hintText: 'Search for locations, buildings, etc.',
                  ),
                ),
              ],
            ),
          ),

          // menu drawer
          drawer: const Drawer(
            child: Center(
              child: Text('add whatever additional features here'),
            ),
          ),

        ),
      ),
    );
  }
}

// return: string of building names for selected category
Future<String?> fetchBuildingsByCategory(String id) async {
  final uri = Uri.parse('http://localhost:3000/helpmenu/$id'); 
  try {
    final resp = await http.get(uri).timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      // maps name field of each object to a list
      if (decoded is List) {
        final names = decoded
            .where((e) => e is Map && e.containsKey('Name'))
            .map((e) => e['Name'].toString())
            .toList();
        if (names.isNotEmpty) return names.join('\n');
      }
      // If backend returns an object with keys that contain name fields:
      if (decoded is Map) {
        // Collect values where the key is "name" or the value is a string
        final names = <String>[];
        decoded.forEach((k, v) {
          if (k == 'Name' && v != null) {
            names.add(v.toString());
          }
          else if (v is Map && v.containsKey('Name')) {
            names.add(v['Name'].toString());
          }
          else if (v is String && v.isNotEmpty) {
            names.add(v);
          }
        });
        if (names.isNotEmpty) return names.join(', ');
      }
    }
  } catch (e) {
    //nothin
  }
  return null;
}
