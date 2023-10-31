
import 'package:beacon_project/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'beacon_notification/beacon_notification.dart';
import 'controller/requirement_state_controller.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  NotifyService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RequirementStateController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage()
    );
  }
}
