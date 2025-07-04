// import 'dart:async';
//
// import "package:cloud_firestore/cloud_firestore.dart";
// import "package:flutter/material.dart";
// import 'package:flutter_dropdown/flutter_dropdown.dart';
// import 'package:pm_app/constant.dart';
// import 'package:pm_app/propertyDetailsNew.dart';
// import 'package:simple_database/simple_database.dart';
//
// var provinceName;
// var schemeName;
// var currentFilterValue = 0;
// var currentFilterName = "province";
// TextEditingController currentSearch = TextEditingController();
// var filters = ["province", "type", "sold", "area"];
//
// class list extends StatefulWidget {
//   @override
//   _listState createState() => _listState();
// }
//
// class _listState extends State<list> {
//   final StreamController<QuerySnapshot> _currentStream =
//   StreamController<QuerySnapshot>.broadcast();
//
//   final listData = FirebaseFirestore.instance.collection("listings");
//   final picsData = FirebaseFirestore.instance.collection("listingsPics");
//
//   String _currentIndividualListingID = '';
//   Stream<QuerySnapshot>? querySnapShot;
//   SimpleDatabase propertySelectedBasedOnRange = SimpleDatabase(
//     name: 'propertySearchDialog',
//   );
//   bool isFilteredExist = false;
//   bool isFilteredDataLoading = false;
//   bool isShowNoneData = false;
//   var picList = [];
//
//   Future<void> getFilterData() async {
//     setState(() {
//       isFilteredDataLoading = true;
//     });
//
//     Map<String, dynamic> propertySearchDialog = {};
//     var result = await propertySelectedBasedOnRange.getAll();
//
//     if (result.isEmpty) {
//       QuerySnapshot _query = await FirebaseFirestore.instance
//           .collection("listings")
//           .orderBy("time", descending: true)
//           .get();
//
//       _currentStream.sink.add(_query);
//
//       setState(() {
//         isFilteredExist = false;
//         isFilteredDataLoading = false;
//       });
//       return;
//     }
//
//     for (var item in result) {
//       propertySearchDialog['selectedProvince'] = item['selectedProvince']?.toString() ?? '';
//       propertySearchDialog['selectedProvinceID'] = item['selectedProvinceID']?.toString() ?? '';
//       propertySearchDialog['selectedDistrict'] = item['selectedDistrict']?.toString() ?? '';
//       propertySearchDialog['selectedDistrictID'] = item['selectedDistrictID']?.toString() ?? '';
//       propertySearchDialog['selectPropertySubType'] = item['selectPropertySubType']?.toString() ?? '';
//       propertySearchDialog['minRange'] = int.tryParse(item['minRange']?.toString() ?? '0') ?? 0;
//       propertySearchDialog['maxRange'] = int.tryParse(item['maxRange']?.toString() ?? '0') ?? 0;
//     }
//
//     await FirebaseFirestore.instance
//         .collection('listings')
//         .where(
//       'provinceName',
//       isEqualTo: (propertySearchDialog['selectedProvince'] as String).toLowerCase(),
//     )
//         .where(
//       'districtName',
//       isEqualTo: (propertySearchDialog['selectedDistrict'] as String).toLowerCase(),
//     )
//         .where(
//       'subType',
//       isEqualTo: propertySearchDialog['selectPropertySubType'],
//     )
//         .where(
//       'area',
//       isGreaterThanOrEqualTo: propertySearchDialog['minRange'].toString(),
//     )
//         .where(
//       'area',
//       isLessThanOrEqualTo: propertySearchDialog['maxRange'].toString(),
//     )
//         .get()
//         .then((QuerySnapshot query) {
//       setState(() {
//         isFilteredExist = true;
//         isFilteredDataLoading = false;
//         _currentStream.sink.add(query);
//         isShowNoneData = query.docs.isEmpty;
//       });
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     getFilterData();
//   }
//
//   @override
//   void dispose() {
//     querySnapShot = null;
//     _currentStream.close();
//     super.dispose();
//   }
//
//   void CancellingStream() {
//     FirebaseFirestore.instance
//         .collection("listings")
//         .orderBy("time", descending: true)
//         .get()
//         .then((QuerySnapshot _query) => _currentStream.sink.add(_query));
//   }
//
//   void showNoneDataToUser(bool isTrue) {
//     setState(() {
//       isShowNoneData = isTrue;
//     });
//   }
//
//   void addToStream(QuerySnapshot _snap) {
//     _currentStream.sink.add(_snap);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Container(
//           padding: const EdgeInsets.only(bottom: 8),
//           child: Column(
//             children: [
//               Expanded(
//                 child: Container(
//                   child: isShowNoneData
//                       ? Container(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'No Data Found',
//                           style: TextStyle(fontSize: 26),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             propertySelectedBasedOnRange.clear();
//                             CancellingStream();
//                             setState(() {
//                               isShowNoneData = false;
//                             });
//                           },
//                           child: const Text('Show All Data'),
//                         ),
//                       ],
//                     ),
//                   )
//                       : StreamBuilder<QuerySnapshot>(
//                     stream: listData.orderBy('time', descending: true).snapshots(),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//
//                       final documents = snapshot.data!.docs;
//
//                       return ListView.builder(
//                         shrinkWrap: true,
//                         physics: const BouncingScrollPhysics(),
//                         itemCount: documents.length,
//                         itemBuilder: (context, index) {
//                           final docData = documents[index].data() as Map<String, dynamic>;
//
//                           // Safe data extraction with defaults
//                           final schemeName = docData["schemeName"]?.toString() ?? 'N/A';
//                           final demand = docData["demand"]?.toString() ?? 'N/A';
//                           final districtName = docData["districtName"]?.toString() ?? 'N/A';
//                           final provinceName = docData["provinceName"]?.toString() ?? 'N/A';
//                           final plotInfo = docData["plotInfo"]?.toString() ?? '';
//                           final soldStatus = docData["sold"]?.toString() ?? 'no';
//                           final profilePic = docData["propertyImagesURL"]?.toString() ?? '';
//                           final isShowPlotInfo = docData["isShowPlotInfoToUser"] ?? false;
//
//                           DateTime? time;
//                           try {
//                             time = (docData["time"] as Timestamp?)?.toDate();
//                           } catch (e) {
//                             time = DateTime.now();
//                           }
//
//                           var timeHours = time?.hour;
//                           var timeMinutes = time?.minute;
//                           var timeCode = "am";
//                           if (timeHours! >= 12) {
//                             timeHours = timeHours - 12;
//                             timeCode = "pm";
//                           }
//                           final timeFormat = "${time?.year}-${time?.month}-${time?.day} $timeHours:$timeMinutes $timeCode";
//
//                           bool check() {
//                             final searchText = currentSearch.value.text.toString().toLowerCase();
//                             switch (currentFilterName) {
//                               case "province":
//                                 return (docData["provinceName"]?.toString() ?? '').toLowerCase().contains(searchText);
//                               case "type":
//                                 return (docData["type"]?.toString() ?? '').toLowerCase().contains(searchText);
//                               case "sold":
//                                 return (docData["sold"]?.toString() ?? '').toLowerCase().contains(searchText);
//                               case "area":
//                                 final area = int.tryParse(docData["area"]?.toString() ?? '0') ?? 0;
//                                 return area >= 565 && area <= 565;
//                               default:
//                                 return false;
//                             }
//                           }
//
//                           if (!check()) {
//                             return Container();
//                           }
//
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => PropertyDetailsNew(
//                                     docData,
//                                     currentListingDocumentID: documents[index].id,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Card(
//                               elevation: 8,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     width: 0,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 margin: const EdgeInsets.all(0),
//                                 padding: const EdgeInsets.all(10),
//                                 child: Row(
//                                   children: [
//                                     CircleAvatar(
//                                       backgroundImage: profilePic.isNotEmpty
//                                           ? NetworkImage(profilePic)
//                                           : const NetworkImage(
//                                         "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5V0xbLGXgCE5b9LrnrrawNIaYO6qsZxBxRxkOI9yKtA&s",
//                                       ),
//                                       backgroundColor: Colors.blue,
//                                       radius: 40,
//                                     ),
//                                     const SizedBox(width: 5),
//                                     Flexible(
//                                       child: Stack(
//                                         children: [
//                                           if (soldStatus == "yes")
//                                             Positioned(
//                                               right: 5,
//                                               top: -25,
//                                               child: Transform.rotate(
//                                                 angle: -0.8,
//                                                 child: Container(
//                                                   alignment: Alignment.centerLeft,
//                                                   margin: const EdgeInsets.all(0),
//                                                   padding: const EdgeInsets.only(bottom: 13),
//                                                   color: Colors.red,
//                                                   height: 105,
//                                                   child: Transform.rotate(
//                                                     angle: 1.6,
//                                                     child: const Text(
//                                                       'Sold',
//                                                       style: TextStyle(
//                                                         fontWeight: FontWeight.bold,
//                                                         color: Colors.white,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.start,
//                                                 children: [
//                                                   const Icon(
//                                                     Icons.timer_rounded,
//                                                     color: GreyColorWriting,
//                                                   ),
//                                                   const SizedBox(width: 3),
//                                                   Text(
//                                                     timeFormat,
//                                                     style: const TextStyle(
//                                                       color: GreyColorWriting,
//                                                       fontFamily: "Times New Roman",
//                                                       fontWeight: FontWeight.w700,
//                                                       fontSize: 14,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               const SizedBox(height: 10),
//                                               SizedBox(
//                                                 width: 210,
//                                                 child: Text(
//                                                   "Scheme : $schemeName",
//                                                   overflow: TextOverflow.ellipsis,
//                                                   maxLines: 1,
//                                                   softWrap: true,
//                                                   style: const TextStyle(
//                                                     color: GreyColorWriting,
//                                                     fontFamily: "Times New Roman",
//                                                     fontWeight: FontWeight.w700,
//                                                     fontSize: 14,
//                                                   ),
//                                                 ),
//                                               ),
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                 children: [
//                                                   Flexible(
//                                                     child: Text(
//                                                       "Demand : $demand",
//                                                       maxLines: 1,
//                                                       style: textstyleMainCard,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               if (!isShowPlotInfo && plotInfo.isNotEmpty)
//                                                 FittedBox(
//                                                   child: Row(
//                                                     mainAxisAlignment: MainAxisAlignment.start,
//                                                     mainAxisSize: MainAxisSize.min,
//                                                     children: [
//                                                       const Text(
//                                                         "plot/house/room no: ",
//                                                         textAlign: TextAlign.left,
//                                                         style: TextStyle(
//                                                           color: GreyColorWriting,
//                                                           fontFamily: "Times New Roman",
//                                                           fontWeight: FontWeight.w700,
//                                                           fontSize: 16,
//                                                         ),
//                                                       ),
//                                                       Text(
//                                                         plotInfo,
//                                                         textAlign: TextAlign.left,
//                                                         style: const TextStyle(
//                                                           color: Colors.orangeAccent,
//                                                           fontFamily: "Times New Roman",
//                                                           fontWeight: FontWeight.w700,
//                                                           fontSize: 20,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.start,
//                                                 children: [
//                                                   Flexible(
//                                                     child: Text(
//                                                       "District : $districtName",
//                                                       style: textstyleMainCard,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.start,
//                                                 children: [
//                                                   Flexible(
//                                                     child: Text(
//                                                       "Province : $provinceName",
//                                                       style: textstyleMainCard,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//plnr

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:pm_app/constant.dart';
import 'package:pm_app/propertyDetailsNew.dart';
import 'package:simple_database/simple_database.dart';

var provinceName;
var schemeName;
var currentFilterValue = 0;
var currentFilterName = "province";
TextEditingController currentSearch = TextEditingController();
var filters = ["province", "type", "sold", "area"];

class list extends StatefulWidget {
  @override
  _listState createState() => _listState();
}

class _listState extends State<list> {
  final StreamController<QuerySnapshot> _currentStream =
  StreamController<QuerySnapshot>.broadcast();

  final listData = FirebaseFirestore.instance.collection("listings");

  SimpleDatabase propertySelectedBasedOnRange = SimpleDatabase(
    name: 'propertySearchDialog',
  );

  bool isFilteredExist = false;
  bool isFilteredDataLoading = false;
  bool isShowNoneData = false;

  Future<void> getFilterData() async {
    setState(() {
      isFilteredDataLoading = true;
    });

    Map<String, dynamic> propertySearchDialog = {};
    var result = await propertySelectedBasedOnRange.getAll();

    if (result.isEmpty) {
      QuerySnapshot _query = await FirebaseFirestore.instance
          .collection("listings")
          .orderBy("time", descending: true)
          .get();

      _currentStream.sink.add(_query);

      setState(() {
        isFilteredExist = false;
        isFilteredDataLoading = false;
      });
      return;
    }

    for (var item in result) {
      propertySearchDialog['selectedProvince'] =
          item['selectedProvince']?.toString() ?? '';
      propertySearchDialog['selectedDistrict'] =
          item['selectedDistrict']?.toString() ?? '';
      propertySearchDialog['selectPropertySubType'] =
          item['selectPropertySubType']?.toString() ?? '';
      propertySearchDialog['minRange'] =
          int.tryParse(item['minRange']?.toString() ?? '0') ?? 0;
      propertySearchDialog['maxRange'] =
          int.tryParse(item['maxRange']?.toString() ?? '0') ?? 0;
    }

    await FirebaseFirestore.instance
        .collection('listings')
        .where(
      'provinceName',
      isEqualTo:
      (propertySearchDialog['selectedProvince'] as String).toLowerCase(),
    )
        .where(
      'districtName',
      isEqualTo:
      (propertySearchDialog['selectedDistrict'] as String).toLowerCase(),
    )
        .where(
      'subType',
      isEqualTo: propertySearchDialog['selectPropertySubType'],
    )
        .where(
      'area',
      isGreaterThanOrEqualTo: propertySearchDialog['minRange'].toString(),
    )
        .where(
      'area',
      isLessThanOrEqualTo: propertySearchDialog['maxRange'].toString(),
    )
        .get()
        .then((QuerySnapshot query) {
      setState(() {
        isFilteredExist = true;
        isFilteredDataLoading = false;
        _currentStream.sink.add(query);
        isShowNoneData = query.docs.isEmpty;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getFilterData();
  }

  @override
  void dispose() {
    _currentStream.close();
    super.dispose();
  }

  void CancellingStream() {
    FirebaseFirestore.instance
        .collection("listings")
        .orderBy("time", descending: true)
        .get()
        .then((QuerySnapshot _query) => _currentStream.sink.add(_query));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              Expanded(
                child: isShowNoneData
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No Data Found', style: TextStyle(fontSize: 26)),
                    TextButton(
                      onPressed: () {
                        propertySelectedBasedOnRange.clear();
                        CancellingStream();
                        setState(() {
                          isShowNoneData = false;
                        });
                      },
                      child: const Text('Show All Data'),
                    ),
                  ],
                )
                    : StreamBuilder<QuerySnapshot>(
                  stream: listData.orderBy('time', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final documents = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final docData =
                        documents[index].data() as Map<String, dynamic>;

                        final propertyLocation = docData["typeName"]?.toString() ?? 'N/A';
                        final demand = docData["demand"]?.toString() ?? 'N/A';
                        final districtName = docData["districtName"]?.toString() ?? 'N/A';
                        final provinceName = docData["provinceName"]?.toString() ?? 'N/A';
                        final plotInfo = docData["plotInfo"]?.toString() ?? '';
                        final soldStatus = docData["sold"]?.toString() ?? 'no';
                        final isShowPlotInfo = docData["isShowPlotInfoToUser"] ?? false;

                        // 🖼️ Image handling (corrected)
                        final List<dynamic> imageList = docData["propertyImagesURL"] ?? [];
                        final profilePic = imageList.isNotEmpty
                            ? imageList[0].toString()
                            : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5V0xbLGXgCE5b9LrnrrawNIaYO6qsZxBxRxkOI9yKtA&s";

                        DateTime time;
                        try {
                          time = (docData["time"] as Timestamp?)?.toDate() ?? DateTime.now();
                        } catch (e) {
                          time = DateTime.now();
                        }
                        var timeHours = time.hour;
                        var timeMinutes = time.minute;
                        var timeCode = "am";

                        if (timeHours >= 12) {
                          timeHours -= 12;
                          timeCode = "pm";
                        }

                        final timeFormat = "${time.year}-${time.month}-${time.day} $timeHours:$timeMinutes $timeCode";

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyDetailsNew(
                                  docData,
                                  currentListingDocumentID: documents[index].id,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(profilePic),
                                    radius: 40,
                                    backgroundColor: Colors.grey[200],
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        if (soldStatus == "yes")
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              color: Colors.red,
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 8),
                                              child: const Text(
                                                'SOLD',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.timer_rounded,
                                                    size: 16, color: GreyColorWriting),
                                                const SizedBox(width: 3),
                                                Text(
                                                  timeFormat,
                                                  style: const TextStyle(
                                                    color: GreyColorWriting,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text("Property Location: $propertyLocation",
                                                overflow: TextOverflow.ellipsis,
                                                style: textstyleMainCard),
                                            Text("Demand: $demand",
                                                style: textstyleMainCard),
                                            if (!isShowPlotInfo && plotInfo.isNotEmpty)
                                              Row(
                                                children: [
                                                  const Text("plot/house no: ",
                                                      style: TextStyle(
                                                          color: GreyColorWriting,
                                                          fontWeight: FontWeight.w700)),
                                                  Text(plotInfo,
                                                      style: const TextStyle(
                                                        color: Colors.orangeAccent,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                ],
                                              ),
                                            Text("District: $districtName",
                                                style: textstyleMainCard),
                                            Text("Province: $provinceName",
                                                style: textstyleMainCard),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
