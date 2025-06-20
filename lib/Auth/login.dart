import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/Material.dart';
import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import "package:google_fonts/google_fonts.dart";
import 'package:pm_app/widgets/stylishCustomButton.dart';

import 'package:url_launcher/url_launcher.dart';

import '../mobileEntry.dart';

TextEditingController email = TextEditingController();
TextEditingController password = TextEditingController();

var obscured = true;

class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  loginState createState() => loginState();
}

class loginState extends State<login> {
  final _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  setUPNotifications() {
    // if (Platform.isIOS) {
    //   var iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
    //     // save the token  OR subscribe to a topic here
    //   });

      _fcm.requestPermission();
    }



    // ...
    //
    // _fcm.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //     showDialog(
    //       context: context,
    //       builder: (context) => AlertDialog(
    //         content: ListTile(
    //           title: Text(message['notification']['title']),
    //           subtitle: Text(message['notification']['body']),
    //         ),
    //         actions: <Widget>[
    //           FlatButton(
    //             child: Text('Ok'),
    //             onPressed: () => Navigator.of(context).pop(),
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //     // TODO optional
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //     // TODO optional
    //   },
    // );

    // ...
    // dialog popup notification show after listing has added

// me *********************************************
    // _fcm.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //     showDialog(
    //       context: context,
    //       builder: (context) => AlertDialog(
    //         content: ListTile(
    //           title: Text(message['notification']['title']),
    //           subtitle: Text(message['notification']['body']),
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             child: Text('Ok'),
    //             onPressed: () => Navigator.of(context).pop(),
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //     // TODO optional
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //     // TODO optional
    //   },
    // );
  // }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
             const SizedBox(
                height: 40,
              ),
              // login or sign up button
              Container(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: <Widget>[
                   TextButton(
                      onPressed: () {},
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Login",
                            style: GoogleFonts.getFont('Montserrat',
                                fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                        const  SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 2,
                            width: 50,
                            child: Container(
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                    // FlatButton(
                    //   onPressed:(){
                    //     Navigator.pushReplacement(context,
                    //     MaterialPageRoute(builder: (context){
                    //       return SafeArea(
                    //         child: Scaffold(
                    //             body: signup()
                    //         ),
                    //       );
                    //     })
                    //     );
                    //   },
                    //   child: Column(
                    //     children: <Widget>[
                    //       Text(
                    //         "Sign Up",
                    //         style: GoogleFonts.getFont('Montserrat',fontWeight: FontWeight.w500,fontSize: 20),
                    //       ),
                    //       SizedBox(height: 10,),
                    //       SizedBox(height: 0,width: 50,child: Container(color: Colors.black,),)
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ), //BUTTONS
             const SizedBox(
                height: 20,
              ),
              Column(
                children: <Widget>[
                  const Image(
                    fit: BoxFit.cover,
                    image:AssetImage(
                      'assets/images/pm.png',
                    ),
                    width: 150,
                  ),
                const  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child:const Center(
                      child: Text(
                        "Property Management App",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Times New Roman",
                            fontWeight: FontWeight.w700,
                            fontSize: 25),
                      ),
                    ),
                  ),


                 const SizedBox(height: 50),

                  Container(
                    //width: 300,
                    padding: const EdgeInsets.only(left: 30, top: 10, right: 30),
                    child: StylishCustomButton(
                      isCenter: true,
                      //isSmallerSize: true,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return mobileEntry();

                        }));
                      },
                      // elevation: 5,
                      // padding: EdgeInsets.only(
                      //     left: 10, top: 10, bottom: 10, right: 15),
                      text: "Sign In with Phone Number",

                    ),
                  ),
                  // Container(
                  //   padding: EdgeInsets.only(left:40),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: <Widget>[
                  //       SignInButton(
                  //         Buttons.Google,
                  //         text: "Sign In with Google",
                  //         onPressed: ()async{
                  //
                  //           await GoogleSignIn().signOut();
                  //           print("signing in with google");
                  //           FirebaseApp defaultApp = await Firebase.initializeApp();
                  //           FirebaseAuth auth=FirebaseAuth.instance;
                  //           UserCredential user= await signInWithGoogle();
                  //
                  //           await setUserDetails(
                  //               user.user.uid,
                  //               name: user.user.displayName,
                  //               email: user.user.email,
                  //               profile: user.user.photoURL,
                  //               phone: user.user.phoneNumber
                  //           );
                  //
                  //           print("signed in");
                  //           Navigator.push(context, MaterialPageRoute(builder: (context){
                  //             return mainPage();
                  //           }));
                  //         },
                  //         padding: EdgeInsets.all(5),
                  //         elevation: 2,
                  //       ),
                  //     ],
                  //   ),
                  // ), //GOOGLE
                  // Container(
                  //   padding: EdgeInsets.only(left:40),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: <Widget>[
                  //       SignInButton(
                  //         Buttons.Facebook,
                  //         text: "Sign In with Facebook",
                  //         onPressed: ()async{
                  //           print("THIS WILL SIGN up with facebook");
                  //           await _login();
                  //         },
                  //         padding: EdgeInsets.only(left: 5,right: 5,top: 12,bottom: 12),
                  //         elevation: 5,
                  //       ),
                  //     ],
                  //   ),
                  // ),//FA
                  // CEBOOK
                  SizedBox(height: 20),

                  Text(
                    "مدد کے لیے کال کریں",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.getFont('Montserrat',
                        fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  TextButton(
                    onPressed: () {
                      launch("tel:+92318-8601066");
                      //UrlLauncher.launch("tel://<phone_number>");
                    },
                    child: Text(
                      "+92318-8601066",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont('Montserrat',
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
