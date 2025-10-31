import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final primaryColor = Colors.grey.shade800;

    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: screenHeight * 0.08,
            backgroundColor: primaryColor,
            iconTheme: IconThemeData(color: Colors.white),
            title: Row(
              children: [
                Image.asset(
                  'images/UMBC-logo20.png',
                  height: screenHeight * 0.07,     
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 12),
                Text('Umbc Guide Dogs', style: GoogleFonts.cinzel(fontSize: screenHeight * 0.04, 
                color: Color(0xFFFFB81C), 
                fontWeight: FontWeight.w500)),
                //TextStyle(fontSize: screenHeight * 0.06, color: Color(0xFFFFB81C))
              ],
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
                  child: CustomSearchBar(),
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

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Search for locations, buildings, etc.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade800, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          ),
        );
      },

      suggestionsCallback: (pattern) async {
        return await search(pattern); // 
      },

      itemBuilder: (context, String suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },

      
      onSelected: (String suggestion) {
        // make call to generate route, sprint 3
      },

      
      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No buildings found.'),
      ),
    );
  }
}


/// returns list of service - building for specified category
Future<String?> fetchBuildingsByCategory(String id) async {
  //replace with server address after hosting
  final uri = Uri.parse('https://umbcgdserver.onrender.com/helpmenu/$id');
  try {
    final resp = await http.get(uri).timeout(const Duration(seconds: 5));

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

// returns list of building names that matches search term
Future<List<String>> search(String term) async {
  final uri = Uri.http('umbcgdserver.onrender.com', '/search', {'q': term});

  try {
    final resp = await http.get(uri).timeout(const Duration(seconds: 5));

    if (resp.statusCode == 200) {
      final List<dynamic> results = jsonDecode(resp.body);
      List<String> buildingNames = [];
      
      // loops thru json objects and append building name to list
      for (var building in results) {
        buildingNames.add(building['Building']);
      }

      return buildingNames;
    } else {
      return [];
    }

  } catch (e) {
    return [];
  }

}