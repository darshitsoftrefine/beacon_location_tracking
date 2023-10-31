import 'dart:core';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../beacon_notification/beacon_notification.dart';
import '../controller/requirement_state_controller.dart';
import '../maps/location_tracking.dart';

class TabScanning extends StatefulWidget {
  const TabScanning({super.key});

  @override
  TabScanningState createState() => TabScanningState();
}

class TabScanningState extends State<TabScanning> {
  StreamSubscription<RangingResult>? _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>{};
  final controller = Get.find<RequirementStateController>();
  Set<String> seenKeys = {};

  @override
  void initState() {
    super.initState();
    controller.startStream.listen((flag) {
      if (flag == true) {
        initScanBeacon();
      }
    });
    controller.pauseStream.listen((flag) {
      if (flag == true) {
        pauseScanBeacon();
      }
    });
  }

  initScanBeacon() async {
    await flutterBeacon.initializeScanning;
    if (!controller.authorizationStatusOk ||
        !controller.locationServiceEnabled ||
        !controller.bluetoothEnabled) {
      debugPrint(
          'RETURNED, authorizationStatusOk=${controller.authorizationStatusOk}, '
              'locationServiceEnabled=${controller.locationServiceEnabled}, '
              'bluetoothEnabled=${controller.bluetoothEnabled}');
      return;
    }

    final regions = <Region>[
      Region(
        identifier: 'Cubeacon',
        proximityUUID: 'CB10023F-A318-3394-4199-A8730C7C1AEC',
      ),
      Region(
        identifier: 'BeaconType2',
        proximityUUID: '6a84c716-0f2a-1ce9-f210-6a63bd873dd9',
      ),
    ];

    if (_streamRanging != null) {
      if (_streamRanging!.isPaused) {
        _streamRanging?.resume();
        return;
      }
    }

    _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) {
          if (mounted) {
            setState(() {
              _regionBeacons[result.region] = result.beacons;
              for (var list in _regionBeacons.values) {
                _beacons.addAll(list);
              }
            });
          }
        });
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
  }

  @override
  void dispose() {
    _streamRanging?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _beacons.isEmpty ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _beacons.length,
        itemBuilder: (BuildContext context, int index) {
          String key = '_beacons-$index';
          return VisibilityDetector(
            key: Key(key),
            onVisibilityChanged: (visibilityInfo) {
                  //not been seen before
              if (visibilityInfo.visibleFraction > 0 && !seenKeys.contains(key)) {
                debugPrint('${!seenKeys.contains(key)}');
                    // Add the key to the seen set
                seenKeys.add(key);
                debugPrint('$seenKeys');
                NotifyService().showNotification(
                    title: 'A beacon is identified',
                    body: "The beacon id is ${_beacons.elementAt(index).proximityUUID} beacon",
                    id: index);
              }
            },
            child: ListTile(
              title: Text(
                _beacons.elementAt(index).proximityUUID,
                style: const TextStyle(fontSize: 15.0),
              ),
              subtitle: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Text(
                      'Major: ${_beacons.elementAt(index).major}\nMinor: ${_beacons.elementAt(index).minor}',
                      style: const TextStyle(fontSize: 13.0),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Text(
                      'Accuracy: ${_beacons.elementAt(index).accuracy}m\nRSSI: ${_beacons.elementAt(index).rssi}',
                      style: const TextStyle(fontSize: 13.0),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        double x = (_beacons.elementAt(index).major) / 1000;
                        double y = (_beacons.elementAt(index).minor) / 100;
                        Get.to(() => const LocationTracking(), arguments: [
                          {'Latitude': x},
                          {'Longitude': y},
                          {'ProximityUUID': _beacons.elementAt(index).proximityUUID},
                        ]);
                      }, child: const Text("See Location"))
                ],
              ),
            ),
          );
        },
      )
    );
  }
}