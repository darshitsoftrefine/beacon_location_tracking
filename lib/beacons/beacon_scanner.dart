import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

class BeaconScannerWidget extends StatefulWidget {
  @override
  _BeaconScannerWidgetState createState() => _BeaconScannerWidgetState();
}

class _BeaconScannerWidgetState extends State<BeaconScannerWidget> {

  List detectedBeacons = [];

  @override
  void initState() {
    super.initState();
    _initBeaconScanning();
  }

  void _initBeaconScanning() {
    flutterBeacon.initializeAndCheckScanning;

    final regions = <Region>[];

    // Define the beacon regions you want to monitor here.
    regions.add(Region(identifier: '100', proximityUUID: 'YOUR_UUID', major: 100, minor: 1));

    flutterBeacon.ranging(regions).listen((RangingResult result) {
      if (result != null && result.beacons.isNotEmpty) {
        detectedBeacons.add(result.beacons);
        print(result.beacons);
      }
    });
    print("HI $detectedBeacons");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacon Scanner'),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: detectedBeacons.length,
        itemBuilder: (context, index) {
          final beacon = detectedBeacons[index];
          print(detectedBeacons);
          return ListTile(
            title: Text(beacon.proximityUUID),
            subtitle: Text('Major: ${beacon.major}, Minor: ${beacon.minor}'),
          );
        },
      )
    );
  }
}
