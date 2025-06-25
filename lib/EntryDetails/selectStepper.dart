import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pm_app/mainPage.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';

class StepperForm extends StatefulWidget {
const StepperForm({super.key});

@override
State<StepperForm> createState() => _StepperFormState();
}

class _StepperFormState extends State<StepperForm> {
final _formKey = GlobalKey<FormState>();
final Box box = Hive.box('userData');
int _currentStep = 0;

var provinces = [], provinceId = [];
var districts = [], districtId = [];
var schemes = ['Scheme', 'Non-Scheme'];
var types = [], typeIds = [];
var propertyTypes = ["Commercial", "Land / Plot", "Residential"];
var subTypes = [], phases = [], phaseIds = [], blocks = [], blockIds = [], subBlocks = [], subBlockIds = [];

String selectedProvince = "", selectedProvinceId = "";
String selectedDistrict = "", selectedDistrictId = "";
String selectedScheme = "";
String selectedType = "", selectedTypeId = "";
String selectedPropertyType = "";
String selectedSubType = "";
String selectedPurpose = "";
String selectedPhase = "", selectedPhaseId = "";
String selectedBlock = "", selectedBlockId = "";
String selectedSubBlock = "", selectedSubBlockId = "";

String selectedUnit = "";
String _verticalGroupValue = "Show";
bool isShownPlotInfo = true;
File? image;
List<XFile>? pickedImages = [];
List<String> uploadedImagesUrls = [];
String username = "";

TextEditingController areaController = TextEditingController();
TextEditingController demandController = TextEditingController();
TextEditingController detailsController = TextEditingController();
TextEditingController plotController = TextEditingController();
TextEditingController addressController = TextEditingController();

final auth = FirebaseAuth.instance;
final db = FirebaseFirestore.instance.collection('listings');
final storage = FirebaseStorage.instance.ref();

@override
void initState() {
super.initState();
getUserName();
}

Future<void> getUserName() async {
final user = await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).get();
setState(() {
username = user['name'];
});
}

void showMsg(String msg) {
Fluttertoast.showToast(msg: msg, backgroundColor: Colors.black, textColor: Colors.white);
}

Future<void> getImages() async {
final List<XFile>? selected = await ImagePicker().pickMultiImage();
if (selected != null && selected.isNotEmpty) {
setState(() {
pickedImages = selected;
});
}
}
StepState _getStepState(int stepIndex) {
if (_currentStep > stepIndex) {
return StepState.complete;
} else if (_currentStep == stepIndex) {
return StepState.editing;
} else {
return StepState.indexed;
}
}


bool _validateForm() {
return selectedProvinceId.isNotEmpty &&
selectedDistrictId.isNotEmpty &&
selectedScheme.isNotEmpty &&
selectedTypeId.isNotEmpty &&
selectedPropertyType.isNotEmpty &&
selectedSubType.isNotEmpty &&
selectedPurpose.isNotEmpty &&
(!isScheme || selectedPhaseId.isNotEmpty) &&
(!isScheme || selectedBlockId.isNotEmpty) &&
(!isScheme || selectedSubBlockId.isNotEmpty) &&
areaController.text.isNotEmpty &&
selectedUnit.isNotEmpty &&
demandController.text.isNotEmpty &&
detailsController.text.isNotEmpty &&
plotController.text.isNotEmpty &&
addressController.text.isNotEmpty &&
username.isNotEmpty;
}


