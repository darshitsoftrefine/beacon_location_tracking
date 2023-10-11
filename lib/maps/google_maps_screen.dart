import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {

  GoogleMapController? _controller;

// Declare a Set<Marker> variable to store the markers
  Set<Marker> _markers = {};

// Declare a BitmapDescriptor variable to store the red icon
  BitmapDescriptor? _redIcon;

  MarkerId? _currentMarkerId;
  @override
  void initState() {
    super.initState();
// Create the red icon from a color
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'assets/red_marker.bmp')
        .then((value) {
// Assign the value to the _redIcon variable
      setState(() {
        _redIcon = value;
      });
    });
  }

  static const LatLng current = LatLng(23.034296666666666, 72.50369833333333);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(initialCameraPosition: CameraPosition(target: current, zoom: 15),
        onMapCreated: (GoogleMapController controller) {
         _controller = controller;
        },
        onTap: _handleTap,
        markers: _markers,
      ),
    );
  }

  void _handleTap(LatLng point) {
// Create a new marker with a custom icon and add it to the set of markers
    setState(() {
// Remove the previous marker if it exists
      if (_currentMarkerId != null) {
        _markers.removeWhere((marker) => marker.markerId == _currentMarkerId);
      }
// Generate a unique id based on the point coordinates
      var markerIdVal = point.toString();
      final MarkerId markerId = MarkerId(markerIdVal);
// Create a new marker with a custom icon
      final Marker marker = Marker(
        markerId: markerId,
        position: point,
        icon: _redIcon ?? BitmapDescriptor.defaultMarker,
      );
// Add the new marker to the set of markers
      _markers.add(marker);
// Assign the new marker id to the current marker id variable
      _currentMarkerId = markerId;
    });
  }
}
