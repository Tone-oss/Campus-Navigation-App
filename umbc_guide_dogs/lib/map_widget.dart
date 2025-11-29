import 'dart:async'; // Required for the timer/delay
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

//functions from gps.js, using js interop
@JS('initMapbox')
external void initMapbox();

@JS('createRouteFromFlutter')
external void createRouteFromFlutter(num lng, num lat);

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool _registered = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) return;

    //registers/creates the div for the map
    if (!_registered) {
      ui_web.platformViewRegistry.registerViewFactory(
        'mapbox-view',
        (int viewId) {
          final div = web.document.createElement('div');
          div.setAttribute('id', 'map'); 
          div.setAttribute('style', 'width:100%;height:100%;border:none;');
          return div;
        },
      );
      _registered = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _waitForMapElement();
      }
    });
  }

  //delay map init until div done
  Future<void> _waitForMapElement() async {
    int attempts = 0;
    while (attempts < 30) { 
      
      final element = web.document.getElementById('map');
      
      if (element != null) {
        try {
          //create map
          initMapbox();
          _initialized = true;
          debugPrint('Mapbox initialized');
        } catch (e) {
          debugPrint('init error: $e');
        }
        return; 
      }

      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Container(color: Colors.grey.shade300);
    }
    
    //render map
    return const HtmlElementView(viewType: 'mapbox-view');
  }
}