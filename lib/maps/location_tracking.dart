import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationTracking extends StatefulWidget {

  const LocationTracking({super.key});

  @override
  State<LocationTracking> createState() => _LocationTrackingState();
}

class _LocationTrackingState extends State<LocationTracking> {

  late Location location;
  late LatLng currentPosition;
  late Marker marker;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location = Location();
    location.onLocationChanged.listen((event) {
// Update the marker position
      if(mounted) {
        setState(() {
          marker = Marker(
            markerId: const MarkerId('current'),
            position: LatLng(event.latitude!, event.longitude!),
          );
        });
      }
      print("Hi latitude ${event.latitude}");
      print("Hi1 longitude ${event.longitude}");
    });
    getLocationFromScan();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    getLocationFromScan();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Tracking"),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) : GoogleMap(initialCameraPosition: CameraPosition(target: currentPosition, zoom: 15),
        markers: {marker},
      ),
    );
  }

  void getLocationFromScan() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
// Request to enable location service
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
// Check if permission is granted
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
// Request for permission
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        double? latitude = prefs.getDouble('latitude');
        double? longitude = prefs.getDouble('longitude');
        currentPosition = LatLng(latitude!, longitude!);

        marker = Marker(
          markerId: const MarkerId('current'),
          position: currentPosition,
        );
        _isLoading = false;
      });
    }
  }
}