Future<void> submitForm() async {
  if (!_validateForm()) {
    showMsg("Please fill all required fields.");
    return;
  }

  Get.defaultDialog(title: "Uploading", content: const CircularProgressIndicator());

  try {
    uploadedImagesUrls.clear();

    if (pickedImages != null && pickedImages!.isNotEmpty) {
      print("🖼️ Uploading ${pickedImages!.length} images...");
      for (var img in pickedImages!) {
        print("📤 Uploading file: ${img.path}");
        String? url = await uploadFile(File(img.path));
        if (url != null) {
          uploadedImagesUrls.add(url);
          print("✅ Uploaded: $url");
        } else {
          print("❌ Failed to upload: ${img.path}");
        }
      }
    } else {
      print("⚠️ No images selected.");
    }

    print("📦 Upload complete. Total URLs: ${uploadedImagesUrls.length}");

    final docRef = await db.add({
      "province": selectedProvinceId,
      "provinceName": selectedProvince,
      "district": selectedDistrictId,
      "districtName": selectedDistrict,
      "scheme": selectedTypeId,
      "schemeName": selectedType,
      "phase": selectedPhaseId,
      "phaseName": selectedPhase,
      "block": selectedBlockId,
      "blockName": selectedBlock,
      "subblock": selectedSubBlockId,
      "subBlockName": selectedSubBlock,
      "address": addressController.text,
      "type": selectedPropertyType,
      "subType": selectedSubType,
      "sale": selectedPurpose,
      "sold": "no",
      "area": areaController.text,
      "areaUnit": selectedUnit,
      "demand": demandController.text,
      "description": detailsController.text,
      "marker_x": null,
      "marker_y": null,
      "seller": auth.currentUser?.uid,
      "name": username,
      "time": DateTime.now(),
      "propertyImagesURL": uploadedImagesUrls, // <- should now have data
      "isShowPlotInfoToUser": isShownPlotInfo,
      "plotInfo": plotController.text,
      "id": "",
    });

    await db.doc(docRef.id).update({"id": docRef.id});

    Get.back();
    showMsg("Successful");
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => mainPage()));
  } catch (e) {
    Get.back();
    print("🔥 Exception: $e");
    showMsg("Failed: ${e.toString()}");
  }
}

Future<String?> uploadFile(File file) async {
  try {
    final fileName = "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    final storageRef = FirebaseStorage.instance.ref().child("uploads/$fileName");

    final uploadTask = await storageRef.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return downloadUrl;
  } catch (e) {
    print("Upload error: $e");
    return null;
  }
}
bool get isScheme => selectedScheme == 'Scheme';

List<Step> getSteps() {
List<Step> steps = [
Step(
title: const Text('Province'),
content: _buildProvinceStep(),
isActive: _currentStep >= 0,
state: _getStepState(0),
),
Step(
title: const Text('District'),
content: _buildDistrictStep(),
isActive: _currentStep >= 1,
state: _getStepState(1),
),
Step(
title: const Text('Scheme/Non-Scheme'),
content: _buildSchemeStep(),
isActive: _currentStep >= 2,
state: _getStepState(2),
),
Step(
title: const Text('Location'),
content: _buildTypeStep(),
isActive: _currentStep >= 3,
state: _getStepState(3),
),
];

if (isScheme) {
steps.addAll([
Step(
title: const Text('Phase'),
content: _buildPhaseStep(),
isActive: _currentStep >= 4,
state: _getStepState(4),
),
Step(
title: const Text('Block'),
content: _buildBlockStep(),
isActive: _currentStep >= 5,
state: _getStepState(5),
),
Step(
title: const Text('Sub Block'),
content: _buildSubBlockStep(),
isActive: _currentStep >= 6,
state: _getStepState(6),
),
]);
}

int baseStep = isScheme ? 7 : 4;

steps.addAll([
Step(
title: const Text('Property Type'),
content: _buildPropertyTypeStep(),
isActive: _currentStep >= baseStep,
state: _getStepState(baseStep),
),
Step(
title: const Text('Sub Type'),
content: _buildSubTypeStep(),
isActive: _currentStep >= baseStep + 1,
state: _getStepState(baseStep + 1),
),
Step(
title: const Text('Purpose'),
content: _buildPurposeStep(),
isActive: _currentStep >= baseStep + 2,
state: _getStepState(baseStep + 2),
),
Step(
title: const Text("Plot Details"),
content: _buildPlotDetailsStep(),
isActive: _currentStep >= baseStep + 3,
state: _getStepState(baseStep + 3),
),
]);

return steps;
}

