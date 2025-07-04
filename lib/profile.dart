import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pm_app/Auth/login.dart';
import 'package:pm_app/mainPage.dart';
import 'package:pm_app/newCode/Functions.dart';

import 'userInformationFormAfterOTP.dart';

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

User? currentUser;

class profile extends StatefulWidget {
  @override
  _profileState createState() => _profileState();
}

class _profileState extends State<profile> {
  File? _image;
  final picker = ImagePicker();

  // Upload and update image link in Firestore and user profile
  Future<void> sendImage(String link) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection("users").doc(uid).get();
    var userData = userSnapshot.data() as Map<String, dynamic>;

    userData["profile"] = link;

    await FirebaseFirestore.instance.collection("users").doc(uid).set(userData);
    await auth.currentUser!.updatePhotoURL(link);
  }

  // Pick image and upload to Firebase Storage
  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = storage.ref().child("user_profiles/$fileName");

      UploadTask uploadTask = ref.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await sendImage(downloadUrl);
      setState(() {}); // Update UI after image change
    } else {
      print('No image selected.');
    }
  }

  // Initialize values from Firebase
  Future<void> initializeValues() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    currentUser = _auth.currentUser;

    if (currentUser == null) return;

    var userCol = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .get();

    var userData = userCol.data() ?? {};

    profileName.text = currentUser!.displayName ?? '';
    idCard.text = userData["idCard"] ?? '';
    businessName.text = userData["businessName"] ?? '';
    registrationNumber.text = userData["registrationNumber"] ?? '';
    businessOwner.text = userData["businessOwner"] ?? '';
    loc.text = userData["loc"] ?? '';
  }

  @override
  void initState() {
    super.initState();
    initializeValues();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? photo = currentUser?.photoURL;

    return SafeArea(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(auth.currentUser?.uid ?? "")
            .snapshots(),
        builder: (context, snapshot) {
          return Container(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                Center(
                  child: GestureDetector(
                    onTap: getImage,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: photo != null
                          ? NetworkImage(photo)
                          : AssetImage("assets/default_profile.png")
                      as ImageProvider,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(profileName.text.isNotEmpty
                    ? profileName.text
                    : "Your Name Here"),
                Text(phone.text.isNotEmpty
                    ? phone.text
                    : "Your Phone Number Here"),
                const Divider(color: Colors.blue),

                // Profile Setting
                ListTile(
                  leading: const Icon(Icons.person_add_alt_1_outlined),
                  title: const Text('Profile Setting'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return UserFormAfterOTP(isFromLoginRoute: false);
                        }));
                  },
                ),

                // Logout
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    bool? result = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Do you want to Logout?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              child: const Text('Yes'),
                            ),
                          ],
                        );
                      },
                    );

                    if (result == true) {
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
        },
      ),
    );
  }
}
