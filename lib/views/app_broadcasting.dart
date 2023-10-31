import 'package:flutter/material.dart';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../controller/requirement_state_controller.dart';

class TabBroadcasting extends StatefulWidget {
  const TabBroadcasting({super.key});

  @override
  TabBroadcastingState createState() => TabBroadcastingState();
}

class TabBroadcastingState extends State<TabBroadcasting> {
  final controller = Get.find<RequirementStateController>();
  final clearFocus = FocusNode();
  bool broadcasting = false;

  int lat = 0;
  int long = 0;
  late Location location;
  late LatLng currentPosition;
  late Marker marker;
  final regexUUID = RegExp(r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}');
  final uuidController = TextEditingController(text: 'CB10023F-A318-3394-4199-A8730C7C1AEC');
  final majorController = TextEditingController();
  final minorController = TextEditingController();

  bool get broadcastReady =>
      controller.authorizationStatusOk == true &&
          controller.locationServiceEnabled == true &&
          controller.bluetoothEnabled == true;

  @override
  void initState() {
    super.initState();
    location = Location();
    _getCurrentLocation();
    controller.startBroadcastStream.listen((flag) {
      if (flag == true) {
        initBroadcastBeacon();
      }
    });
  }

  initBroadcastBeacon() async {
    await flutterBeacon.initializeScanning;
  }

  @override
  void dispose() {
    clearFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(clearFocus),
        child: Obx(
              () => broadcastReady != true
              ? const Center(child: Text('Please wait... \nEnable Bluetooth and Location',))
              : Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  uuidField,
                  majorField,
                  minorField,
                  const SizedBox(height: 16),
                  buttonBroadcast,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get uuidField {
    return TextFormField(
      readOnly: broadcasting,
      controller: uuidController,
      decoration: const InputDecoration(
        labelText: 'Proximity UUID',
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Proximity UUID required';
        }

        if (!regexUUID.hasMatch(val)) {
          return 'Invalid Proxmity UUID format';
        }
        return null;
      },
    );
  }

  Widget get majorField {
    return TextFormField(
      readOnly: broadcasting,
      controller: majorController,
      decoration: const InputDecoration(
        labelText: 'Major',
      ),
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Major required';
        }

        try {
          int major = lat;
          if (major < 0 || major > 65535) {
            return 'Major must be number between 0 and 65535';
          }
        } on FormatException {
          return 'Major must be number';
        }

        return null;
      },
    );
  }

  Widget get minorField {
    return TextFormField(
      readOnly: broadcasting,
      controller: minorController,
      decoration: const InputDecoration(
        labelText: 'Minor',
      ),
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Minor required';
        }

        try {
          int minor = long;
          if (minor < 0 || minor > 65535) {
            return 'Minor must be number between 0 and 65535';
          }
        } on FormatException {
          return 'Minor must be number';
        }

        return null;
      },
    );
  }

  Widget get buttonBroadcast {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: broadcasting ? Colors.red : Theme.of(context).primaryColor,
      minimumSize: const Size(88, 36),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );

    return ElevatedButton(
      style: raisedButtonStyle,
      onPressed: () async {
        setState(() {
          _getCurrentLocation();
          majorController.text = lat.toString();
          minorController.text = long.toString();
        });
        if (broadcasting) {
          await flutterBeacon.stopBroadcast();
        } else {
          await flutterBeacon.startBroadcast(BeaconBroadcast(
            proximityUUID: uuidController.text,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
            major: int.tryParse(majorController.text) ?? 0,
            minor: int.tryParse(minorController.text) ?? 0,
          ));
          debugPrint("Major $majorController");
          debugPrint("Minor $minorController");
        }
        final isBroadcasting = await flutterBeacon.isBroadcasting();

        if (mounted) {
          setState(() {
            broadcasting = isBroadcasting;
          });
        }
      },
      child: Text('Broadcast${broadcasting ? 'ing' : ''}'),
    );
  }
  void _getCurrentLocation() async {

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
    LocationData locationData = await location.getLocation();
    setState(() {
      String l = locationData.latitude!.toString();
      List<String> z = l.split(".");
      String l1 = z[0];
      int v = l1.length;
      debugPrint(l);
      debugPrint("Before decimal latitude $v");
      if(v == 2){
        lat = int.parse(locationData.latitude!.toStringAsFixed(3).replaceAll(".", ""));
      } else if(v == 1){
        lat = int.parse(locationData.latitude!.toStringAsFixed(4).replaceAll(".", ""));
      } else{
        debugPrint("Not valid location");
      }
      String lo = locationData.longitude!.toString();
      List<String> z1 = lo.split(".");
      String l2 = z1[0];
      int v1 = l2.length;
      debugPrint(lo);
      debugPrint("Before decimal longitude $v1");

      if(v1 == 2){
        long = int.parse(locationData.longitude!.toStringAsFixed(2).replaceAll(".", ""));
      } else if(v1 == 3){
        long = int.parse(locationData.longitude!.toStringAsFixed(1).replaceAll(".", ""));
      }else if(v1 == 1){
        long = int.parse(locationData.longitude!.toStringAsFixed(3).replaceAll(".", ""));
      }
        else {
        debugPrint("Not Valid location");
      }
    });
        currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
  }
}