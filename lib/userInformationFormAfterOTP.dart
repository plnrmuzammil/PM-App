
import 'dart:io';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pm_app/chat.dart';
import 'package:pm_app/model/userFormModel.dart';
import 'package:pm_app/widgets/stylishCustomButton.dart';

// import 'package:location/location.dart';

import 'mainPage.dart';

class UserFormAfterOTP extends StatefulWidget {
  static const String routeID = '/UserForm';
  bool isFromLoginRoute;

  UserFormAfterOTP({Key? key, required this.isFromLoginRoute})
      : super(key: key);

  @override
  _UserFormAfterOTPState createState() => _UserFormAfterOTPState();
}

class _UserFormAfterOTPState extends State<UserFormAfterOTP> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserForm? _userModel;
  File? _profileImage;
  File? _idCardFrontImage;
  File? _idCardBackImage;
  File? _registerationDocFrontImage;
  File? _registerationDocBackImage;
  bool pageLoading = false;
  bool profileImageExist = true;
  bool enableOfficeAddress = false;
  bool isCameraSelected = false;
  bool isTextFieldSelected = false;

  bool isFrontImageSelected = false;
  bool isBackImageSelected = false;
  bool isDocumentFrontImageSelected = false;
  bool isDocumentBackImageSelected = false;

  bool showCircleAvatarPic = true;
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance.ref();

  bool _isSubmitting = false;

  // bool viewFromProfileSide = false;

  final TextStyle _lableStyle = TextStyle(fontSize: 12);

  bool loadProfileImage = false;
  int? lines;

  //profile image picker
  Future pickImageFromGallery() async {
    final pickedImage = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;
    setState(() {
      _profileImage = File(pickedImage!.path);
      loadProfileImage = true;
      showCircleAvatarPic = false;
      profileImageExist = false;
      isCameraSelected = true;
    });
  }

  Future pickImageFromCamera() async {
    final pickedImage = await ImagePicker.platform.getImage(
      source: ImageSource.camera,
    );

    if (pickedImage == null) return;

    setState(() {
      _profileImage = File(pickedImage.path);
      loadProfileImage = true;
      showCircleAvatarPic = false;
      profileImageExist = false;
    });
  }

  // id card front image picker
  Future pickIdCardFrontImageFromGallery() async {
    final pickedImage = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;
    setState(() {
      _idCardFrontImage = File(pickedImage!.path);
      isFrontImageSelected = true;
    });
  }

  Future pickIdCardFrontImageFromCamera() async {
    final pickedImage = await ImagePicker.platform.pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage == null) return;
    setState(() {
      _idCardFrontImage = File(pickedImage!.path);
      isFrontImageSelected = true;
    });
  }

  // id card back imag picker
  Future pickIdCardBackImageFromGallery() async {
    final pickedImage = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;
    setState(() {
      _idCardBackImage = File(pickedImage!.path);
      isBackImageSelected = true;
    });
  }

  Future pickIdCardBackImageFromCamera() async {
    final pickedImage = await ImagePicker.platform.pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage == null) return;
    setState(() {
      _idCardBackImage = File(pickedImage!.path);
      isBackImageSelected = true;
    });
  }

  // registeration doc front image picker
  Future pickRegisterationDocFrontImageFromGallery() async {
    final pickedImage = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;
    setState(() {
      _registerationDocFrontImage = File(pickedImage!.path);
      isDocumentFrontImageSelected = true;
    });
  }

  Future pickRegisterationDocFrontImageFromCamera() async {
    final pickedImage = await ImagePicker.platform.pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage == null) return;
    setState(() {
      _registerationDocFrontImage = File(pickedImage!.path);
      isDocumentFrontImageSelected = true;
    });
  }

  // registeration doc back image picker
  Future pickRegisterationDocBackImageFromGallery() async {
    final pickedImage = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;
    setState(() {
      _registerationDocBackImage = File(pickedImage!.path);
      isDocumentBackImageSelected = true;
    });
  }

  Future pickRegisterationDocBackImageFromCamera() async {
    final pickedImage = await ImagePicker.platform.pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage == null) return;
    setState(() {
      _registerationDocBackImage = File(pickedImage!.path);
      isDocumentBackImageSelected = true;
    });
  }

  String updatedName = "";
  String updatedPhone = "";
  String updatedProfileImage = "";
  String updatedBusinessName = "";
  String updatedBusinessOwnerName = "";
  String updatedDistrict = "";
  String updatedOfficeAddress = "";
  String updatedIdCardNumber = "";
  String updatedRegisterationNumber = "";
  Size size = Get.size;

  Future getUserProfileData() async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get();
    if (result.exists) {
      setState(() {
        updatedProfileImage = result['profile'];
        updatedName = result['name'];
        updatedPhone = result['phone'];
        updatedBusinessName = result['businessName'];
        updatedBusinessOwnerName = result['businessOwner'];
        updatedDistrict = result['district'];
        updatedOfficeAddress = result['officeAddress'];
        updatedIdCardNumber = result['idCard'];
        updatedRegisterationNumber = result['registrationNumber'];
      });
    }
    print(updatedName);
  }

  void showToastMessages(String msg) {
    Fluttertoast.showToast(
      msg: msg.toString(),
      fontSize: 18.0,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
      textColor: Colors.white,
      backgroundColor: Colors.black,
    );
  }

  Future updateDataToFirestore() async {
    FocusScope.of(context).unfocus();
    setState(() {
      pageLoading = true;
    });

    if (isCameraSelected & isTextFieldSelected) {
      final profileRef = await storage
          .child("user_profile_image")
          .child("${updatedName.toString()}")
          .child(updatedName.toString() + " profile pic");
      await profileRef.putFile(_profileImage!.absolute);
      String imgUrl = await profileRef.getDownloadURL();

      db
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update({
        'officeAddress': officeAddressController.text.toString(),
        'profile': imgUrl.toString(),
      })
          .then((value) {
        setState(() {
          pageLoading = false;
          enableOfficeAddress = false;
          getUserProfileData();
        });
        showToastMessages('Updated');
      })
          .onError((error, stackTrace) {
        setState(() {
          pageLoading = false;
          enableOfficeAddress = false;
        });
        showToastMessages(error.toString());
      });
      officeAddressController.clear();
      setState(() {
        pageLoading = false;
        enableOfficeAddress = false;
      });
    } else if (isCameraSelected) {
      FocusScope.of(context).unfocus();

      setState(() {
        pageLoading = true;
      });

      final profileRef = await storage
          .child("user_profile_image")
          .child("${updatedName.toString()}")
          .child(updatedName.toString() + " profile pic");
      await profileRef.putFile(_profileImage!.absolute);
      String imgUrl = await profileRef.getDownloadURL();

      db
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update({'profile': imgUrl.toString()})
          .then((value) {
        setState(() {
          pageLoading = false;
          getUserProfileData();
        });
        showToastMessages('Updated');
      })
          .onError((error, stackTrace) {
        setState(() {
          pageLoading = false;
        });
        showToastMessages(error.toString());
      });
      officeAddressController.clear();
      setState(() {
        pageLoading = false;
      });
    } else if (isTextFieldSelected) {
      db
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update({'officeAddress': officeAddressController.text.toString()})
          .then((value) {
        setState(() {
          pageLoading = false;
          enableOfficeAddress = false;
          getUserProfileData();
        });
        showToastMessages('Updated');
      })
          .onError((error, stackTrace) {
        setState(() {
          pageLoading = false;
          enableOfficeAddress = false;
        });
        showToastMessages(error.toString());
      });
      officeAddressController.clear();
      setState(() {
        pageLoading = false;
        enableOfficeAddress = false;
      });
    } else {
      setState(() {
        pageLoading = false;
        enableOfficeAddress = false;
        isCameraSelected = false;
        isTextFieldSelected = false;
      });
      showToastMessages("Nothing updated");
    }
  }

  Future saveData() async {
    FocusScope.of(context).unfocus();

    if (_profileImage != null &&
        _idCardFrontImage != null &&
        _idCardBackImage != null &&
        _registerationDocFrontImage != null &&
        _registerationDocBackImage != null) {
      Get.defaultDialog(
        title: "Creating account",
        content: Column(
          children: [
            const CircularProgressIndicator(color: Colors.black),

            SizedBox(height: size.height * 0.02),

            const Text("Please wait...."),
          ],
        ),
      );

      Reference profileRef = await storage
          .child("user_profile_image")
          .child("${nameController.text}")
          .child(nameController.text + " profile pic");
      UploadTask task1 = profileRef.putFile(_profileImage!.absolute);
      TaskSnapshot taskSnapshot1 = await task1;
      String imgUrl = await taskSnapshot1.ref.getDownloadURL();

      // Second image
      Reference cardFrontImg = await storage
          .child("user_profile_image")
          .child("${nameController.text}")
          .child(nameController.text + " id card front img");
      UploadTask task2 = cardFrontImg.putFile(_idCardFrontImage!.absolute);
      TaskSnapshot taskSnapshot2 = await task2;
      String idCardFrontImgUrl = await taskSnapshot2.ref.getDownloadURL();

      // Third image
      Reference cardBackImg = await storage
          .child("user_profile_image")
          .child("${nameController.text}")
          .child(nameController.text + " id card back img");
      UploadTask task3 = cardBackImg.putFile(_idCardBackImage!.absolute);
      TaskSnapshot taskSnapshot3 = await task3;
      String idCardbackImgUrl = await taskSnapshot3.ref.getDownloadURL();

      // Fourth image
      Reference regDocFrontImg = await storage
          .child("user_profile_image")
          .child("${nameController.text}")
          .child(nameController.text + " reg front img");
      UploadTask task4 = regDocFrontImg.putFile(
        _registerationDocFrontImage!.absolute,
      );
      TaskSnapshot taskSnapshot4 = await task4;
      String regDocFrontImgUrl = await taskSnapshot4.ref.getDownloadURL();

      // Fifth image
      Reference regDocBackImg = await storage
          .child("user_profile_image")
          .child("${nameController.text}")
          .child(nameController.text + " reg back img");
      UploadTask task5 = regDocBackImg.putFile(
        _registerationDocBackImage!.absolute,
      );
      TaskSnapshot taskSnapshot5 = await task5;
      String regDocBackImgUrl = await taskSnapshot5.ref.getDownloadURL();

      await db
          .collection("users")
          .doc(auth.currentUser!.uid)
          .set({
        'name': nameController.text,
        'approved': true,
        'businessName': businessNameController.text.toString(),
        'businessOwner': businessOwnerController.text.toString(),
        'email': "",
        'district': districtController.text.toString(),
        'id': auth.currentUser!.uid.toString(),
        'idCard': idCardNumberController.text.toString(),
        'idCardBackPic': idCardbackImgUrl.toString(),
        'idCardFrontPic': idCardFrontImgUrl.toString(),
        'phone': phoneController.text.toString(),
        'profile': imgUrl.toString(),
        'registrationDocumentBackPic': regDocBackImgUrl.toString(),
        'registrationDocumentFrontPic': regDocFrontImgUrl.toString(),
        'registrationNumber': registerationNumberController.text.toString(),
        'officeAddress': officeAddressController.text.toString(),
      })
          .then((value) {
        Get.back();
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => mainPage()));
      })
          .onError((error, stackTrace) {
        Get.back();
        Get.defaultDialog(
          title: "Network error",
          content: Text(error.toString()),
        );
      });
    } else {
      Get.snackbar("!", "please select all images");
    }
    //First image
  }

  void dialogue(context, int opt) {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
            height: 120.0,
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    if (opt == 1) {
                      pickImageFromCamera();
                      Navigator.pop(context);
                    } else if (opt == 2) {
                      pickIdCardFrontImageFromCamera();
                      Navigator.pop(context);
                    } else if (opt == 3) {
                      pickIdCardBackImageFromCamera();
                      Navigator.pop(context);
                    } else if (opt == 4) {
                      pickRegisterationDocFrontImageFromCamera();
                      Navigator.pop(context);
                    } else {
                      pickRegisterationDocBackImageFromCamera();
                      Navigator.pop(context);
                    }
                  },
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text("Camera"),
                ),
                ListTile(
                  onTap: () {
                    if (opt == 1) {
                      pickImageFromGallery();
                      Navigator.pop(context);
                    } else if (opt == 2) {
                      pickIdCardFrontImageFromGallery();
                      Navigator.pop(context);
                    } else if (opt == 3) {
                      pickIdCardBackImageFromGallery();
                      Navigator.pop(context);
                    } else if (opt == 4) {
                      pickRegisterationDocFrontImageFromGallery();
                      Navigator.pop(context);
                    } else {
                      pickRegisterationDocBackImageFromGallery();
                      Navigator.pop(context);
                    }
                  },
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Gallery"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessOwnerController = TextEditingController();
  TextEditingController officeAddressController = TextEditingController();
  TextEditingController idCardNumberController = TextEditingController();
  TextEditingController registerationNumberController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  DocumentSnapshot? _userDocumentForUpdateOperation;
  bool isServiceEnable = false;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    print('init state...user information from after OTP');

    isUserDataExist().then((bool isUserExist) {
      if (isUserExist) {
        _getProfileImage().then((value) => print('get user profile image'));
        // flow from login page
        if (widget.isFromLoginRoute) {
          print('path from login page');
          // flow from login side

          isUserDataExist().then((value) {
            print('Data found: $value');

            if (value) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return mainPage();
                  },
                ),
              );
            }
          });
        }
        // flow from profile page
        else {
          getUserProfileData();
          setState(() {
            loading = true;
          });
        }
      } else {
        phoneController = TextEditingController(
          text: FirebaseAuth.instance.currentUser!.phoneNumber.toString(),
        );
        setState(() {
          loading = true;
        });
      }
    });
  }

  @override
  void dispose() {
    if (widget.isFromLoginRoute == false) {}
    super.dispose();
  }

  bool _isProfileImageUploading = false;
  String profileImagePath = '';

  Future<void> _getProfileImage() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    setState(() {
      _isProfileImageUploading = true;
    });
    // get the user document data
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser!.uid)
        .get();
    if (user != null) {
      print('user exist on firebase');
      var userData = user;
      setState(() {
        print('user profile image url: ${userData["profile"]}');

        profileImagePath = userData["profile"];
        _isProfileImageUploading = false;
      });
    } else {
      setState(() {
        _isProfileImageUploading = false;
      });
    }
  }

  List<String> _provinceNames = const [
    'Khyber Pakhtunkhwa',
    'Punjab',
    'Sindh',
    'Balochistan',
  ];

  String province = 'Khyber Pakhtunkhwa';
  String district = '';

  @override
  Widget build(BuildContext context) {
    print(
      'current phone number: ${FirebaseAuth.instance.currentUser!.phoneNumber}',
    );
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          return widget.isFromLoginRoute
              ? Future.value(false)
              : Future.value(true);
        },
        child: loading
            ? Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.green,
            title: Text(
              widget.isFromLoginRoute
                  ? 'Enter User Information'
                  : 'Update User Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          body: _isSubmitting
              ? Center(child: CircularProgressIndicator())
              : Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 20,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //avatar for circle
                    GestureDetector(
                      onTap: () {
                        dialogue(context, 1);
                      },
                      child: Center(
                        child: ClipOval(
                          child: Container(
                            color: Colors.lightBlue[300],
                            width: 160,
                            height: 160,
                            child: profileImageExist
                                ? CircleAvatar(
                              backgroundImage:
                              updatedProfileImage == ""
                                  ? NetworkImage("No Image")
                                  : NetworkImage(
                                updatedProfileImage,
                              ),
                            )
                                : CircleAvatar(
                              backgroundImage: FileImage(
                                _profileImage!.absolute,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    // name
                    !widget.isFromLoginRoute
                        ? Text("Name : " + updatedName)
                        : TextFormField(
                      //enabled: widget.isFromLoginRoute ? true : false,
                      //readOnly: widget.isFromLoginRoute ? true : false,
                      controller: nameController,
                      style: TextStyle(fontSize: 16),
                      keyboardType: TextInputType.name,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "* required";
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        //border: InputBorder.none,
                        hintText: 'Name *',
                        hintStyle: TextStyle(fontSize: 16),
                        labelText: 'Name *',
                        labelStyle: _lableStyle,
                      ),
                      // onChanged: (String name) {
                      //   _userModel!.name = name.trim();
                      // },
                    ),

                    SizedBox(height: 20),
                    // phone number
                    !widget.isFromLoginRoute
                        ? Text("Phone Number : " + updatedPhone)
                        : TextFormField(
                      //enabled: widget.isFromLoginRoute ? true : false,
                      //readOnly: true,
                      controller: phoneController,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return '* required';
                        }
                      },
                      style: TextStyle(fontSize: 16),
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        //border: InputBorder.none,
                        hintText: 'Phone Number *',
                        hintStyle: TextStyle(fontSize: 16),
                        labelText: 'Phone Number',
                        labelStyle: _lableStyle,
                      ),
                      onChanged: (String phoneNumber) {
                        _userModel!.phone = phoneNumber
                            .trim();
                      },
                    ),

                    SizedBox(height: 20),

                    // business name
                    !widget.isFromLoginRoute
                        ? Text(
                      "Business Name : " +
                          updatedBusinessName,
                    )
                        : TextFormField(
                      //enabled: widget.isFromLoginRoute ? true : false,
                      controller: businessNameController,
                      style: TextStyle(fontSize: 16),
                      keyboardType: TextInputType.name,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return '* required';
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        //border: InputBorder.none,
                        hintText: 'Business Name *',
                        hintStyle: TextStyle(fontSize: 16),
                        labelText: 'Business Name',
                        labelStyle: _lableStyle,
                      ),
                      onChanged: (String businessName) {
                        _userModel!.businessName =
                            businessName.trim();
                      },
                    ),

                    SizedBox(height: 20),

                    // business owner
                    !widget.isFromLoginRoute
                        ? Text(
                      "Business Owner : " +
                          updatedBusinessOwnerName,
                    )
                        : TextFormField(
                      //enabled: widget.isFromLoginRoute ? true : false,
                      controller: businessOwnerController,
                      style: TextStyle(fontSize: 16),
                      keyboardType: TextInputType.name,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return '* required';
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        //border: InputBorder.none,
                        hintText: 'Business Owner *',
                        hintStyle: TextStyle(fontSize: 16),
                        labelText: 'Business Owner',
                        labelStyle: _lableStyle,
                      ),
                      onChanged: (String businessOwner) {
                        _userModel!.businessOwner =
                            businessOwner;
                      },
                    ),


                    SizedBox(height: 20),

                    // district
                    !widget.isFromLoginRoute
                        ? Text("District : " + updatedDistrict)
                        : TextFormField(
                      //enabled: widget.isFromLoginRoute ? true : false,
                      controller: districtController,
                      style: TextStyle(fontSize: 16),
                      keyboardType: TextInputType.name,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return '* required';
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        hintText: 'district',
                        hintStyle: TextStyle(fontSize: 16),
                        labelText: 'district',
                        labelStyle: _lableStyle,
                      ),
                      onChanged: (String district) {
                        setState(() {});
                        this.district = district;
                        print(
                          'selected district: ${this.district}',
                        );
                      },
                    ),

                    !widget.isFromLoginRoute & !enableOfficeAddress
                        ? Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Office Address : " +
                              updatedOfficeAddress,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              enableOfficeAddress =
                              !enableOfficeAddress;
                              isTextFieldSelected = true;
                            });
                          },
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    )
                        : Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                      ),
                      child: TextFormField(
                        controller: officeAddressController,
                        style: TextStyle(fontSize: 16),
                        keyboardType: TextInputType.name,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return '* required';
                          }
                        },
                        maxLines:
                        officeAddressController
                            .text
                            .length >
                            53
                            ? 5
                            : 1,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                          EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          //border: InputBorder.none,
                          hintText: 'Office Address *',
                          hintStyle: TextStyle(fontSize: 16),
                          labelText: 'Office Address',
                          labelStyle: _lableStyle,
                        ),
                        onChanged: (String officeAddress) {
                          setState(() {});
                          _userModel!.officeAddress =
                              officeAddress;
                        },
                      ),
                    ),

                    // id card number
                    !widget.isFromLoginRoute
                        ? Text("ID Card : " + updatedIdCardNumber)
                        : TextFormField(
                      //enabled: widget.isFromLoginRoute ? true : false,
                      controller: idCardNumberController,
                      style: TextStyle(fontSize: 16),
                      keyboardType: TextInputType.name,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return '* required';
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        //border: InputBorder.none,
                        hintText: 'ID Card Number *',
                        hintStyle: const TextStyle(
                          fontSize: 16,
                        ),
                        labelText: 'ID Card Number',
                        labelStyle: _lableStyle,
                      ),
                      onChanged: (String idCardNumber) {
                        _userModel?.idCardNumber =
                            idCardNumber;
                      },
                    ),

                    if (widget.isFromLoginRoute == true)
                      SizedBox(height: 20),
                    if (widget.isFromLoginRoute == true)
                      const Text(
                        'Choose ID card front image ',
                        style: TextStyle(fontSize: 18),
                      ),
                    if (widget.isFromLoginRoute == true)
                      SizedBox(height: 15),
                    if (widget.isFromLoginRoute == true)
                    // for cardFrontImage
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        height: 80,
                        child: Row(
                          children: [
                            StylishCustomButton(
                              icon: Icons.add,
                              onPressed: () async {
                                dialogue(context, 2);

                              },
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  isFrontImageSelected
                                      ? 'Image has Selected'
                                      : 'Nothing is Selected',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            //SizedBox(width: 10),
                            Checkbox(
                              activeColor: Colors.green,
                              value: isFrontImageSelected,
                              onChanged: (value) {},
                            ),
                            //SizedBox(width: 10),
                          ],
                        ),
                      ),
                    // ------------------------
                    if (widget.isFromLoginRoute == true)
                      SizedBox(height: 20),
                    if (widget.isFromLoginRoute == true)
                      Text(
                        'Choose ID card back image ',
                        style: TextStyle(fontSize: 18),
                      ),
                    if (widget.isFromLoginRoute == true)
                      SizedBox(height: 15),
                    if (widget.isFromLoginRoute == true)
                    // cardBackImage
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        height: 80,
                        child: Row(
                          children: [
                            StylishCustomButton(
                              icon: Icons.add,
                              onPressed: () async {
                                dialogue(context, 3);
                              },
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  isBackImageSelected
                                      ? 'Image has Selected'
                                      : 'Nothing is Selected',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            Checkbox(
                              activeColor: Colors.green,
                              value: isBackImageSelected,
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 15),

                    // textfield for registration number
                    !widget.isFromLoginRoute
                        ? Text(
                      "Registeration Number : " +
                          updatedRegisterationNumber,
                    )
                        : TextFormField(
                      //enabled: widget.isFromLoginRoute ? true : false,
                      //enabled: false,
                      controller:
                      registerationNumberController,
                      style: TextStyle(fontSize: 16),
                      keyboardType: TextInputType.name,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return '* required';
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        //border: InputBorder.none,
                        hintText:
                        'Registration Number(Excise and Taxation number)',
                        hintStyle: TextStyle(fontSize: 16),
                        labelText: 'Registration Number',
                        labelStyle: _lableStyle,
                      ),
                      onChanged: (String registrationNumber) {
                        _userModel!.registrationNumber =
                            registrationNumber;
                      },
                    ),

                    if (widget.isFromLoginRoute == true)
                    // register document
                      SizedBox(height: 30),
                    if (widget.isFromLoginRoute == true)
                      Text(
                        'Choose an Registration document front image ',
                        style: TextStyle(fontSize: 18),
                      ),
                    if (widget.isFromLoginRoute == true)
                      SizedBox(height: 15),
                    if (widget.isFromLoginRoute == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        height: 80,
                        child: Row(
                          children: [
                            // documentFrontImage
                            StylishCustomButton(
                              icon: Icons.add,
                              onPressed: () async {
                                dialogue(context, 4);
                              },
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  isDocumentFrontImageSelected
                                      ? 'Image has Selected'
                                      : 'Nothing is Selected',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            Checkbox(
                              activeColor: Colors.green,
                              value: isDocumentFrontImageSelected,
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                      ),
                    // ------------------------
                    SizedBox(height: 20),

                    if (widget.isFromLoginRoute == true)
                      Text(
                        'Choose an Registration document back image ',
                        style: TextStyle(fontSize: 18),
                      ),
                    if (widget.isFromLoginRoute == true)
                      SizedBox(height: 15),
                    if (widget.isFromLoginRoute == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        height: 80,
                        child: Row(
                          children: [
                            // documentBackImage
                            StylishCustomButton(
                              icon: Icons.add,
                              onPressed: () async {
                                dialogue(context, 5);
                              },
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Text(
                                  isDocumentBackImageSelected
                                      ? 'Image has Selected'
                                      : 'Nothing is Selected',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            Checkbox(
                              activeColor: Colors.green,
                              value: isDocumentBackImageSelected,
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                      ),
                    // show update button if update operation
                    widget.isFromLoginRoute
                        ? Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: StylishCustomButton(
                        text: 'submit',
                        onPressed: () async {
                          if (_formKey.currentState!
                              .validate()) {
                            await saveData();
                          }
                        },
                      ),
                    )
                        : Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: pageLoading
                          ? CircularProgressIndicator()
                          : StylishCustomButton(
                        text: 'Update',
                        icon: Icons.update_rounded,
                        onPressed: () {
                          if (enableOfficeAddress) {
                            if (_formKey.currentState!
                                .validate()) {
                              updateDataToFirestore();
                            }
                          } else {
                            updateDataToFirestore();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _sendImage(imageURL) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth.currentUser!.updateDisplayName(auth.currentUser!.displayName);
    auth.currentUser!.updatePhotoURL(imageURL.toString());
  }

  Future<String> getImage({
    void Function()? whenImageSelect,
    String bucketName = "uploads",
    void Function({required String imagePath})? selectedImagePath,
  }) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _profileImage = File(pickedFile.path);
      print('File path: ${pickedFile.path}');
      //selectedImagePath(imagePath: pickedFile.path.toString());
      // here image is selected

      whenImageSelect!();

      // storing image to the firebase storage
      // FirebaseStorage _storage = FirebaseStorage.instance;
      String fileName = _profileImage!.path;

      //me ****************************
      // StorageReference firebaseStorageRef =
      //     FirebaseStorage.instance.ref().child('$bucketName/$fileName');
      // StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
      // StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      // String imageURL = await taskSnapshot.ref.getDownloadURL();
      // return imageURL; // its the uploaded image url
    } else {
      print('No image selected.');
    }
    return '';
  }

  Future<bool> isUserDataExist() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    //  retrieving the user  document from the firestore
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser!.uid)
        .get();
    // if (user == null || (!user.exists)) {
    //   return false;
    // }

    if (user.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    DocumentSnapshot userDocument = await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.currentUser!.uid)
        .get();

    if (userDocument.exists) {
      prepareTextFieldController(userDocument);
      // save the snapshot
      _userDocumentForUpdateOperation = userDocument;
      return true;
    } else {
      return false;
    }
  }

  void prepareTextFieldController(DocumentSnapshot document) {
    Map<String, dynamic>? userDocument =
    document.data() as Map<String, dynamic>?;
    print('User Firestore data: \n$userDocument');
    // assign value to the province dropdown
    // ----------------------------------------
    province = userDocument!['province'];
    // ----------------------------------------
  }

  Future<void> saveInfoToFirestore() async {
    setState(() {
      _isSubmitting = true;
    });
    FirebaseAuth auth = FirebaseAuth.instance;

    // retriving the document from the firestore
    if (widget.isFromLoginRoute) {
      // if user is from login flow
      DocumentSnapshot user = await FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser!.uid)
          .get();
      // adding data to user model
      if (widget.isFromLoginRoute == true) {
        _userModel!.district = this.district;
        _userModel!.province = province;
        // me *************************************
        // _userModel.lat = _userLocationData.latitude.toString();
        // _userModel.long = _userLocationData.longitude.toString();
      }

      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      //   // here "push" method is replace with "pushReplacement" method
      //   // me**********************************
      //   return mainPage();
      //   // return policy(); // replace with above when set
      // }));
    } else {
      // for update operation
      // passing the document to the use form model
      FirebaseFirestore.instance
          .collection("users")
          .doc('${FirebaseAuth.instance.currentUser!.uid}')
          .update({'officeAddress': officeAddressController!.text.toString()});

      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
