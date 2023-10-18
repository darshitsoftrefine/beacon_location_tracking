import 'package:flutter/material.dart';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final regexUUID = RegExp(
      r'[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}');
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
              ? const Center(child: Text('Please wait...'))
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
      onPrimary: Colors.white,
      primary: broadcasting ? Colors.red : Theme.of(context).primaryColor,
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
          print(lat);
          print(long);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lat = locationData.latitude!.round();
      long = locationData.longitude!.round();
    });
    prefs.setDouble('latitude', locationData.latitude!);
    prefs.setDouble('longitude', locationData.longitude!);
// Set the current position and marker
        currentPosition =
            LatLng(locationData.latitude!, locationData.longitude!);
  }
}