Widget _buildProvinceStep() => StreamBuilder(
stream: FirebaseFirestore.instance.collection('province').orderBy("name").snapshots(),
builder: (context, AsyncSnapshot snapshot) {
if (snapshot.hasData) {
provinces.clear(); provinceId.clear();
for (var i in snapshot.data.docs) {
var data = i.data();
if (data.containsKey('name') && data.containsKey('id')) {
provinces.add(data['name']); provinceId.add(data['id']);
}
}
return DropDown(hint: const Text("Select Province"), items: provinces,
onChanged: (val) {
setState(() {
selectedProvince = val;
selectedProvinceId = provinceId[provinces.indexOf(val)];
});
}

);
} else return const CircularProgressIndicator();
});

Widget _buildDistrictStep() => StreamBuilder(
stream: FirebaseFirestore.instance.collection('districts').orderBy("name").snapshots(),
builder: (context, AsyncSnapshot snapshot) {
if (snapshot.hasData) {
districts.clear(); districtId.clear();
for (var i in snapshot.data.docs) {
var data = i.data();
if (data['provinceID'] == selectedProvinceId) {
districts.add(data['name']); districtId.add(data['id']);
}
}
return DropDown(hint: const Text("Select District"), items: districts, onChanged: (val) {
setState(() {
selectedDistrict = val;
selectedDistrictId = districtId[districts.indexOf(val)];
});
});
} else return const CircularProgressIndicator();
});

Widget _buildSchemeStep() => DropDown(
hint: const Text("Select Scheme"),
items: schemes,
onChanged: (val) {
setState(() {
selectedScheme = val ?? "";
if (!isScheme) {
selectedPhase = selectedPhaseId = "";
selectedBlock = selectedBlockId = "";
selectedSubBlock = selectedSubBlockId = "";
}
_currentStep = _currentStep.clamp(0, getSteps().length - 1); // safety for length mismatch
});

}
);

Widget _buildTypeStep() => StreamBuilder(
stream: FirebaseFirestore.instance.collection(isScheme ? 'Scheme' : 'Non Scheme').orderBy("name").snapshots(),
builder: (context, AsyncSnapshot snapshot) {
if (snapshot.hasData) {
types.clear(); typeIds.clear();
for (var i in snapshot.data.docs) {
var data = i.data();
if (data['provinceID'] == selectedProvinceId && data['districtID'] == selectedDistrictId) {
types.add(data['name']); typeIds.add(data['id']);
}
}
return DropDown(hint: const Text("Select Type"), items: types, onChanged: (val) {
setState(() {
selectedType = val;
selectedTypeId = typeIds[types.indexOf(val)];
});
});
} else return const CircularProgressIndicator();
});

Widget _buildPhaseStep() => StreamBuilder(
stream: FirebaseFirestore.instance.collection('Phase').orderBy("name").snapshots(),
builder: (context, AsyncSnapshot snapshot) {
if (snapshot.hasData) {
phases.clear(); phaseIds.clear();
for (var i in snapshot.data.docs) {
var data = i.data();
if (data['provinceID'] == selectedProvinceId && data['districtID'] == selectedDistrictId && data['schemeID'] == selectedTypeId) {
phases.add(data['name']); phaseIds.add(data['id']);
}
}
return DropDown(hint: const Text("Select Phase"), items: phases, onChanged: (val) => setState(() {
selectedPhase = val;
selectedPhaseId = phaseIds[phases.indexOf(val)];
}));
} else return const CircularProgressIndicator();
});

Widget _buildBlockStep() => StreamBuilder(
stream: FirebaseFirestore.instance.collection('block').orderBy("name").snapshots(),
builder: (context, AsyncSnapshot snapshot) {
if (snapshot.hasData) {
blocks.clear(); blockIds.clear();
for (var i in snapshot.data.docs) {
var data = i.data();
if (data['provinceID'] == selectedProvinceId && data['districtID'] == selectedDistrictId && data['schemeID'] == selectedTypeId && data['phaseID'] == selectedPhaseId) {
blocks.add(data['name']); blockIds.add(data['id']);
}
}
return DropDown(hint: const Text("Select Block"), items: blocks, onChanged: (val) => setState(() {
selectedBlock = val;
selectedBlockId = blockIds[blocks.indexOf(val)];
}));
} else return const CircularProgressIndicator();
});

