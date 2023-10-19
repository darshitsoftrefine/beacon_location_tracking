import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:beacon_project/beacons/beacon_library.dart';
import 'package:beacon_project/maps/location_data.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override

  double lat = 0.0;
  double long = 0.0;

  @override
  initState(){
    locate(lat, long);
    super.initState();


  }

  Future<void> beac() async {
    BeaconBroadcast beaconBroadcast = BeaconBroadcast();
    beaconBroadcast.setUUID('v')
        .setMajorId(1)
        .setMinorId(100)
        .setTransmissionPower(-59)//iOS-only, optional
        .setLayout('m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24')
        .setManufacturerId(0x004C)
        .start();
    bool? isAdvertising = await beaconBroadcast.isAdvertising();
    print(isAdvertising);
  }

  Future<void> advertise() async {
    BeaconBroadcast beaconBroadcast = BeaconBroadcast();
    BeaconStatus transmissionSupportStatus = await beaconBroadcast.checkTransmissionSupported();
    switch (transmissionSupportStatus) {
      case BeaconStatus.supported:
      // You're good to go, you can advertise as a beacon
      print("Good to go");
        break;
      case BeaconStatus.notSupportedMinSdk:
      // Your Android system version is too low (min. is 21)
      print("Version is too low");
        break;
      case BeaconStatus.notSupportedBle:
      // Your device doesn't support BLE
      print("Does not support BLE");
        break;
      case BeaconStatus.notSupportedCannotGetAdvertiser:
      // Either your chipset or driver is incompatible
      print(" chipset or driver is incompatible");
        break;
    }
    beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
      // Now you know if beacon is advertising
      print(isAdvertising);
    });
  }

  void stop(){
    BeaconBroadcast beaconBroadcast = BeaconBroadcast();
    beaconBroadcast.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Location Tracking Using Beacon"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: (){
            beac();
          }, child: const Text("Hello")),
          ElevatedButton(onPressed: (){
            advertise();
    }, child: const Text("Advertise")),
          ElevatedButton(onPressed: (){
            stop();
          }, child: const Text("Stop")),
          Text('xcdb',style: const TextStyle(fontSize: 20),),
          const SizedBox(height: 50,),
          ElevatedButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BeaconLibrary()),
            );
          }, child: const Text("Go to Beacons")),

          const SizedBox(height: 50,),
          ElevatedButton(onPressed: () async {
            LocationData loc = await Location().getLocation();
            lat = loc.latitude!;
            long = loc.longitude!;
            setState(() {
              locate(lat, long);
            });
          }, child: const Text("Get Location")),

          Text("Latitude: " +lat.toString() + '\n' + "Longitude: " + long.toString(), style: const TextStyle(fontSize: 20),),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LocationMap()),
        );
      },
        tooltip: 'Open Google Maps',
        child: const Icon(Icons.location_on),
      ),
    );
  }

  Future<LocationData> locate(double lat, double long) async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {

      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {

      }
    }
    locationData = await location.getLocation();
    lat = locationData.latitude!;
    long = locationData.longitude!;
    return locationData;
  }
}
