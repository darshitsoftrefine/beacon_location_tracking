import 'package:beacon_project/beacons/beacon_notification.dart';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  final _beacons = <Beacon>[];
  final controller = Get.find<RequirementStateController>();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  showNotification() {
    if (_beacons.isEmpty) {
      return;
    }

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      "ScheduleNotification001",
      "Notify Me",
      importance: Importance.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      macOS: null,
      linux: null,
    );



    flutterLocalNotificationsPlugin.show(01, "A beacon is identified", "Please click to show more", notificationDetails);
  }

  void stopNotifications() async {
    flutterLocalNotificationsPlugin.cancel(01);
  }

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
      print(
          'RETURNED, authorizationStatusOk=${controller.authorizationStatusOk}, '
              'locationServiceEnabled=${controller.locationServiceEnabled}, '
              'bluetoothEnabled=${controller.bluetoothEnabled}');
      return;
    }
    //await BeaconsPlugin.runInBackground(true);
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

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
          if (mounted) {
            setState(() {
              _regionBeacons[result.region] = result.beacons;
              _regionBeacons.values.forEach((list) {
                _beacons.addAll(list);
              });
              _beacons.sort(_compareParameters);
            });
          }
        });
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
  }

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }

  @override
  void dispose() {
    _streamRanging?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _beacons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: _beacons.map(
                (beacon) {
              return VisibilityDetector(
                key: Key('${_beacons.length}'),
                onVisibilityChanged: (VisibilityInfo info) {
                  if(info.visibleFraction > 0 ){
                    showNotification();
                  }
                },
                child: ListTile(
                  title: Text(
                    beacon.proximityUUID,
                    style: const TextStyle(fontSize: 15.0),
                  ),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Text(
                          'Major: ${beacon.major}\nMinor: ${beacon.minor}',
                          style: const TextStyle(fontSize: 13.0),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Text(
                          'Accuracy: ${beacon.accuracy}m\nRSSI: ${beacon.rssi}',
                          style: const TextStyle(fontSize: 13.0),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () async {

                            double x = (beacon.major) / 1000;
                              double y = (beacon.minor) / 100;
                           Get.to(const LocationTracking(), arguments: [
                             {'Latitude': x},
                             {'Longitude': y}
                           ]);
                          }, child: const Text("See Location"))
                    ],
                  ),
                ),
              );
            },
          ),
        ).toList(),
      ),
    );
  }
}