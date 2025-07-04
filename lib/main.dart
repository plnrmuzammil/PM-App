import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:pm_app/Auth/login.dart';
import 'package:pm_app/firebase_options.dart';
import 'package:pm_app/mainPage.dart';
import 'package:pm_app/model/house_model.dart';
import 'package:pm_app/model/listing_range_model.dart';
import 'package:pm_app/model/stepper_state_model.dart';
import 'package:pm_app/userInformationFormAfterOTP.dart';

late ListingRangeModel listingModel;
late HouseModel houseModel;
late StepperStateModel stepperStateModel;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<dynamic>('userData');

  houseModel = HouseModel()..resetValue();
  listingModel = ListingRangeModel()..reset();
  stepperStateModel = StepperStateModel()..reset();

  runApp(const GetMaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), checkLog);
  }

  Future<bool> isUserDataExist() async {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;

    if (uid == null) return false;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    return userDoc.exists;
  }

  Future<void> checkLog() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      if (await isUserDataExist()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SafeArea(child: Scaffold(body: mainPage()))),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SafeArea(child: Scaffold(body: UserFormAfterOTP(isFromLoginRoute: true))),
          ),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SafeArea(child: Scaffold(body: login())),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 25),
                  child: Text(
                    "PM App",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Times New Roman",
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                    ),
                  ),
                ),
                const Image(
                  image: AssetImage('assets/images/pm.png'),
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Property Management \n App",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Times New Roman",
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const SpinKitFadingCube(
                  color: Colors.green,
                  size: 50.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
