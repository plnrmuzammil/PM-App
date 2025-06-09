import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reale/Auth/login.dart';
import 'package:reale/mainPage.dart';
import 'package:reale/model/house_model.dart';
import 'package:reale/model/listing_range_model.dart';
import 'package:reale/model/stepper_state_model.dart';
import 'package:reale/userInformationFormAfterOTP.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

late ListingRangeModel listingModel;
late HouseModel houseModel;
late StepperStateModel stepperStateModel;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<dynamic>('userData');
  
  houseModel = HouseModel()..resetValue();
  listingModel = ListingRangeModel()..reset();
  stepperStateModel = StepperStateModel()..reset();

  runApp(const GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      checkLog();
    });
  }

  Future<void> checkLog() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SafeArea(
              child: Scaffold(body: UserFormAfterOTP(isFromLoginRoute: true)),
            ),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SafeArea(child: Scaffold(body: MainPage())),
          ),
        );
      }
    } else {
      setState(() => _isLoading = false);
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
                        padding: EdgeInsets.fromLTRB(8.0, 8, 8, 25),
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
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/pm.png'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Property Management \n App",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Times New Roman",
                          fontWeight: FontWeight.w700,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SpinKitFadingCube(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? Colors.greenAccent
                                  : Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