Widget _buildSubBlockStep() => StreamBuilder(
stream: FirebaseFirestore.instance.collection('subblock').orderBy("name").snapshots(),
builder: (context, AsyncSnapshot snapshot) {
if (snapshot.hasData) {
subBlocks.clear(); subBlockIds.clear();
for (var i in snapshot.data.docs) {
var data = i.data();
if (data['provinceID'] == selectedProvinceId && data['districtID'] == selectedDistrictId && data['schemeID'] == selectedTypeId && data['phaseID'] == selectedPhaseId && data['blockID'] == selectedBlockId) {
subBlocks.add(data['name']); subBlockIds.add(data['id']);
}
}
return DropDown(hint: const Text("Select Sub Block"), items: subBlocks, onChanged: (val) => setState(() {
selectedSubBlock = val;
selectedSubBlockId = subBlockIds[subBlocks.indexOf(val)];
}));
} else return const CircularProgressIndicator();
});

Widget _buildPropertyTypeStep() => DropDown(hint: const Text("Select Property Type"), items: propertyTypes,
onChanged: (val) {
setState(() {
selectedPropertyType = val!;
_updateSubTypes(val);  // Keep this inside setState
});
}

);

Widget _buildSubTypeStep() => DropDown(hint: const Text("Select Property Subtype"), items: subTypes,
onChanged: (val) => setState(() => selectedSubType = val));

Widget _buildPurposeStep() => DropDown(hint: const Text("Select Purpose"), items: ["Lease", "Rent", "Sale"],
onChanged: (val) => setState(() => selectedPurpose = val!));

Widget _buildPlotDetailsStep() => Column(
children: [
TextFormField(controller: areaController, decoration: const InputDecoration(labelText: "Area",),                keyboardType: TextInputType.number,
),
DropDown(hint: const Text("Unit"), items: ["Marla", "Squareft"],
onChanged: (val) => setState(() => selectedUnit = val!)),
TextFormField(controller: demandController, decoration: const InputDecoration(labelText: "Demand",hint: Text("Value of Demand")),                keyboardType: TextInputType.number,
),
TextFormField(controller: detailsController, decoration: const InputDecoration(labelText: "All Details: Number of Rooms, Washrooms, Lounge etc ",hint: Text("All Details like: Numbers of Rooms, Kitchen, Washrooms, Lounge, etc and other condition of Property")), maxLines: 3),
TextFormField(controller: plotController, decoration: const InputDecoration(labelText: "Plot / Flat / Khasra")),
RadioGroup<String>.builder(
direction: Axis.horizontal,
groupValue: _verticalGroupValue,
onChanged: (val) {
setState(() {
_verticalGroupValue = val!;
isShownPlotInfo = val == "Show";
});
},
items: ["Show", "Hide"],
itemBuilder: (item) => RadioButtonBuilder(item),
),
TextFormField(controller: addressController, decoration: const InputDecoration(labelText: "Address",hint: Text("Please Enter property location like street number etc")), maxLines: 2),
MaterialButton(
color: Colors.green,
onPressed: getImages,
child: const Text("Add Images", style: TextStyle(color: Colors.white)),
),


if (pickedImages != null && pickedImages!.isNotEmpty)
SizedBox(
height: 110,
child: ListView.separated(
scrollDirection: Axis.horizontal,
padding: const EdgeInsets.symmetric(horizontal: 8),
itemCount: pickedImages!.length,
separatorBuilder: (_, __) => const SizedBox(width: 8),
itemBuilder: (context, index) {
return Stack(
alignment: Alignment.topRight,
children: [
GestureDetector(
onTap: () {
showDialog(
context: context,
builder: (_) => Dialog(
backgroundColor: Colors.black,
child: GestureDetector(
onTap: () {
showDialog(
context: context,
builder: (_) => Dialog(
backgroundColor: Colors.black,
insetPadding: EdgeInsets.zero,
child: Stack(
children: [
PageView.builder(
controller: PageController(initialPage: index),
itemCount: pickedImages!.length,
itemBuilder: (context, i) {
return InteractiveViewer(
child: Center(
child: Image.file(
File(pickedImages![i].path),
fit: BoxFit.contain,
),
),
);
},
),
Positioned(
top: 30,
right: 20,
child: IconButton(
icon: const Icon(Icons.close, color: Colors.white, size: 30),
onPressed: () => Navigator.of(context).pop(),
),
),
],
),
),
);
},
child: InteractiveViewer(
child: Image.file(
File(pickedImages![index].path),
fit: BoxFit.contain,
),
),
),
),
);
},
child: ClipRRect(
borderRadius: BorderRadius.circular(8),
child: Image.file(
File(pickedImages![index].path),
width: 100,
height: 100,
fit: BoxFit.cover,
),
),
),
Positioned(
right: 2,
top: 2,
child: GestureDetector(
onTap: () {
setState(() {
pickedImages!.removeAt(index);
});
},
child: Container(
decoration: BoxDecoration(
color: Colors.black54,
shape: BoxShape.circle,
),
padding: const EdgeInsets.all(2),
child: const Icon(Icons.close, size: 18, color: Colors.white),
),
),
),
],
);
},
),
),
],
);

