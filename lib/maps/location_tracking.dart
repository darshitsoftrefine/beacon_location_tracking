import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
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
  dynamic argumentData = Get.arguments;

  @override
  void initState() {
    super.initState();
    location = Location();
    debugPrint("Argument Data $argumentData");
    getLocationFromScan();
  }

  @override
  void dispose() {
    super.dispose();
    getLocationFromScan();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Tracking"),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) :
      GoogleMap(initialCameraPosition: CameraPosition(target: currentPosition, zoom: 15),
        markers: {marker},
      ),
    );
  }

  void getLocationFromScan() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    if(mounted){
      setState(() {
        currentPosition = LatLng(argumentData[0]['Latitude'], argumentData[1]['Longitude']);
        marker = Marker(
          markerId: const MarkerId('current'),
          position: currentPosition,
          onTap: (){
            showDialog(
                context: context, builder: (BuildContext context) =>
                AlertDialog(
                  insetPadding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                  ),
                  title: const Text("Beacon Information"),
                  content: SizedBox(
                    height: 200,
                    width: 200,
                    child: Column(
                      children: [
                        Text("The UUID of the beacon is ${argumentData[2]['ProximityUUID']}"),
                        const SizedBox(height: 20,),
                        Text("The coordinates of the beacon is Latitude  ${argumentData[0]['Latitude']} and Longitude ${argumentData[1]['Longitude']}"),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: (){
                      Navigator.pop(context);
                    }, child: const Text("Ok"))
                  ],
                ));
          }
        );
        _isLoading = false;
      });
    }
  }
}
