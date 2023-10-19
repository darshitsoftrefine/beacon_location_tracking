import 'package:beacon_project/beacons/home_screen.dart';
import 'package:beacon_project/maps/location_tracking.dart';
import 'package:beacon_project/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'beacons/beacon_library.dart';
import 'beacons/beacons_scan.dart';
import 'controller/requirement_state_controller.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(RequirementStateController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage()
    );
  }
}
