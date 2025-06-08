import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  FirebaseApp defaultApp = await Firebase.initializeApp();
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<dynamic>('userData');
  houseModel = HouseModel();
  houseModel.resetValue();
  print('house model has initialized');

  // listing model: record the value given by user for filter
  listingModel = ListingRangeModel();
  listingModel.reset();
  // creating drop down model
  stepperStateModel = StepperStateModel();
  stepperStateModel.reset();
  runApp(GetMaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isLoading = false;


  Future<bool> isUserDataExist() async {
    _isLoading = true;
    FirebaseAuth auth = FirebaseAuth.instance;

    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser!.uid)
        .get();

    if (!user.exists) {
      setState(() {
        _isLoading = false;
      });
      return false;
    }
    else {
      return true;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //
  //   return MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     home: mainPage(),
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    Future<void> checkLog() async {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user != null) {
        // isUserDataExist().then((bool? isUserDataExist) {
        //_isLoading = false; //
        setState(() {
          _isLoading = false; // variable for this page only
        });
        if (await isUserDataExist() == false) {
          print("user is not here");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
                return SafeArea(
                    child: Scaffold(
                        body: UserFormAfterOTP(
                          isFromLoginRoute: true,
                        )));
                // return SafeArea(child: Scaffold(body: login()));
              }));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
                return SafeArea(child: Scaffold(body: mainPage()));
                print("you are here else 2 ");
                return SafeArea(
                    child: Scaffold()); //replace with above mainpage is setup
              }));
        }
        // });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
              return SafeArea(child: Scaffold(body: login()));
              // return SafeArea(child: Scaffold(body: mainPage()));
              print("you are here else 3 ");
            }));
      }
    }

    Timer(Duration(seconds: 5), () {
      checkLog();
    });
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

              Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 25),
              child: SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width - 20,
                child: const Center(
                  child: Text(
                    "PM App",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Times New Roman",
                        fontWeight: FontWeight.w700,
                        fontSize: 25),
                  ),
                ),
              ),
            ),
            const Image(
              fit: BoxFit.cover,
              image: AssetImage(
                'assets/images/pm.png',
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(right: 15, left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width - 40,
                    child: const Center(
                      child: Text(
                        "Property Management \n App",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Times New Roman",
                            fontWeight: FontWeight.w700,
                            fontSize: 25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SpinKitFadingCube(
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.greenAccent : Colors.green,
                  ),
                );
              },
            ),
            ],
          )),
    ),)
    );
  }


}
