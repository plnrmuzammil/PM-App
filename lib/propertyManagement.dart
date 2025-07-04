import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:hive/hive.dart';
import 'package:pm_app/dealers.dart';
import 'package:pm_app/sold.dart';
import 'package:pm_app/userInformationFormAfterOTP.dart';
import 'package:pm_app/widgets/custom_text_widget.dart';
import 'package:pm_app/widgets/stylishCustomButton.dart';

import 'Auth/login.dart';
import 'EntryDetails/selectStepper.dart';
import 'main.dart';
import 'mainPage.dart';
import 'newCode/Functions.dart';

// ✅ Full screen image preview widget
class FullImageView extends StatelessWidget {
  final String imageUrl;

  const FullImageView({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Image Preview", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class propertyManagement extends StatefulWidget {
  @override
  _propertyManagementState createState() => _propertyManagementState();
}

class _propertyManagementState extends State<propertyManagement> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  String userName = "";
  String phoneNumber = "";
  String imgUrl = "";

  Future<void> getUserData() async {
    await db.collection("users").doc(auth.currentUser!.uid).get().then((value) {
      final userData = value.data();
      setState(() {
        userName = userData!['name'];
        phoneNumber = userData['phone'];
        imgUrl = userData['profile'];
      });
    }).onError((error, stackTrace) {});
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    var photo = currentUser?.photoURL ?? "none";

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: imgUrl.isNotEmpty
                            ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullImageView(imageUrl: imgUrl),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: NetworkImage(imgUrl),
                          ),
                        )
                            : const CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 10),
                      CustomTextWidget(text1: 'Name: ', text2: userName),
                      CustomTextWidget(text1: 'Phone Number: ', text2: phoneNumber),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StylishCustomButton(
                          text: "Entries",
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => StepperForm()));
                          },
                        ),
                        const SizedBox(height: 12),
                        StylishCustomButton(
                          text: "DEALERS",
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => dealers()));
                          },
                        ),
                        const SizedBox(height: 12),
                        StylishCustomButton(
                          text: "SOLD/UNSOLD",
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => sold(name: userName)));
                          },
                        ),
                        const SizedBox(height: 12),
                        StylishCustomButton(
                          text: "Profile",
                          onPressed: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return UserFormAfterOTP(isFromLoginRoute: false);
                                }));
                          },
                        ),
                        const SizedBox(height: 12),
                        StylishCustomButton(
                          text: "Logout",
                          onPressed: () async {
                            bool? result = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text('Do you want to Logout?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text('No'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (result!) {
                              FirebaseAuth auth = FirebaseAuth.instance;
                              await removeFCMTok(auth.currentUser!.uid);
                              await auth.signOut();

                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                    return SafeArea(child: Scaffold(body: login()));
                                  }));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
