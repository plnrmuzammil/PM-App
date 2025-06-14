import "dart:io";

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:reale/Auth/login.dart';
import 'package:reale/mainPage.dart';
import 'package:reale/newCode/Functions.dart';

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
  const profile({super.key});

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
    var userData = user.data();
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

      FirebaseStorage storage = FirebaseStorage.instance;

      String? fileName = _image?.path;

      // me ++++++++++++++++++++++++++++++++++
      // StorageReference firebaseStorageRef =
      //     FirebaseStorage.instance.ref().child('uploads/$fileName');
      // StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
      // StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      // taskSnapshot.ref.getDownloadURL().then(
      //   (value) async {
      //     await sendImage(value);
      //   },
      // );
    } else {
      print('No image selected.');
    }
  }

  initializeValues() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var tempUser = auth.currentUser;

    setState(() {
      currentUser = tempUser;
    });

    var userCol = await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser!.uid)
        .get();
    var userData = userCol.data();

    var nameTemp = tempUser!.displayName == null ? "" : tempUser.displayName;
    var tempIdCard = userData!["idCard"] == null ? "" : userData["idCard"];
    var tempBusinessName =
        userData["businessName"] ?? "";
    var tempRegistrationNumber = userData["registrationNumber"] ?? "";
    var tempBusinessOwner =
        userData["businessOwner"] ?? "";
    var locationa = userData["loc"] ?? "";

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
    var photo = currentUser!.photoURL ?? "none";

    return SafeArea(
      child: StreamBuilder<dynamic>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(auth.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  // Text(
                  //   "Change Your Details",
                  //   style: GoogleFonts.getFont('Montserrat',
                  //       fontWeight: FontWeight.w500, fontSize: 20),
                  // ),

                  Center(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(photo),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('dummy name here'),
                  const Text('dummy phone number here'),
                  const Divider(color: Colors.blue),
                  // list tile start
                  // profile list tile
                  ListTile(
                    leading: const Icon(Icons.person_add_alt_1_outlined),
                    title: const Text('Profile Setting'),
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
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () async {
                      print('logout text tapped');
                      bool? result = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Do you want to Logout ?'),
                            actions: [
                              MaterialButton(
                                onPressed: () {
                                  print('Log out user');
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('No'),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  print('Login user');
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Yes'),
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
                          return const SafeArea(child: Scaffold(body: login()));
                        }));
                      }
                    },
                  ),
                  // list tile end
                  // get image button
                  /*Container(
                    width: 60,
                    //alignment: Alignment.center,
                    child: StylishCustomButton.icon(
                      onPressed: () async {
                        await getImage();
                      },
                      icon: Icons.add_a_photo,
                    ),
                  ), */
                  /*
                  // name textfield
                  Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: profileName,
                        style: GoogleFonts.getFont('Montserrat',
                            fontWeight: FontWeight.w400, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Name",
                          hintStyle: GoogleFonts.getFont('Montserrat',
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                      )),
                  // Id Card Number
                  Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: idCard,
                        style: GoogleFonts.getFont('Montserrat',
                            fontWeight: FontWeight.w400, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Id Card Number",
                          hintStyle: GoogleFonts.getFont('Montserrat',
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                      )),
                  // Business Name
                  Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: businessName,
                        style: GoogleFonts.getFont('Montserrat',
                            fontWeight: FontWeight.w400, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Business Name",
                          hintStyle: GoogleFonts.getFont('Montserrat',
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                      )),
                  // Registration Number
                  Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: registrationNumber,
                        style: GoogleFonts.getFont('Montserrat',
                            fontWeight: FontWeight.w400, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Registration Number",
                          hintStyle: GoogleFonts.getFont('Montserrat',
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                      )),
                  // Business Owner Name
                  Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: businessOwner,
                        style: GoogleFonts.getFont('Montserrat',
                            fontWeight: FontWeight.w400, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Business Owner Name",
                          hintStyle: GoogleFonts.getFont('Montserrat',
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                      )),
                  // Current Location
                  Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: loc,
                        style: GoogleFonts.getFont('Montserrat',
                            fontWeight: FontWeight.w400, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Current Location",
                          hintStyle: GoogleFonts.getFont('Montserrat',
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                      )),
                  // update current location button
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.white,
                          onPressed: () async {
                            FirebaseAuth _auth = FirebaseAuth.instance;
                            await _auth.currentUser.updateProfile(
                                displayName: profileName.value.text);
                            CollectionReference users =
                                await FirebaseFirestore.instance
                                    .collection('users');
                            DocumentSnapshot ourUser =
                                await users.doc(currentUser.uid).get();
                            var userData = ourUser.data();
                            userData["name"] = profileName.value.text;
                            userData["idCard"] = idCard.value.text;
                            userData["businessName"] =
                                businessName.value.text;
                            userData["registrationNumber"] =
                                registrationNumber.value.text;
                            userData["businessOwner"] =
                                businessOwner.value.text;

                            Position position;
                            try {
                              print("FETCHING");
                              LocationPermission permission =
                                  await requestPermission();
                              position = await getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high);
                            } catch (e) {
                              print(e);
                            }

                            print("FETCHED");
                            userData["loc"] = position.toString();
                            users.doc(currentUser.uid).set(userData);
                          },
                          elevation: 0,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.pinkAccent,
                                  border: Border.all(color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              padding: EdgeInsets.all(25),
                              child: Text(
                                "Update Current Location",
                                style: TextStyle(color: Colors.white),
                              )),
                        )
                      ],
                    ),
                  ),
                  // forward icon button
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.white,
                          onPressed: () async {
                            FirebaseAuth _auth = FirebaseAuth.instance;
                            await _auth.currentUser.updateProfile(
                                displayName: profileName.value.text);
                            CollectionReference users =
                                await FirebaseFirestore.instance
                                    .collection('users');
                            DocumentSnapshot ourUser =
                                await users.doc(currentUser.uid).get();
                            var userData = ourUser.data();
                            userData["name"] = profileName.value.text;
                            userData["idCard"] = idCard.value.text;
                            userData["businessName"] =
                                businessName.value.text;
                            userData["registrationNumber"] =
                                registrationNumber.value.text;
                            userData["businessOwner"] =
                                businessOwner.value.text;
                            users.doc(currentUser.uid).set(userData);
                          },
                          elevation: 0,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.pinkAccent,
                                  border: Border.all(color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              padding: EdgeInsets.all(25),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              )),
                        )
                      ],
                    ),
                  ),
                  // log out button
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.white,
                          onPressed: () async {
                            FirebaseAuth auth = FirebaseAuth.instance;
                            await removeFCMTok(auth.currentUser.uid);
                            await auth.signOut();

                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return SafeArea(child: Scaffold(body: login()));
                            }));
                          },
                          elevation: 0,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.pinkAccent,
                                  border: Border.all(color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              padding: EdgeInsets.all(25),
                              child: Text(
                                "Log Out",
                                style: TextStyle(color: Colors.white),
                              )),
                        )
                      ],
                    ),
                  ),

                   */
                ],
              ),
            );
          }),
    );
  }
}
