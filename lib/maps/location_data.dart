import 'package:beacon_project/views/app_broadcasting.dart';
import 'package:beacon_project/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controller/requirement_state_controller.dart';

class LocationMap extends StatefulWidget {
  const LocationMap({Key? key}) : super(key: key);

  @override
  LocationMapState createState() => LocationMapState();
}

class LocationMapState extends State<LocationMap> with WidgetsBindingObserver {
// Declare the variables
  final controller = Get.find<RequirementStateController>();
  late Location location;
  late LatLng currentPosition;
  late Marker marker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    location = Location();
    _getCurrentLocation();
// Listen to the location changes
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
    });
  }

  @override
  void dispose(){
    super.dispose();
    _getCurrentLocation();
  }

// Get the current location
  void _getCurrentLocation() async {

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
// Get the location data
    LocationData locationData = await location.getLocation();
    if(mounted) {
      setState(() {
// Set the current position and marker
        currentPosition =
            LatLng(locationData.latitude!, locationData.longitude!);
        marker = Marker(
          markerId: const MarkerId('current'),
          position: currentPosition,
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Map'),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) : GoogleMap(initialCameraPosition: CameraPosition(target: currentPosition, zoom: 15),
        markers: {marker},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 28.0),
        child: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(onPressed: (){
            print(currentPosition);
            //Navigate to broadcasting page
            Get.to(HomePage());
          },
            tooltip: 'Open Google Maps',
            child: const Icon(Icons.share)
          ),
        ),
      ),
    );
  }
}