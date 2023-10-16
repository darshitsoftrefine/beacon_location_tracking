import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
class BeaconsScan extends StatefulWidget {
  const BeaconsScan({super.key});

  @override
  State<BeaconsScan> createState() => _BeaconsScanState();
}

class _BeaconsScanState extends State<BeaconsScan> {

  List detectedBeacons = [];

  @override
  void initState(){
    debugPrint("Init Called");
    BeaconsPlugin.addRegion("myBeacon", "01022022-f88f-0000-00ae-9605fd9bb620");
    startScanning();
    super.initState();
    // scanResults();
  }

  startScanning() async {
    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if (call.method == 'scannerReady') {
          await BeaconsPlugin.startMonitoring();
          print("Scanning");
        }
      });
    } else if (Platform.isIOS) {
      await BeaconsPlugin.startMonitoring();
    }
  }

  // Future<void> ranging() async {
  //   // if you need to monitor also major and minor use the original version and not this fork
  //   BeaconsPlugin.addRegion("myBeacon", "01022022-f88f-0000-00ae-9605fd9bb620").then((result) {
  //     print("hi range");
  //   });
  //
  //   //Send 'true' to run in background [OPTIONAL]
  //   await BeaconsPlugin.runInBackground(true);
  //
  //   //IMPORTANT: Start monitoring once scanner is setup & ready (only for Android)
  //   if (Platform.isAndroid) {
  //     BeaconsPlugin.channel.setMethodCallHandler((call) async {
  //       if (call.method == 'scannerReady') {
  //         await BeaconsPlugin.startMonitoring();
  //       }
  //     });
  //   } else if (Platform.isIOS) {
  //     await BeaconsPlugin.startMonitoring();
  //   }
  // }

  void scanResults(){
    final StreamController<String> beaconEventsController = StreamController<String>.broadcast();
    BeaconsPlugin.listenToBeacons(beaconEventsController);
    print("Hear before listen");
    beaconEventsController.stream.listen((data) {
          if (data.isNotEmpty) {
            setState(() {
              var beaconResult = data;
              detectedBeacons.add(data);
              print("Hi $beaconResult");
            });

            print("Beacons DataReceived: $data");
          }
        },
        onDone: () {
      print("Done");
        },
        onError: (error) {
          print("Error: $error");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ElevatedButton(onPressed: (){
                // ranging();
              }, child: Text("range")),
              SizedBox(height: 50,),
              ElevatedButton(onPressed: (){
                scanResults();
              }, child: Text("Scan Results")),

              ListView.builder(
                shrinkWrap: true,
                itemCount: detectedBeacons.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(detectedBeacons[index]),
                  );
                },

              )
            ],
          ),
        ),
      ),
    );
  }
}
