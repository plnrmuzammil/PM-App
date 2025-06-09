import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reale/main.dart';
import 'package:reale/resources/constant.dart';
import 'package:reale/stepper_steps/selectArea.dart';
import 'package:reale/widgets/stylishCustomButton.dart';

class SelectAddress extends StatefulWidget {
  final dynamic scheme, province, city, phase, block, subBlock;
  final String? blockName, provinceName, cityName, phaseName, schemeName, subBlockName;
  final String? propertyType, propertySubType, purpose;
  final dynamic floors, rooms, kitchens, basements, washrooms, parkings;
  final String? area, areaUnit, demand, description, plotNumber;
  final bool? showPlotToUser;

  const SelectAddress({
    super.key,
    this.scheme,
    this.province,
    this.city,
    this.phase,
    this.block,
    this.subBlock,
    this.propertyType,
    this.propertySubType,
    this.floors,
    this.rooms,
    this.kitchens,
    this.basements,
    this.washrooms,
    this.parkings,
    this.subBlockName,
    this.blockName,
    this.phaseName,
    this.cityName,
    this.schemeName,
    this.provinceName,
    this.purpose,
    this.area,
    this.areaUnit,
    this.demand,
    this.description,
    this.plotNumber,
    this.showPlotToUser,
  });

  @override
  State<SelectAddress> createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  final TextEditingController addressController = TextEditingController();
  final picker = ImagePicker();
  final List<File> _selectedImages = [];
  final Map<String, String> _uploadedImageUrls = {};
  bool _isSavingImage = false;
  String? schemeImageURL;

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _getSchemeImageUrl(String imageName) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('location_images/$imageName.jpg');
      schemeImageURL = await ref.getDownloadURL();
      houseModel.schemeImageURL = schemeImageURL!;
    } catch (e) {
      print("Failed to load image URL: $e");
    }
  }

  Future<void> _uploadListing() async {
    if (!SelectArea.isStartSubmittingData) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Missing Mandatory Fields'),
          content: const Text('Provide the value for mandatory fields'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final auth = FirebaseAuth.instance;
    final listings = FirebaseFirestore.instance.collection('listings');
    final plotInfo = FirebaseFirestore.instance.collection('plot_info');
    final updates = FirebaseFirestore.instance.collection('updates');

    // Load image from Firebase Storage based on scheme
    if (widget.schemeName != null) {
      setState(() => _isSavingImage = true);
      await _getSchemeImageUrl(widget.schemeName!.toLowerCase().replaceAll(' ', '_'));
      setState(() => _isSavingImage = false);
    }

    final listingData = {
      "province": widget.province ?? houseModel.province,
      "scheme": widget.scheme ?? houseModel.scheme,
      "provinceName": widget.provinceName ?? houseModel.provinceName,
      "cityName": widget.cityName ?? houseModel.cityName,
      "schemeName": widget.schemeName ?? houseModel.schemeName,
      "phaseName": widget.phaseName ?? houseModel.phaseName,
      "blockName": widget.blockName ?? houseModel.blockName,
      "subBlockName": widget.subBlockName ?? houseModel.subBlockName,
      "district": widget.city ?? houseModel.city,
      "phase": widget.phase ?? houseModel.phase,
      "block": widget.block ?? houseModel.block,
      "subblock": widget.subBlock ?? houseModel.subBlock,
      "adress": addressController.text,
      "type": widget.propertyType ?? houseModel.propertyType,
      "subType": widget.propertySubType ?? houseModel.propertySubType,
      "sale": widget.purpose ?? houseModel.purpose,
      "sold": "no",
      "area": houseModel.area ?? widget.area,
      "areaUnit": widget.areaUnit ?? houseModel.areaUnit,
      "demand": houseModel.demand ?? widget.demand,
      "description": widget.description ?? houseModel.description,
      "marker_x": null,
      "marker_y": null,
      "seller": auth.currentUser?.uid,
      "name": auth.currentUser?.displayName,
      "time": DateTime.now(),
      "schemeImageURL": schemeImageURL,
      "isShowPlotInfoToUser": widget.showPlotToUser,
      "plotInfo": houseModel.plotNumber ?? widget.plotNumber,
    };

    final docRef = await listings.add(listingData);
    plotCollectionID = docRef.id;

    await plotInfo.add({
      "user": auth.currentUser?.displayName,
      "plotInfo": widget.plotNumber ?? '',
      "createdAt": Timestamp.now(),
      "listingCollectionID": docRef.id,
    });

    await updates.add({
      "user": auth.currentUser?.displayName,
      "action": "created",
      "createdAt": Timestamp.now(),
      "id": docRef.id,
    });

    await _uploadImages(docRef.id);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SafeArea(
          child: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Your Listing was Successfully Posted",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25)),
                const SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 100,
                  child: StylishCustomButton.icon(
                    icon: Icons.check_circle,
                    text: "DONE",
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadImages(String documentId) async {
    final storage = FirebaseStorage.instance;
    for (final imageFile in _selectedImages) {
      final fileName = 'plot_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref().child(fileName);
      final uploadTask = await ref.putFile(imageFile);
      final url = await uploadTask.ref.getDownloadURL();
      _uploadedImageUrls['img_${DateTime.now().millisecondsSinceEpoch}'] = url;
    }

    final imagesRef = FirebaseFirestore.instance.collection("plots_images").doc(documentId);
    await imagesRef.set(_uploadedImageUrls, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: addressController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Select Address",
              hintText: "Enter property location address",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            onChanged: (val) => houseModel.address = val,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            child: ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Add Images", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 15),
          StylishCustomButton(
            text: "Submit",
            icon: Icons.check_circle,
            onPressed: _uploadListing,
          ),
          if (_isSavingImage)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
