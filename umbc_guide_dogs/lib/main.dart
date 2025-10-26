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
        title: Text('What are you looking for?', textAlign: TextAlign.center,),
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
                  //displays text with scroll view
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          selectedInfoText!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
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

/// returns list of service - building for specified category
Future<String?> fetchBuildingsByCategory(String id) async {
  //replace with server address after hosting
  final uri = Uri.parse('http://localhost:3000/helpmenu/$id');
  try {
    final resp = await http.get(uri).timeout(const Duration(seconds: 8));

    if (resp.statusCode == 200) {
      final List<dynamic> buildings = jsonDecode(resp.body);

      // Build list of "Service - BuildingName" lines
      List<String> lines = [];

      // nested for loop that combines servce - building and appends to lines
      for (var building in buildings) {
        final String buildingName = building['buildingName'] ?? 'Unknown Building';
        final List<dynamic> services = building['services'] ?? [];

        for (var service in services) {
          final String serviceKey = service['key'] ?? 'Unknown Service';
          lines.add('$serviceKey - $buildingName');
        }
      }

      return lines.isEmpty ? null : lines.join('\n');
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}