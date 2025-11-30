import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'map_widget.dart'; 
import 'dart:js_interop';

// js interop to call function in gps.js
@JS('createRouteFromFlutter')
external void createRouteFromFlutter(num lng, num lat);

// new class to integrate returned coordinates from search
class Building {
  final String id;
  final String name;
  final double long;
  final double lat;
  final double floors;
  final String abbrev;
  final String description;

  Building({
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
    required this.floors,
    required this.abbrev,
    required this.description
    
  });

  //factory constructor to build class from jso ndirectly
  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['_id'] as String,
      name: json['Building'] as String,
      lat: (json['Coordinates'][1] as num).toDouble(), 
      long: (json['Coordinates'][0] as num).toDouble(),
      floors: (json['Floors'] as num?)?.toDouble() ?? 0.0,
      abbrev: json['Abbreviation'] as String? ?? 'N/A', 
      description: json['Description'] as String? ?? 'No description availible.',
    );
  }
}

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
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // return list of locations to buildings by category
  Future<String?> fetchBuildingsByCategory(String id) async {
    final uri = Uri.parse('https://umbcgdserver.onrender.com/helpmenu/$id');
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));

      if (resp.statusCode == 200) {
        final List<dynamic> buildings = jsonDecode(resp.body);
        List<String> lines = [];
        for (var building in buildings) {
          final String buildingName =
              building['buildingName'] ?? 'Unknown Building';
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

  // opens the help menu
  void _openHelpMenu(BuildContext context) {
    String? selectedInfoText;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(
          'What are you looking for?',
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // the list of diff service categories
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

                  //makes query when selected
                  onSelected: (String? value) async {
                    if (value == null) return;
                    final infoText = await fetchBuildingsByCategory(value);
                    setState(() {
                      selectedInfoText =
                          infoText ?? 'No information available for this category.';
                    });
                  },
                ),
                SizedBox(height: 20),
                if (selectedInfoText != null)
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
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final primaryColor = Colors.grey.shade800;

    return Container(
      color: primaryColor,
      child: SafeArea(
        child: Scaffold(

          // APP bar at the top
          appBar: AppBar(
            toolbarHeight: screenHeight * 0.08,
            backgroundColor: primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              children: [
                Image.asset(
                  'images/UMBC-logo20.png',
                  height: screenHeight * 0.07,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Text('Umbc Guide Dogs',
                    style: GoogleFonts.cinzel(
                        fontSize: screenHeight * 0.04,
                        color: const Color(0xFFFFB81C),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          
          body: Stack(
            children: [
              // the map !!!!
              const Positioned.fill(
                child: MapWidget(),
              ),

              Positioned(
                top: 10, 
                left: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent, 
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                      SizedBox(width: screenWidth * 0.02),
                      const Expanded(
                        child: CustomSearchBar(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // drawer for report menu (will we even do this?)
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

  // returns list of building objects that matches query 
  Future<List<Building>> search(String term) async {
    final uri = Uri.https('umbcgdserver.onrender.com', '/search', {'q': term});

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));

      if (resp.statusCode == 200) {
        final List<dynamic> results = jsonDecode(resp.body);
        List<Building> buildings = [];
        for (var jsonMap in results) {
          buildings.add(Building.fromJson(jsonMap));
        }
        return buildings;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  void _openBuildingInfo(BuildContext context, Building building) {

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Building Name: ${building.name}'),
                Text('Abbreviation: ${building.abbrev}'),
                Text('Number of Floors: ${building.floors}'),
                Text('Description: ${building.description}'),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Building>(
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Search for buildings...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade800, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          ),
        );
      },

      // makes the query, pattern is the term
      suggestionsCallback: (pattern) async {
        return await search(pattern);
      },
      
      // populates the dropdown
      itemBuilder: (context, Building suggestion) {
        return ListTile(
          // SEE IF THIS WORKS ?
          title: Text(suggestion.name),
        );
      },

      // the ACTION!
      onSelected: (Building suggestion) {
        // mane why u no work
        // okay, so database gives coordinates [X, Y], but we needed to pass it in as [Y, X] for mapbox
        createRouteFromFlutter(suggestion.lat, suggestion.long);
        _openBuildingInfo(context, suggestion);
      },

      // error prompt ig
      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No buildings found.'),
      ),
    );
  }
}