void _updateSubTypes(String propertyType) {
if (propertyType == "Commercial") {
subTypes = ['Food Court', "Factory", "Gym", "Hall", "Office", "Shop", "Theatre", "Warehouse"];
} else if (propertyType == "Residential") {
subTypes = ['Farm House', 'Guest House', 'Hostel', 'House', 'Penthouse', "Room", 'Villas'];
} else if (propertyType == "Land / Plot") {
subTypes = ['Commercial Land', 'Residential Land', 'Plot File'];
} else {
subTypes = [];
}
}

void _onStepContinue() {
if (_validateCurrentStep(_currentStep)) {
if (_currentStep < getSteps().length - 1) {
setState(() => _currentStep++);
} else {
submitForm(); // only on last step
}
}
}

void _onStepCancel() {
if (_currentStep > 0) {
setState(() => _currentStep--);
}
}

@override
@override
@override
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Stepper Entry Form"), backgroundColor: Colors.green),
body: Stepper(
key: ValueKey("$_currentStep-$isScheme-$selectedPurpose-$selectedSubType-$selectedUnit"),
type: StepperType.vertical,
currentStep: _currentStep,
onStepContinue: _onStepContinue,
onStepCancel: _onStepCancel,
steps: getSteps(),
controlsBuilder: (context, details) {
return Row(
children: [
ElevatedButton(
onPressed: details.onStepContinue,
child: Text(_currentStep == getSteps().length - 1 ? "Submit" : "Next"),
),
const SizedBox(width: 10),
if (_currentStep > 0)
TextButton(
onPressed: details.onStepCancel,
child: const Text("Back"),
),
],
);
},
),
);
}
// steps validation

bool _validateCurrentStep(int step) {
switch (step) {
case 0:
if (selectedProvinceId.isEmpty) {
showMsg("Please select a province.");
return false;
}
break;
case 1:
if (selectedDistrictId.isEmpty) {
showMsg("Please select a district.");
return false;
}
break;
case 2:
if (selectedScheme.isEmpty) {
showMsg("Please select scheme or non-scheme.");
return false;
}
break;
case 3:
if (selectedTypeId.isEmpty) {
showMsg("Please select a type.");
return false;
}
break;
case 4:
if (isScheme && selectedPhaseId.isEmpty) {
showMsg("Please select a phase.");
return false;
}
break;
case 5:
if (isScheme && selectedBlockId.isEmpty) {
showMsg("Please select a block.");
return false;
}
break;
case 6:
if (isScheme && selectedSubBlockId.isEmpty) {
showMsg("Please select a sub-block.");
return false;
}
break;
case 7:
if (selectedPropertyType.isEmpty) {
showMsg("Please select a property type.");
return false;
}
break;
case 8:
if (selectedSubType.isEmpty) {
showMsg("Please select a property subtype.");
return false;
}
break;
case 9:
if (selectedPurpose.isEmpty) {
showMsg("Please select a purpose.");
return false;
}
break;
case 10:
if (areaController.text.isEmpty ||
selectedUnit.isEmpty ||
demandController.text.isEmpty ||
detailsController.text.isEmpty ||
plotController.text.isEmpty ||
addressController.text.isEmpty) {
showMsg("Please fill all plot detail fields.");
return false;
}
break;
}
return true;
}}

