import 'dart:io';

import 'package:beacon_project/beacons/beacons_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

class BeaconLibrary extends StatefulWidget {
  const BeaconLibrary({super.key});

  @override
  State<BeaconLibrary> createState() => _BeaconLibraryState();
}

class _BeaconLibraryState extends State<BeaconLibrary> {

  Future<void> range() async {
    try {

      // or if you want to include automatic checking permission
      await flutterBeacon.initializeAndCheckScanning;
      print(await flutterBeacon.initializeAndCheckScanning);
    } on PlatformException catch(e) {
      // library failed to initialize, check code and message
      print("exception");
    }
  }

  void rangingbeacon(){
    final regions = <Region>[];

    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(Region(
          identifier: 'Apple Airlocate',
          proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
    } else {
      // android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(identifier: 'com.example.beacon_project'));
    }

    print(regions);
// to start ranging beacons
    var streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) {
      // result contains a region and list of beacons found
      print(result.beacons);
      // list can be empty if no matching beacons were found in range
    });

// to stop ranging beacons
    streamRanging.cancel();
  }

  void monitoringbeacon(){
    final regions = <Region>[];

    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(Region(
          identifier: 'Apple Airlocate',
          proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
    } else {
      // Android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(identifier: 'com.example.beacon_project'));
    }

// to start monitoring beacons
    var streamMonitoring = flutterBeacon.monitoring(regions).listen((MonitoringResult result) {
      // result contains a region, event type and event state
      print(result.region);
    });
    print(regions);
// to stop monitoring beacons
    streamMonitoring.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ranging, Monitoring Beacons"),
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: (){
            range();
          }, child: Text("Show Beacons")),
          SizedBox(height: 40),
          ElevatedButton(onPressed: (){
            rangingbeacon();
          }, child: Text("Show List")),
          SizedBox(height: 40,),
          ElevatedButton(onPressed: (){
            monitoringbeacon();
          }, child: Text("Monitor")),


          SizedBox(height: 100,),
          ElevatedButton(onPressed: (){
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BeaconsScan()),
            );
            }, child: Text("Go to Beacons Plugin"))
        ],
      ),
    );
  }
}


// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_beacon/flutter_beacon.dart';
//
// class BeaconScanner extends StatefulWidget {
//   const BeaconScanner({Key? key}) : super(key: key);
//
//   @override
//   _BeaconScannerState createState() => _BeaconScannerState();
// }
//
// class _BeaconScannerState extends State<BeaconScanner> {
// // Declare the variables
//   late StreamSubscription<RangingResult> _streamRanging; // For scanning beacons
//   List<Beacon> _beacons = []; // For storing the scanned beacons
//
//   @override
//   void initState() {
//     super.initState();
// // Initialize the flutter beacon
//     _initFlutterBeacon();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
// // Cancel the stream subscription
//     _streamRanging.cancel();
//   }
//
// // Initialize the flutter beacon
//   void _initFlutterBeacon() async {
// // Request permission for location service and bluetooth service
//     await flutterBeacon.requestAuthorization;
// // Define a region to scan for beacons with any identifiers
//     final region = Region(
//       identifier: 'allbeacons',
//       proximityUUID: null,
//       major: null,
//       minor: null,
//     );
// // Start ranging for beacons in the region
//     _streamRanging =
//         flutterBeacon.ranging([region]).listen((RangingResult result) {
//           if (result.beacons.isNotEmpty) {
//             setState(() {
// // Update the list of beacons
//               _beacons = result.beacons;
//             });
//           }
//         });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Beacon Scanner'),
//       ),
//       body: ListView.builder(
//         shrinkWrap: true,
//         itemCount: _beacons.length,
//         itemBuilder: (context, index) {
// // Display the beacon information in a list tile
//           final beacon = _beacons[index];
//           print(_beacons[index]);
//           return ListTile(
//             title: Text('UUID: ${beacon.proximityUUID}'),
//             subtitle: Text('Major: ${beacon.major}, Minor: ${beacon.minor}'),
//             trailing: Text('Distance: ${beacon.accuracy} m'),
//           );
//         },
//       ),
//     );
//   }
// }