import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pm_app/EntryDetails/selectCityDetails.dart';
import 'package:pm_app/mainPage.dart';
import 'package:pm_app/widgets/stylishCustomButton.dart';
//
// class SelectProvinceDetails extends StatefulWidget{
//   const SelectProvinceDetails({Key? key}) : super(key: key);
//
//   @override
//   _SelectProvinceDetailsState createState() => _SelectProvinceDetailsState();
// }
//
// class _SelectProvinceDetailsState extends State<SelectProvinceDetails> {
//
//
//   var provinces = [];
//   var provinceId = [];
//   Box box = Hive.box<dynamic>('userData');
//
//   String selectProvince = "";
//   String selectProvinceId = "";
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             StreamBuilder(
//               stream: FirebaseFirestore.instance
//                   .collection('province')
//                   .orderBy("name", descending: false)
//                   .snapshots(),
//               builder: (BuildContext context, AsyncSnapshot snapshot) {
//                 if (snapshot.hasData) {
//                   var el = snapshot.data.docs;
//                   provinces = [];
//                   provinceId = [];
//                   for (var i in el) {
//                     if (i.data() != null) {
//                       provinces.add(i.data()['name']);
//                       provinceId.add(i.data()['id']);
//                     }
//                   }
//                   print(provinceId);
//                   return DropDown<dynamic>(
//                     hint: Text("select province"),
//                     items: provinces,
//                     onChanged: (val){
//                       setState(() {
//                         selectProvince = val;
//                         selectProvinceId = provinceId[provinces.indexOf(val)];
//                       });
//                     },
//                   );
//                 } else {
//                   return const CircularProgressIndicator();
//                 }
//               },
//             ),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     box.delete('provinceName');
//                     box.delete('provinceId');
//                   },
//                   child: Text("Back"),
//                 ),
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (selectProvince == "" && selectProvinceId == "") ? null : (){
//                     box.put('provinceName', selectProvince);
//                     box.put('provinceId', selectProvinceId);
//                     Navigator.of(context).pushReplacement(
//
//                         MaterialPageRoute(
//                             builder: (context) => SelectCityDetails(
//                               provinceId: selectProvinceId,
//                             )));
//                   }, child:const Text("Continue"),),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//Stepper plnr
//
// class SelectProvinceDetails extends StatefulWidget{
//   const SelectProvinceDetails({Key? key}) : super(key: key);
//
//   @override
//   _SelectProvinceDetailsState createState() => _SelectProvinceDetailsState();
// }
//
// class _SelectProvinceDetailsState extends State<SelectProvinceDetails> {
//
//
//   var provinces = [];
//   var provinceId = [];
//   Box box = Hive.box<dynamic>('userData');
//
//   String selectProvince = "";
//   String selectProvinceId = "";
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             StreamBuilder(
//               stream: FirebaseFirestore.instance
//                   .collection('province')
//                   .orderBy("name", descending: false)
//                   .snapshots(),
//               builder: (BuildContext context, AsyncSnapshot snapshot) {
//                 if (snapshot.hasData) {
//                   var el = snapshot.data.docs;
//                   provinces = [];
//                   provinceId = [];
//                   for (var i in el) {
//                     if (i.data() != null) {
//                       provinces.add(i.data()['name']);
//                       provinceId.add(i.data()['id']);
//                     }
//                   }
//                   print(provinceId);
//                   return DropDown<dynamic>(
//                     hint: Text("select province"),
//                     items: provinces,
//                     onChanged: (val){
//                       setState(() {
//                         selectProvince = val;
//                         selectProvinceId = provinceId[provinces.indexOf(val)];
//                       });
//                     },
//                   );
//                 } else {
//                   return const CircularProgressIndicator();
//                 }
//               },
//             ),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     box.delete('provinceName');
//                     box.delete('provinceId');
//                   },
//                   child: Text("Back"),
//                 ),
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (selectProvince == "" && selectProvinceId == "") ? null : (){
//                     box.put('provinceName', selectProvince);
//                     box.put('provinceId', selectProvinceId);
//                     Navigator.of(context).pushReplacement(
//
//                         MaterialPageRoute(
//                             builder: (context) => SelectCityDetails(
//                               provinceId: selectProvinceId,
//                             )));
//                   }, child:const Text("Continue"),),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class SelectCityDetails extends StatefulWidget {
//   const SelectCityDetails({Key? key, required this.provinceId, }) : super(key: key);
//
//   final String provinceId;
//
//   @override
//   _SelectCityDetailsState createState() => _SelectCityDetailsState();
// }
//
// class _SelectCityDetailsState extends State<SelectCityDetails> {
//
//   var city = [];
//   var cityId = [];
//   Box box = Hive.box<dynamic>('userData');
//
//   String selectCity = "";
//   String selectCityId = "";
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             StreamBuilder(
//               stream: FirebaseFirestore.instance.collection('cities').orderBy('name', descending: false).snapshots(),
//               builder: (BuildContext context, AsyncSnapshot snapshot)
//               {
//                 if(snapshot.hasData)
//                 {
//                   var el = snapshot.data.docs;
//                   city = [];
//                   cityId = [];
//                   for(var e in el)
//                   {
//                     if(e.data() != null)
//                     {
//                       if(e.data()['provinceID'] == widget.provinceId)
//                       {
//                         cityId.add(e.data()['id']);
//                         city.add(e.data()['name']);
//                       }
//                     }
//                   }
//
//                   return DropDown<dynamic>(
//                     hint: Text('select city'),
//                     items: city,
//                     onChanged: (val){
//                       setState(() {
//                         selectCity = val;
//                         selectCityId = cityId[city.indexOf(val)];
//                       });
//                     },
//                   );
//                 }
//                 else
//                 {
//                   return CircularProgressIndicator();
//                 }
//               },
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     box.delete('city');
//                     box.delete('cityId');
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SelectProvinceDetails()));
//                   }, child: Text("Back"),),
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed:(selectCity == "" && selectCityId == "") ? null : (){
//                     box.put('city', selectCity);
//                     box.put('cityId', selectCityId);
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SelectSchemeDetails(
//                       provinceId: widget.provinceId,
//                       cityId: selectCityId,
//                     )));
//                     //Navigator.of(context).push(MaterialPageRoute(builder: (context) => SelectProvinceDetails()));
//                   }, child: Text("Continue"),),
//
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
// class SelectSchemeDetails extends StatefulWidget {
//   const SelectSchemeDetails({Key? key, required this.provinceId, required this.cityId}) : super(key: key);
//
//   final String provinceId;
//   final String cityId;
//
//   @override
//   State<SelectSchemeDetails> createState() => _SelectSchemeDetailsState();
// }
//
// class _SelectSchemeDetailsState extends State<SelectSchemeDetails> {
//
//   var SchemesData = ['Scheme', 'Non-Scheme'];
//   bool isScheme = false;
//   bool isNonScheme = false;
//
//   Box<dynamic> box = Hive.box<dynamic>('userData');
//   String selectScheme = "";
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropDown<dynamic>(
//               hint:const Text('select scheme'),
//               items: SchemesData,
//               onChanged: (val)
//               {
//                 setState(() {
//                   selectScheme = val;
//                 });
//               },
//             ),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     box.delete('schemeData');
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SelectCityDetails(provinceId: widget.provinceId)));
//                   }, child: Text("Back"),),
//
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: selectScheme == "" ? null : (){
//                     box.put('schemeData', selectScheme);
//                     Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                             builder: (context) => SelectTypeDetails(provinceId: widget.provinceId, cityId: widget.cityId, isScheme: selectScheme == "Scheme" ? true : false,)
//                         ));
//                   }, child: Text("Continue"),),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class SelectTypeDetails extends StatefulWidget {
//   const SelectTypeDetails({Key? key, required this.provinceId,  required this.cityId, required this.isScheme}) : super(key: key);
//
//
//   final String provinceId;
//   final String cityId;
//   final bool isScheme;
//
//   @override
//   _SelectTypeDetailsState createState() => _SelectTypeDetailsState();
// }
//
// class _SelectTypeDetailsState extends State<SelectTypeDetails> {
//
//   Box box = Hive.box<dynamic>('userData');
//
//   var type = [];
//   var typeId = [];
//   String typeSelected = "";
//   String typeIdSelected = "";
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     print(widget.isScheme);
//   }
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             StreamBuilder(
//               stream: FirebaseFirestore.instance.collection(widget.isScheme ? 'Scheme' : 'Non Scheme').orderBy('name', descending: false).snapshots(),
//               builder: (BuildContext context, AsyncSnapshot snapshot)
//               {
//                 if(snapshot.hasData)
//                 {
//                   var myData = snapshot.data.docs;
//                   type = [];
//                   typeId = [];
//
//                   for(var el in myData)
//                   {
//                     if(el.data() != null)
//                     {
//                       if(widget.provinceId == el.data()['provinceID'] && widget.cityId == el.data()['cityID'])
//                       {
//                         type.add(el.data()['name']);
//                         typeId.add(el.data()['id']);
//                       }
//                     }
//                   }
//
//                   return DropDown<dynamic>(
//                     hint: Text("select type"),
//                     items: type,
//                     onChanged: (val)
//                     {
//                       setState((){
//                         typeSelected = val;
//                         typeIdSelected = typeId[type.indexOf(val)];
//                       });
//                     },
//                   );
//                 }
//                 else
//                 {
//                   return const CircularProgressIndicator();
//                 }
//               },
//             ),
//
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     box.delete('type');
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SelectSchemeDetails(provinceId: widget.provinceId, cityId: widget.cityId,)));
//                   },
//                   child: Text("Back"),
//                 ),
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (typeSelected == "" && typeIdSelected == "") ? null : (){
//                     box.put('type', typeSelected);
//                     box.put('typeId', typeIdSelected);
//                     Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(builder: (context) =>
//                             SelectPropertyType(isScheme: widget.isScheme, provinceId: widget.provinceId, cityId: widget.cityId, typeId: typeIdSelected,),
//                         ));
//                   }, child:const Text("Continue"),),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class SelectPropertyType extends StatefulWidget {
//   const SelectPropertyType({Key? key, required this.isScheme, required this.provinceId, required this.cityId, required this.typeId}) : super(key: key);
//
//   final String provinceId;
//   final String cityId;
//   final String typeId;
//   final bool isScheme;
//
//   @override
//   _SelectPropertyTypeState createState() => _SelectPropertyTypeState();
// }
//
// class _SelectPropertyTypeState extends State<SelectPropertyType> {
//
//   Box box = Hive.box<dynamic>('userData');
//
//   String selectPropertyType = "";
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropDown<dynamic>(
//               hint: Text("select property type"),
//               items: ["Commercial", "Land / Plot", "Residential"],
//               onChanged: (val)
//               {
//                 setState((){
//                   selectPropertyType = val;
//                 });
//               },
//             ),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     box.delete('propertyType');
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
//                         SelectTypeDetails(
//                           provinceId: widget.provinceId ,
//                           cityId: widget.cityId,
//                           isScheme: widget.isScheme,
//                         )));
//                   }, child: Text("Back"),),
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed:selectPropertyType == "" ? null : (){
//                     box.put('propertyType', selectPropertyType);
//                     Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               SelectPropertySubType(
//                                 propertyType: selectPropertyType,
//                                 provinceId: widget.provinceId,
//                                 cityId: widget.cityId,
//                                 typeId: widget.typeId,
//                                 isScheme: widget.isScheme,
//                               ),
//                         ));
//                   },
//                   child: Text("Continue"),),
//
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class SelectPropertySubType extends StatefulWidget {
//   const SelectPropertySubType({Key? key, required this.propertyType, required this.provinceId, required this.cityId, required this.typeId, required this.isScheme}) : super(key: key);
//
//   final String propertyType;
//   final String provinceId;
//   final String cityId;
//   final String typeId;
//   final bool isScheme;
//
//   @override
//   _SelectPropertySubTypeState createState() => _SelectPropertySubTypeState();
// }
//
// class _SelectPropertySubTypeState extends State<SelectPropertySubType>{
//
//   Box box = Hive.box<dynamic>('userData');
//   var dynamicItems = [];
//
//   @override
//   void initState() {
//     if (widget.propertyType == "Commercial") {
//       dynamicItems = [
//         'Food Court',
//         "Factory",
//         "Gym",
//         "Hall",
//         "Office",
//         "Shop",
//         "Theatre",
//         "Warehouse",
//       ];
//     } else if (widget.propertyType == "Residential") {
//       dynamicItems = [
//         'Farm House',
//         'Guest House',
//         'Hostel',
//         'House',
//         'Penthouse',
//         "Room",
//         'Villas',
//       ];
//     } else if (widget.propertyType == "Land / Plot") {
//       dynamicItems = [
//         'Commercial Land',
//         'Residential Land',
//         'Plot File',
//         //'Agricultural Land',
//       ];
//     } else {
//       dynamicItems = ["None"];
//     }
//
//     super.initState();
//   }
//
//   String propertySubType = "";
//
//
//   @override
//   Widget build(BuildContext context){
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropDown<dynamic>(
//               hint: Text("select sub type"),
//               items: dynamicItems,
//               onChanged: (val)
//               {
//                 setState((){
//                   propertySubType = val;
//                 });
//               },
//             ),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     box.delete('propertySubType');
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SelectPropertyType(
//                       provinceId: widget.provinceId,
//                       cityId: widget.cityId,
//                       typeId: widget.typeId,
//                       isScheme: widget.isScheme,
//                     )));
//                   }, child: Text("Back"),),
//
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed:propertySubType == "" ? null : (){
//                     box.put('propertySubType', propertySubType);
//                     Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                           builder: (context) => SelectPurpose(
//                             propertyType: widget.propertyType,
//                             provinceId: widget.provinceId,
//                             cityId: widget.cityId,
//                             typeId: widget.typeId,
//                             isScheme: widget.isScheme,
//                           ),
//                         ));
//                   },
//                   child: Text("Continue"),),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class SelectPurpose extends StatefulWidget {
//   const SelectPurpose({Key? key, required this.propertyType, required this.provinceId, required this.cityId, required this.typeId, required this.isScheme}) : super(key: key);
//
//   final String propertyType;
//   final String provinceId;
//   final String cityId;
//   final String typeId;
//   final bool isScheme;
//
//   @override
//   _SelectPurposeState createState() => _SelectPurposeState();
// }
//
// class _SelectPurposeState extends State<SelectPurpose> {
//
//   Box box = Hive.box<dynamic>('userData');
//   String selectedPurpose = "";
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//
//             DropDown<dynamic>(
//               hint: Text("select purpose"),
//               items: [
//                 "Lease",
//                 "Rent",
//                 "Sale",
//               ],
//               onChanged: (val)
//               {
//                 setState((){
//                   selectedPurpose = val;
//                 });
//               },
//             ),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     box.delete('purpose');
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
//                         SelectPropertySubType(
//                           provinceId: widget.provinceId,
//                           cityId: widget.cityId,
//                           typeId: widget.typeId,
//                           isScheme: widget.isScheme,
//                           propertyType: widget.propertyType,
//                         )));
//                   },
//                   child:const Text("Back"),),
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed:selectedPurpose == "" ? null : (){
//                     box.put('purpose', selectedPurpose);
//                     Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                           builder: (context) => widget.isScheme ? SelectPhaseDetails(cityId: widget.cityId, provinceId: widget.provinceId, typeId: widget.typeId, isScheme: widget.isScheme, propertyType: widget.propertyType,) :  SelectArea(isScheme: widget.isScheme,),
//                         ));
//                   },
//                   child: Text("Continue"),),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class SelectPhaseDetails extends StatefulWidget {
//   const SelectPhaseDetails({Key? key, required this.cityId, required this.provinceId, required this.isScheme, required this.propertyType, required this.typeId,}) : super(key: key);
//
//   final String propertyType;
//   final String provinceId;
//   final String cityId;
//   final String typeId;
//   final bool isScheme;
//   @override
//   _SelectPhaseDetailsState createState() => _SelectPhaseDetailsState();
// }
//
// class _SelectPhaseDetailsState extends State<SelectPhaseDetails> {
//
//   var phase = [];
//   var phaseId = [];
//   String selectedPhaseName = "";
//   String selectedPhaseNameId = "";
//
//   Box box = Hive.box<dynamic>('userData');
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             StreamBuilder(
//               stream: FirebaseFirestore.instance
//                   .collection('Phase')
//                   .orderBy("name", descending: false)
//                   .snapshots(),
//               builder: (BuildContext context, AsyncSnapshot snapshot){
//                 if (snapshot.hasData) {
//                   var el = snapshot.data.docs;
//                   phase = [];
//                   phaseId = [];
//                   for (var i in el) {
//                     if (i.data() != null) {
//                       if(i.data()['cityID'] == widget.cityId && i.data()['provinceID'] == widget.provinceId && i.data()['schemeID'] == widget.typeId)
//                       {
//                         phase.add(i.data()['name']);
//                         phaseId.add(i.data()['id']);
//                       }
//                     }
//                   }
//
//                   return DropDown<dynamic>(
//                     hint: Text("select phase"),
//                     items: phase,
//                     onChanged: (val){
//                       setState(() {
//                         selectedPhaseName = val;
//                         selectedPhaseNameId = phaseId[phase.indexOf(val)];
//                       });
//                     },
//                   );
//                 } else {
//                   return const CircularProgressIndicator();
//                 }
//               },
//             ),
//
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     box.delete('phase');
//                     box.delete('phaseId');
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SelectPurpose(provinceId: widget.provinceId, cityId: widget.cityId, isScheme: true, propertyType: widget.propertyType, typeId: widget.typeId,)));
//                   }, child: Text("Back"),),
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed:(selectedPhaseName == "" && selectedPhaseNameId == "") ? null : (){
//                     box.put('phase', selectedPhaseName);
//                     box.put('phaseId', selectedPhaseNameId);
//                     Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                             builder: (context) => SelectBlockDetails(provinceId: widget.provinceId, cityId: widget.cityId, schemeId: widget.typeId, phaseId: selectedPhaseNameId, isScheme: widget.isScheme, propertyType: widget.propertyType,)
//                         ));
//                   },
//                   child: Text("Continue"),),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class SelectBlockDetails extends StatefulWidget {
//   const SelectBlockDetails({Key? key, required this.provinceId, required this.cityId, required this.schemeId, required this.phaseId, required this.isScheme, required this.propertyType}) : super(key: key);
//
//   final String provinceId;
//   final String cityId;
//   final String schemeId;
//   final String phaseId;
//   final bool isScheme;
//   final String propertyType;
//
//   @override
//   _SelectBlockDetailsState createState() => _SelectBlockDetailsState();
// }
//
// class _SelectBlockDetailsState extends State<SelectBlockDetails> {
//
//   var block= [];
//   var blockId = [];
//   String selectedBlock = "";
//   String selectedBlockId = "";
//
//   Box box = Hive.box<dynamic>('userData');
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             StreamBuilder(
//                 stream: FirebaseFirestore.instance.collection('block').orderBy('name', descending: false).snapshots(),
//                 builder: (BuildContext context, AsyncSnapshot snapshot){
//                   if(snapshot.hasData)
//                   {
//                     var el = snapshot.data.docs;
//                     block = [];
//                     blockId = [];
//                     for(var e in el)
//                     {
//                       if(e.data() != null)
//                       {
//                         if(e.data()['cityID'] == widget.cityId && e.data()['provinceID'] == widget.provinceId && e.data()['schemeID'] == widget.schemeId && e.data()['phaseID'] == widget.phaseId)
//                         {
//                           block.add(e.data()['name']);
//                           blockId.add(e.data()['id']);
//                         }
//                         else
//                         {
//                           print('error');
//                         }
//                       }
//                       else
//                       {
//                         print('error');
//                       }
//                     }
//
//
//                     return  DropDown<dynamic>(
//                       hint: Text("select block"),
//                       items: block,
//                       onChanged: (val)
//                       {
//                         setState((){
//                           selectedBlock = val;
//                           selectedBlockId = blockId[block.indexOf(val)];
//                         });
//                       },
//                     );
//                   }
//                   else
//                   {
//                     return CircularProgressIndicator();
//                   }
//                 }),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     box.delete('block');
//                     box.delete('blockId');
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(
//                         builder: (context) =>
//                             SelectPhaseDetails(provinceId: widget.provinceId, cityId: widget.cityId, typeId: widget.schemeId, isScheme: widget.isScheme, propertyType: widget.propertyType,)));
//                   }, child: Text("Back"),),
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed:(selectedBlock == "" && selectedBlockId == "") ? null : (){
//                     box.put('block', selectedBlock);
//                     box.put('blockId', selectedBlockId);
//                     Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                             builder: (context) => SubBlockDetails(
//                               provinceId: widget.provinceId,
//                               cityId: widget.cityId,
//                               schemeId: widget.schemeId,
//                               phaseId: widget.phaseId,
//                               blockId: selectedBlockId,
//                               isScheme: widget.isScheme,
//                               propertyType: widget.propertyType,
//                             )
//                         ));
//                   },
//                   child: Text("Continue"),),
//
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class SubBlockDetails extends StatefulWidget {
//   const SubBlockDetails({Key? key, required this.cityId, required this.provinceId, required this.phaseId, required this.blockId, required this.schemeId, required this.isScheme, required this.propertyType}) : super(key: key);
//
//   final String cityId;
//   final String provinceId;
//   final String phaseId;
//   final String blockId;
//   final String schemeId;
//   final bool isScheme;
//   final String propertyType;
//
//
//   @override
//   _SubBlockDetailsState createState() => _SubBlockDetailsState();
// }
//
// class _SubBlockDetailsState extends State<SubBlockDetails> {
//
//   var subBlock = [];
//   var subBlockId = [];
//   String selectedSubBlock = "";
//   String selectedSubBlockId = "";
//
//   Box box = Hive.box<dynamic>('userData');
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             StreamBuilder(
//                 stream: FirebaseFirestore.instance.collection('subblock').orderBy('name', descending: false).snapshots(),
//                 builder: (BuildContext context, AsyncSnapshot snapshot){
//                   if(snapshot.hasData)
//                   {
//                     var el = snapshot.data.docs;
//                     subBlock = [];
//                     subBlockId = [];
//                     for(var e in el)
//                     {
//                       if(e.data() != null)
//                       {
//                         if(e.data()['cityID'] == widget.cityId && e.data()['provinceID'] == widget.provinceId && e.data()['schemeID'] == widget.schemeId && e.data()['phaseID'] == widget.phaseId && e.data()['blockID'] == widget.blockId)
//                         {
//
//                           subBlock.add(e.data()['name']);
//                           subBlockId.add(e.data()['id']);
//                         }
//                         else
//                         {
//                           print('error');
//                         }
//                       }
//                       else
//                       {
//                         print('error');
//                       }
//                     }
//
//
//                     return  DropDown<dynamic>(
//                       hint: Text("select sub block"),
//                       items: subBlock,
//                       onChanged: (val)
//                       {
//                         setState((){
//                           selectedSubBlock = val;
//                           selectedSubBlockId = subBlockId[subBlock.indexOf(val)];
//                         });
//                       },
//                     );
//                   }
//                   else
//                   {
//                     return CircularProgressIndicator();
//                   }
//                 }),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     box.delete('subBlock');
//                     box.delete('subBlockId');
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
//                         SelectBlockDetails(
//                           provinceId: widget.provinceId,
//                           cityId: widget.cityId,
//                           schemeId: widget.schemeId,
//                           isScheme: widget.isScheme,
//                           propertyType: widget.propertyType,
//                           phaseId: widget.phaseId,
//                         )));
//                   }, child: Text("Back"),),
//                 MaterialButton(
//                   color: Colors.green,
//                   onPressed:(selectedSubBlock == "" && selectedSubBlockId == "") ? null : (){
//                     box.put('subBlock', selectedSubBlock);
//                     box.put('subBlockId', selectedSubBlockId);
//                     Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                           builder: (context) => SelectArea(isScheme: widget.isScheme,),
//                         ));
//                   },
//                   child: Text("Continue"),),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
//
// class SelectArea extends StatefulWidget {
//   const SelectArea({Key? key, required this.isScheme}) : super(key: key);
//
//   final bool isScheme;
//   @override
//   _SelectAreaState createState() => _SelectAreaState();
// }
//
// class _SelectAreaState extends State<SelectArea> {
//
//   String imgpath = "";
//   Box box = Hive.box<dynamic>('userData');
//   bool showImage = false;
//
//   final db = FirebaseFirestore.instance.collection('listings');
//   final pic_db = FirebaseFirestore.instance.collection('listingsPics');
//   final upd = FirebaseFirestore.instance.collection('updates');
//   final plotInfo = FirebaseFirestore.instance.collection('plot_info');
//   final auth = FirebaseAuth.instance;
//   final phaseDb = FirebaseFirestore.instance.collection('Phase');
//   final storage = FirebaseStorage.instance.ref();
//
//   bool isShownPlotInfo = true;
//   bool isLoading = false;
//
//   final TextEditingController areaController = TextEditingController();
//   final TextEditingController demandController = TextEditingController();
//   final TextEditingController detailsController = TextEditingController();
//   final TextEditingController plotFlatKharsaraController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//
//   String provinceName = "";
//   String provinceId = "";
//   String city = "";
//   String cityId = "";
//   String scheme = "";
//   String type = "";
//   String typeId = "";
//   String phase = "";
//   String phaseId = "";
//   String block = "";
//   String blockId = "";
//   String subBlock = "";
//   String subBlockId = "";
//   String propertyType = "";
//   String subPropertyType = "";
//   String purpose = "";
//   String username = "";
//
//   void getData()
//   {
//     provinceName = box.get('provinceName');
//     provinceId = box.get('provinceId');
//     city = box.get('city');
//     cityId = box.get('cityId');
//     scheme = box.get('schemeData');
//     type = box.get('type');
//     typeId = box.get('typeId');
//     print("type id $typeId");
//     propertyType = box.get('propertyType');
//     subPropertyType = box.get('propertySubType');
//     purpose = box.get('purpose');
//   }
//
//
//   getName()async{
//     final userData = await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).get();
//     final user = userData['name'];
//     setState(() {
//       username = user;
//     });
//
//   }
//
//   void getAllData()
//   {
//     provinceName = box.get('provinceName');
//     provinceId = box.get('provinceId');
//     city = box.get('city');
//     cityId = box.get('cityId');
//     scheme = box.get('schemeData');
//     type = box.get('type');
//     typeId = box.get('typeId');
//     phase = box.get('phase');
//     phaseId = box.get('phaseId');
//     block = box.get('block');
//     blockId = box.get('blockId');
//     subBlock = box.get('subBlock');
//     subBlockId = box.get('subBlockId');
//     propertyType = box.get('propertyType');
//     subPropertyType = box.get('propertySubType');
//     purpose = box.get('purpose');
//   }
//
//   File? image;
//
//
//   void showMsg(String msg)
//   {
//     Fluttertoast.showToast(
//         gravity: ToastGravity.BOTTOM,
//         textColor: Colors.white,
//         backgroundColor: Colors.black,
//         toastLength: Toast.LENGTH_SHORT,
//         msg: msg
//     );
//   }
//
//   void getImage()async{
//     final pickedImage = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
//     setState(() {
//       image = File(pickedImage!.path);
//       showImage = true;
//     });
//   }
//
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     widget.isScheme ? getAllData() : getData();
//     getName();
//   }
//
//
//   String _verticalGroupValue = "Show";
//   String selectedUnit = "";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: Text("Entry Details"),
//         centerTitle: true,
//       ),
//
//       body: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         physics: BouncingScrollPhysics(),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(
//                   hintText: "Enter Area*",
//                   hintStyle: TextStyle(color: Colors.grey),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                 ),
//                 controller: areaController,
//               ),
//
//               Align(
//                 alignment: Alignment.bottomRight,
//                 child: DropDown<dynamic>(
//                   items: ['Squareft', 'Marla'],
//                   hint: Text('units'),
//                   onChanged: (val)
//                   {
//                     setState((){
//                       selectedUnit = val;
//                     });
//                   },
//                 ),
//               ),
//
//               TextFormField(
//                 decoration: InputDecoration(
//                   hintText: "Enter Demand*",
//                   hintStyle: TextStyle(color: Colors.grey),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                 ),
//                 controller: demandController,
//               ),
//
//               SizedBox(
//                 height: 10.0,
//               ),
//
//               TextFormField(
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   hintText: "Enter Details*",
//                   hintStyle: TextStyle(color: Colors.grey),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                 ),
//                 controller: detailsController,
//               ),
//
//               const SizedBox(
//                 height: 10.0,
//               ),
//
//
//               TextFormField(
//                 decoration: InputDecoration(
//                   hintText: "Plot/ Flat/ Khasra*",
//                   hintStyle: TextStyle(color: Colors.grey),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                 ),
//                 controller: plotFlatKharsaraController,
//               ),
//
//               RadioGroup<String>.builder
//                 (
//                   direction: Axis.horizontal,
//                   groupValue: _verticalGroupValue,
//                   textStyle: TextStyle(fontSize: 25),
//                   horizontalAlignment: MainAxisAlignment.spaceAround,
//                   onChanged: (val)
//                   {
//                     if(val == 'Hide')
//                     {
//                       setState(() {
//                         _verticalGroupValue = val!;
//                         isShownPlotInfo = false;
//                       });
//                     }
//                     else
//                     {
//                       setState(() {
//                         _verticalGroupValue = val!;
//                         isShownPlotInfo = true;
//                       });
//                     }
//
//                   },
//                   items: ['Show', 'Hide'],
//                   itemBuilder: (item){
//                     return RadioButtonBuilder(item);
//                   }
//               ),
//
//
//               TextFormField(
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   hintText: "Address*",
//                   labelText: 'Address',
//                   hintStyle: TextStyle(color: Colors.grey),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                 ),
//                 controller: addressController,
//               ),
//
//               Container(
//                 width: MediaQuery.of(context).size.width - 50,
//                 child: MaterialButton(
//                   color: Colors.green,
//                   onPressed: (){
//                     getImage();
//                   },
//                   child:const Text(
//                     'Add Images',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//
//               showImage ? Container(
//                 child: Image(image: FileImage(File(image!.path)),),
//               ): Container(),
//
//
//
//               StylishCustomButton(
//                 text: "Submit",
//                 icon: Icons.check_circle,
//                 onPressed: () async {
//
//                   FocusScope.of(context).unfocus();
//
//                   print(isShownPlotInfo);
//                   if(image != null) {
//                     print("image exist");
//                     Get.defaultDialog(title: "uploading" ,content: CircularProgressIndicator());
//                     final result =await storage.child("location_image").child(DateTime.now().toString());
//                     final fil = await result.putFile(image!.absolute);
//                     final picUrl = await fil.ref.getDownloadURL();
//
//                     //await FirebaseFirestore.instance.collection("plot images").add({"property_image" : imgpath,});
//
//                     await db.add({
//                       "province": provinceId.toString()?? "",
//                       "scheme": typeId.toString() ?? "",
//                       "provinceName": provinceName.toString() ?? "",
//                       "cityName": city.toString() ?? "",
//                       "schemeName": type.toString() ?? "",
//                       "phaseName": phase.toString() ?? "",
//                       "blockName": block.toString() ?? "",
//                       "subBlockName": subBlock.toString() ?? "",
//                       "district": cityId.toString() ?? "",
//                       "phase": phaseId.toString() ?? "",
//                       "block": blockId.toString() ?? "",
//                       "subblock": subBlockId.toString() ?? "",
//                       "adress": addressController.text.toString() ?? "",
//                       "type": propertyType.toString() ?? "",
//                       "subType": subPropertyType.toString() ?? "",
//
//                       "sale": purpose.toString() ?? "",
//                       "sold": "no", // static value used for time being
//                       "area": areaController.text.toString() ?? "",
//                       "areaUnit": selectedUnit.toString() ?? "",
//                       "demand": demandController.text.toString() ?? "",
//                       "description": detailsController.text.toString() ?? "",
//                       "marker_x": null, //widget.marker_x ?? houseModel.marker_x,
//                       "marker_y": null, //widget.marker_y ?? houseModel.marker_y,
//                       "seller": "${auth.currentUser?.uid}",
//                       "name": username.toString(),
//                       "time": DateTime.now(),
//                       'schemeImageURL' : picUrl.toString(),
//                       "isShowPlotInfoToUser": isShownPlotInfo ?? "",
//                       'id': '',
//                       "plotInfo": plotFlatKharsaraController.text.toString() ?? "",
//                       //widget.plotNumber.toString(),
//                     }).then((value){
//                       db.doc(value.id.toString()).update(
//                           {
//                             "id" : value.id.toString(),
//                           }
//                       );
//
//                       print("image ${picUrl}");
//
//                       Get.back();
//                       showMsg('Successful');
//                     }).onError((error, stackTrace){
//                       Get.back();
//                       showMsg('Failed');
//                     });
//
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => mainPage()));
//
//                   }
//                   else
//                   {
//                     print("image does not exist");
//                     Get.defaultDialog(title: "uploading" ,content: CircularProgressIndicator());
//
//                     await db.add({
//                       "province": provinceId.toString()?? "",
//                       "scheme": typeId.toString() ?? "",
//                       "provinceName": provinceName.toString() ?? "",
//                       "cityName": city.toString() ?? "",
//                       "schemeName": type.toString() ?? "",
//                       "phaseName": phase.toString() ?? "",
//                       "blockName": block.toString() ?? "",
//                       "subBlockName": subBlock.toString() ?? "",
//                       "district": cityId.toString() ?? "",
//                       "phase": phaseId.toString() ?? "",
//                       "block": blockId.toString() ?? "",
//                       "subblock": subBlockId.toString() ?? "",
//                       "adress": addressController.text.toString() ?? "",
//                       "type": propertyType.toString() ?? "",
//                       "subType": subPropertyType.toString() ?? "",
//                       // "washroom": widget.washrooms,
//                       // "kitchens": widget.kitchens,
//                       // "basements": widget.basements,
//                       // "floors": widget.floors,
//                       // "parkings": widget.parkings,
//                       // "rooms": widget.rooms,
//                       "sale": purpose.toString() ?? "",
//                       "sold": "no", // static value used for time being
//                       "area": areaController.text.toString() ?? "",
//                       "areaUnit": selectedUnit.toString() ?? "",
//                       "demand": demandController.text.toString() ?? "",
//                       "description": detailsController.text.toString() ?? "",
//                       "marker_x": null, //widget.marker_x ?? houseModel.marker_x,
//                       "marker_y": null, //widget.marker_y ?? houseModel.marker_y,
//                       "seller": "${auth.currentUser?.uid}",
//                       "name": username.toString(),
//                       "time": DateTime.now(),
//                       "schemeImageURL": "",
//                       "isShowPlotInfoToUser": isShownPlotInfo,
//                       "plotInfo": plotFlatKharsaraController.text.toString() ?? "",
//                       //widget.plotNumber.toString(),
//                     }).then((value)async{
//                       Get.back();
//                       showMsg('Successful');
//                     }).onError((error, stackTrace){
//                       Get.back();
//                       showMsg('Failed');
//                     });
//
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => mainPage()));
//
//                   }
//                 },
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// plnr


