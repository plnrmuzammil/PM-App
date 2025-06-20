import "dart:io";

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:pm_app/Auth/login.dart';
import 'package:pm_app/mainPage.dart';
import 'package:pm_app/newCode/Functions.dart';

import 'userInformationFormAfterOTP.dart';

File? _image;
final picker = ImagePicker();

TextEditingController profileName = TextEditingController();
TextEditingController email = TextEditingController();
TextEditingController phone = TextEditingController();
TextEditingController officeAddress = TextEditingController();
TextEditingController businessName = TextEditingController();
TextEditingController businessOwner = TextEditingController();
TextEditingController idCard = TextEditingController();
TextEditingController idCardBackPic = TextEditingController();
TextEditingController idCardFrontPic = TextEditingController();
TextEditingController registrationDocumentBackPic = TextEditingController();
TextEditingController registrationDocumentFrontPic = TextEditingController();
TextEditingController registrationNumber = TextEditingController();
TextEditingController loc = TextEditingController();

class profile extends StatefulWidget {
  @override
  _profileState createState() => _profileState();
}

class _profileState extends State<profile> {
  // imp method
  sendImage(link) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    // get the user document data
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser!.uid)
        .get();
    var userData = await user.data();
    (userData as Map<String, dynamic>)["profile"] = link.toString();

    // updating the user profile data
    await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser!.uid)
        .set(userData);
    auth.currentUser!.updateProfile(
        photoURL: link.toString(), displayName: auth.currentUser!.displayName);
  }

  // image related function
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);

      FirebaseStorage _storage = FirebaseStorage.instance;

      String? fileName = _image?.path;


    } else {
      print('No image selected.');
    }
  }

  initializeValues() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    var tempUser = await _auth.currentUser;

    setState(() {
      currentUser = tempUser;
    });

    var userCol = await FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .get();
    var userData = await userCol.data();

    var nameTemp = tempUser!.displayName == null ? "" : tempUser.displayName;
    var tempIdCard = userData!["idCard"] == null ? "" : userData["idCard"];
    var tempBusinessName =
        userData["businessName"] == null ? "" : userData["businessName"];
    var tempRegistrationNumber = userData["registrationNumber"] == null
        ? ""
        : userData["registrationNumber"];
    var tempBusinessOwner =
        userData["businessOwner"] == null ? "" : userData["businessOwner"];
    var locationa = userData["loc"] == null ? "" : userData["loc"];

    profileName.value = TextEditingValue(text: nameTemp!);
    idCard.value = TextEditingValue(text: tempIdCard);
    businessName.value = TextEditingValue(text: tempBusinessName);
    registrationNumber.value = TextEditingValue(text: tempRegistrationNumber);
    businessOwner.value = TextEditingValue(text: tempBusinessOwner);
    loc.value = TextEditingValue(text: locationa);
  }

  @override
  void initState() {
    initializeValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    var photo = currentUser!.photoURL == null ? "none" : currentUser!.photoURL;

    return SafeArea(
      child: StreamBuilder<dynamic>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc("${auth.currentUser!.uid}")
              .snapshots(),
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),


                  Center(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(photo!),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('dummy name here'),
                  Text('dummy phone number here'),
                  Divider(color: Colors.blue),
                  // list tile start
                  // profile list tile
                  ListTile(
                    leading: Icon(Icons.person_add_alt_1_outlined),
                    title: Text('Profile Setting'),
                    onTap: () {
                      // go to user info screen
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return UserFormAfterOTP(
                          isFromLoginRoute: false,
                        );
                        // return mainPage();
                      }));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () async {
                      print('logout text tapped');
                      bool? result = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Logout'),
                            content: Text('Do you want to Logout ?'),
                            actions: [
                              MaterialButton(
                                onPressed: () {
                                  print('Log out user');
                                  Navigator.of(context).pop(false);
                                },
                                child: Text('No'),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  print('Login user');
                                  Navigator.of(context).pop(true);
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                      // if true the logout otherwise stay same
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
            );
          }),
    );
  }
}
