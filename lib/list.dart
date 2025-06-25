import 'dart:async';

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
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
  final picsData = FirebaseFirestore.instance.collection("listingsPics");

  String _currentIndividualListingID = '';
  Stream<QuerySnapshot>? querySnapShot;
  SimpleDatabase propertySelectedBasedOnRange = SimpleDatabase(
    name: 'propertySearchDialog',
  );
  bool isFilteredExist = false;
  bool isFilteredDataLoading = false;
  bool isShowNoneData = false;
  var picList = [];

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
      propertySearchDialog['selectedProvince'] = item['selectedProvince']?.toString() ?? '';
      propertySearchDialog['selectedProvinceID'] = item['selectedProvinceID']?.toString() ?? '';
      propertySearchDialog['selectedDistrict'] = item['selectedDistrict']?.toString() ?? '';
      propertySearchDialog['selectedDistrictID'] = item['selectedDistrictID']?.toString() ?? '';
      propertySearchDialog['selectPropertySubType'] = item['selectPropertySubType']?.toString() ?? '';
      propertySearchDialog['minRange'] = int.tryParse(item['minRange']?.toString() ?? '0') ?? 0;
      propertySearchDialog['maxRange'] = int.tryParse(item['maxRange']?.toString() ?? '0') ?? 0;
    }

    await FirebaseFirestore.instance
        .collection('listings')
        .where(
      'provinceName',
      isEqualTo: (propertySearchDialog['selectedProvince'] as String).toLowerCase(),
    )
        .where(
      'districtName',
      isEqualTo: (propertySearchDialog['selectedDistrict'] as String).toLowerCase(),
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
    querySnapShot = null;
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

  void showNoneDataToUser(bool isTrue) {
    setState(() {
      isShowNoneData = isTrue;
    });
  }

  void addToStream(QuerySnapshot _snap) {
    _currentStream.sink.add(_snap);
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
                child: Container(
                  child: isShowNoneData
                      ? Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No Data Found',
                          style: TextStyle(fontSize: 26),
                        ),
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
                    ),
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
                          final docData = documents[index].data() as Map<String, dynamic>;

                          // Safe data extraction with defaults
                          final schemeName = docData["schemeName"]?.toString() ?? 'N/A';
                          final demand = docData["demand"]?.toString() ?? 'N/A';
                          final districtName = docData["districtName"]?.toString() ?? 'N/A';
                          final provinceName = docData["provinceName"]?.toString() ?? 'N/A';
                          final plotInfo = docData["plotInfo"]?.toString() ?? '';
                          final soldStatus = docData["sold"]?.toString() ?? 'no';
                          final profilePic = docData["schemeImageURL"]?.toString() ?? '';
                          final isShowPlotInfo = docData["isShowPlotInfoToUser"] ?? false;

                          DateTime? time;
                          try {
                            time = (docData["time"] as Timestamp?)?.toDate();
                          } catch (e) {
                            time = DateTime.now();
                          }

                          var timeHours = time?.hour;
                          var timeMinutes = time?.minute;
                          var timeCode = "am";
                          if (timeHours! >= 12) {
                            timeHours = timeHours - 12;
                            timeCode = "pm";
                          }
                          final timeFormat = "${time?.year}-${time?.month}-${time?.day} $timeHours:$timeMinutes $timeCode";

                          bool check() {
                            final searchText = currentSearch.value.text.toString().toLowerCase();
                            switch (currentFilterName) {
                              case "province":
                                return (docData["provinceName"]?.toString() ?? '').toLowerCase().contains(searchText);
                              case "type":
                                return (docData["type"]?.toString() ?? '').toLowerCase().contains(searchText);
                              case "sold":
                                return (docData["sold"]?.toString() ?? '').toLowerCase().contains(searchText);
                              case "area":
                                final area = int.tryParse(docData["area"]?.toString() ?? '0') ?? 0;
                                return area >= 565 && area <= 565;
                              default:
                                return false;
                            }
                          }

                          if (!check()) {
                            return Container();
                          }

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
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 0,
                                    color: Colors.white,
                                  ),
                                ),
                                margin: const EdgeInsets.all(0),
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: profilePic.isNotEmpty
                                          ? NetworkImage(profilePic)
                                          : const NetworkImage(
                                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5V0xbLGXgCE5b9LrnrrawNIaYO6qsZxBxRxkOI9yKtA&s",
                                      ),
                                      backgroundColor: Colors.blue,
                                      radius: 40,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Stack(
                                        children: [
                                          if (soldStatus == "yes")
                                            Positioned(
                                              right: 5,
                                              top: -25,
                                              child: Transform.rotate(
                                                angle: -0.8,
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  margin: const EdgeInsets.all(0),
                                                  padding: const EdgeInsets.only(bottom: 13),
                                                  color: Colors.red,
                                                  height: 105,
                                                  child: Transform.rotate(
                                                    angle: 1.6,
                                                    child: const Text(
                                                      'Sold',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                    Icons.timer_rounded,
                                                    color: GreyColorWriting,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    timeFormat,
                                                    style: const TextStyle(
                                                      color: GreyColorWriting,
                                                      fontFamily: "Times New Roman",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                width: 210,
                                                child: Text(
                                                  "Scheme : $schemeName",
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                    color: GreyColorWriting,
                                                    fontFamily: "Times New Roman",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      "Demand : $demand",
                                                      maxLines: 1,
                                                      style: textstyleMainCard,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (!isShowPlotInfo && plotInfo.isNotEmpty)
                                                FittedBox(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        "plot/house/room no: ",
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          color: GreyColorWriting,
                                                          fontFamily: "Times New Roman",
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      Text(
                                                        plotInfo,
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(
                                                          color: Colors.orangeAccent,
                                                          fontFamily: "Times New Roman",
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      "District : $districtName",
                                                      style: textstyleMainCard,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      "Province : $provinceName",
                                                      style: textstyleMainCard,
                                                    ),
                                                  ),
                                                ],
                                              ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Rest of your code for RangePropertyDialog, AlertErrorWidget, and ProgressWidget remains the same
// [Previous code for these classes can be kept as is]


/// plnr
///
///
///
class RangePropertyDialog extends StatefulWidget {
  Function refresh;
  Function addToStream;
  Function showNoneDataToUser;

  RangePropertyDialog({
    required this.refresh,
    required this.addToStream,
    required this.showNoneDataToUser,
  });

  @override
  RangePropertyDialogState createState() => RangePropertyDialogState();
}

class RangePropertyDialogState extends State<RangePropertyDialog> {
  Future<void> getAllDistrictsFromFirebase() async {
    print('invoked.....getAllDistrictsFromFirebase()');
    QuerySnapshot _snapshot = await FirebaseFirestore.instance
        .collection("districts")
        .orderBy("name", descending: false)
        .get();

    _allDistrictFromFirebase = [];
    _allDistrictIDFromFirebase = [];

    print(
      'district snapshot length: ${(_snapshot.docs.length as Map<String, dynamic>)}',
    );
    //var el = _snapshot.docs;
    for (var e in _snapshot.docs) {
      if (e.data() != null) {
        print('current province id: $currentProvinceID');
        if ((e.data() as Map<String, dynamic>)["provinceID"] ==
            currentProvinceID) {
          _allDistrictFromFirebase.add(
            (e.data() as Map<String, dynamic>)["name"],
          );
          _allDistrictFromFirebase.add(
            (e.data() as Map<String, dynamic>)["id"],
          );
        }
      }
    }
    print('all districts names from firebase: $_allDistrictFromFirebase');
    setState(() {});
  }

  List<String> _allProvinceFromFirebase = [];
  List<String> _allProvinceIDFromFirebase = [];
  String currentProvinceID = '';

  List<String> _allDistrictFromFirebase = [];
  List<String> _allDistrictIDFromFirebase = [];
  String? currentDistrictID;

  bool _isProvinceSelected = false;
  bool _isDistrictSelected = false;

  bool _isSubTypeSelected = false;
  bool _isRangeSelected = false;

  String selectedProvince = 'Khyber Pakhtunkhwa';
  String selectedDistrict = '';
  String propertySubType = '';
  int minRange = 0;
  int maxRange = 0;
  String areaUnit = '';

  List<String> subtypes = [
    'Food Court',
    "Factory",
    "Gym",
    "Hall",
    "Office",
    "Shop",
    "Theatre",
    "Warehouse",
    'Farm House',
    'Guest House',
    'Hostel',
    'House',
    'Penthouse',
    "Room",
    'Villas',
    'Commercial Land',
    'Residential Land',
    'Plot File',
  ];

  SimpleDatabase propertySelectedBasedOnRange = SimpleDatabase(
    name: 'propertySearchDialog',
  );
  int _totalRecord = 0;

  SimpleDatabase? propertyDialogData;
  bool isLoading = false;

  @override
  void initState() {
    propertySelectedBasedOnRange.count().then((value) => _totalRecord = value);
    setState(() {
      isLoading = true;
    });
    super.initState();
    print('init state...range dialog');
    FirebaseFirestore.instance
        .collection("province")
        .orderBy("name", descending: false)
        .get()
        .then((QuerySnapshot _snapshot) {
          var el = _snapshot.docs;
          _allProvinceFromFirebase = [];
          for (var e in el) {
            if (e.data() != null) {
              _allProvinceFromFirebase.add(
                (e.data() as Map<String, dynamic>)["name"],
              );
              _allProvinceIDFromFirebase.add(
                (e.data() as Map<String, dynamic>)["id"],
              );
            }
          }

          setState(() {});

          propertyDialogData = SimpleDatabase(name: 'propertySearchDialog');
          propertyDialogData?.getAll().then((List<dynamic> userData) {
            isLoading = false;

            if (userData.length > 0) {
              selectedProvince = userData[0]['selectedProvince'];
              selectedDistrict = userData[0]['selectedDistrict'];
              propertySubType = userData[0]['selectPropertySubType'];
              minRange = userData[0]['minRange'];
              maxRange = userData[0]['maxRange'];
              areaUnit = userData[0]['areaUnit'];
            } else {
              print('no user stored filter data found');
            }
            setState(() {});
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: isLoading
          ? Container(child: Center(child: CircularProgressIndicator()))
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              //width: 200,
              height: 355,
              child: ListView(
                //mainAxisAlignment: MainAxisAlignment.start,
                //crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filter',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  // province
                  DropDown(
                    items: _allProvinceFromFirebase,
                    hint: selectedProvince.length > 0
                        ? Text(selectedProvince)
                        : Text("select province"),
                    //initialValue: _allProvinceFromFirebase.length == 0 ? selectedProvince : null,
                    onChanged: (val) async {
                      print('onChanged callback');
                      selectedProvince = val.toString();
                      print('selected province: $val');
                      int provinceIndex = _allProvinceFromFirebase.indexOf(
                        val.toString(),
                      );
                      print('province index: $provinceIndex');
                      if (provinceIndex != -1 && provinceIndex != null) {
                        currentProvinceID =
                            _allProvinceIDFromFirebase[provinceIndex]
                                .toString();
                        print('current province ID: $currentProvinceID');
                        print('province selected: $_isProvinceSelected');
                        setState(() {});
                        await getAllDistrictsFromFirebase();
                      }
                    },
                  ),
                  SizedBox(height: 5),
                  // district
                  DropDown(
                    items: _allDistrictFromFirebase,
                    hint: selectedDistrict.length > 0
                        ? Text(selectedDistrict)
                        : Text("select District"),
                    onChanged: _allDistrictFromFirebase.length > 0
                        ? (val) async {
                            print('onChanged callback');
                            selectedDistrict = val.toString();
                            currentDistrictID =
                                _allDistrictIDFromFirebase[_allDistrictFromFirebase
                                        .indexOf(val.toString())]
                                    .toString();
                            print('selected district ID: $currentDistrictID');

                            // setState(() {
                            //   _isCitySelected = true;
                            // });
                          }
                        : null,
                  ),
                  SizedBox(height: 5),

                  //sub type
                  DropDown(
                    items: subtypes,
                    hint: propertySubType.length > 0
                        ? Text(propertySubType)
                        : Text("select sub type"),
                    onChanged: (val) async {
                      _isSubTypeSelected = true;
                      propertySubType = val.toString();
                      print('onChanged callback');
                      // setState(() {
                      //   _isSubTypeSelected = true;
                      // });
                    },
                  ),
                  SizedBox(height: 5),

                  /*Row for min and max drop down*/
                  Row(
                    children: [
                      DropDown(
                        items: const [
                          "0-5",
                          "10-20",
                          "30-50",
                          "100-200",
                          "300-500",
                        ],
                        hint: Text(minRange.toString()),
                        onChanged: (String? val) async {
                          _isRangeSelected = true;
                          print('overall range: $val');
                          var minMaxValue = val?.split('-');
                          minRange = int.tryParse(minMaxValue![0])!;

                          maxRange = int.tryParse(minMaxValue[1])!;
                          print('Splitting value range: ${minMaxValue.length}');
                          print(
                            'Min Range Complex: ${int.tryParse(minMaxValue[0])}',
                          );
                          print(
                            'Max Range Complex: ${int.tryParse(minMaxValue[1])}',
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  // drop down for area unit
                  DropDown(
                    items: ["Squareft", "Marla"],
                    hint: areaUnit.length > 0
                        ? Text(areaUnit)
                        : Text("Select Unit"),
                    onChanged: (val) async {
                      areaUnit = val.toString();
                    },
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      // search button
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            print('Selected province: $selectedProvince');
                            print('Selected province ID: $currentProvinceID');
                            print('Selected district: $selectedDistrict');
                            print('Selected district ID: $currentDistrictID');
                            print('property sub type: $propertySubType');
                            print('Min Range: $minRange');
                            print('Max Range: $maxRange');

                            print('setState() selected....');
                            // setting up the database
                          });
                          SimpleDatabase propertySelectedBasedOnRange =
                              SimpleDatabase(name: 'propertySearchDialog');
                          await propertySelectedBasedOnRange.clear();
                          Map<String, dynamic> propertySearchDialog =
                              Map<String, dynamic>();

                          propertySearchDialog['selectedProvince'] =
                              selectedProvince;
                          propertySearchDialog['selectedProvinceID'] =
                              currentProvinceID;
                          propertySearchDialog['selectedDistrict'] =
                              selectedDistrict;
                          propertySearchDialog['selectedDistrictID'] =
                              currentDistrictID;
                          propertySearchDialog['selectPropertySubType'] =
                              propertySubType;
                          propertySearchDialog['minRange'] = minRange;
                          propertySearchDialog['maxRange'] = maxRange;
                          propertySearchDialog['areaUnit'] = areaUnit;

                          await propertySelectedBasedOnRange.add(
                            propertySearchDialog,
                          );

                          print('Range Based Property Selection attribute: ');
                          Future<QuerySnapshot> querySnap;
                          for (var item
                              in await propertySelectedBasedOnRange.getAll()) {
                            print('item: $item');
                          }
                          if (_isRangeSelected && _isSubTypeSelected) {
                            print(
                              "if (_isRangeSelected && _isSubTypeSelected) ",
                            );
                            querySnap = FirebaseFirestore.instance
                                .collection('listings')
                                .where(
                                  'provinceName',
                                  isEqualTo: selectedProvince,
                                )
                                .where(
                                  'districtName',
                                  isEqualTo: selectedDistrict,
                                )
                                .where('subType', isEqualTo: propertySubType)
                                .where(
                                  'area',
                                  isGreaterThanOrEqualTo: minRange.toString(),
                                )
                                .where(
                                  'area',
                                  isLessThanOrEqualTo: maxRange.toString(),
                                )
                                .get();
                          } else if (_isSubTypeSelected &&
                              _isRangeSelected == false) {
                            print(
                              "if (_isSubTypeSelected &&_isRangeSelected == false) ",
                            );
                            querySnap = FirebaseFirestore.instance
                                .collection('listings')
                                .where(
                                  'provinceName',
                                  isEqualTo: selectedProvince,
                                )
                                .where(
                                  'districtName',
                                  isEqualTo: selectedDistrict,
                                )
                                .where('subType', isEqualTo: propertySubType)
                                .
                                //where('area', isGreaterThanOrEqualTo: minRange.toString()).
                                //where('area', isLessThanOrEqualTo: maxRange.toString()).
                                get();
                          } else if (_isRangeSelected &&
                              _isSubTypeSelected == false) {
                            print(
                              "if (_isRangeSelected && _isSubTypeSelected == false)",
                            );
                            print(
                              '_isRangeSelected && _isSubTypeSelected == false',
                            );
                            querySnap = FirebaseFirestore.instance
                                .collection('listings')
                                .where(
                                  'provinceName',
                                  isEqualTo: selectedProvince,
                                )
                                .where(
                                  'districtName',
                                  isEqualTo: selectedDistrict,
                                )
                                .where(
                                  'area',
                                  isGreaterThanOrEqualTo: minRange.toString(),
                                )
                                .where(
                                  'area',
                                  isLessThanOrEqualTo: maxRange.toString(),
                                )
                                .get();
                          } else {
                            print("else");
                            // rand sub type both are not selected
                            querySnap = FirebaseFirestore.instance
                                .collection('listings')
                                .where(
                                  'provinceName',
                                  isEqualTo: selectedProvince,
                                )
                                .where(
                                  'districtName',
                                  isEqualTo: selectedDistrict,
                                )
                                .get();
                          }

                          print('pre loading');

                          querySnap.then((QuerySnapshot _snap) async {
                            if (_snap.docs.length == 0) {
                              // no data found
                              print('if- Total Docs: ${_snap.docs.length}');
                              //widget.addToStream(QuerySnapshot);
                              // TODO: show no data to user on the screen

                              await showDialog(
                                context: context,
                                builder: (context) => AlertErrorWidget(),
                              );
                              widget.showNoneDataToUser(true);
                              //return;
                              //AlertErrorWidget();
                            } else {
                              // data found
                              print('else- Total Docs: ${_snap.docs.length}');
                              widget.addToStream(_snap);
                              Navigator.of(context).pop();
                              //Navigator.of(context).pop(Stream.fromFuture(Future.value(_snap)));
                            }
                          });

                          print('post loading');
                          int totalDocuments = -1;
                        },
                        child: Text('search'),
                      ),
                      // exit button
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: Text('Exit'),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: _totalRecord > 0
                            ? () async {
                                await propertySelectedBasedOnRange.clear();
                                widget.refresh();
                                Navigator.of(context).pop();
                              }
                            : null,
                        child: Text('clear Filter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class AlertErrorWidget extends StatefulWidget {
  const AlertErrorWidget({Key? key}) : super(key: key);

  @override
  _AlertErrorWidgetState createState() => _AlertErrorWidgetState();
}

class _AlertErrorWidgetState extends State<AlertErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: AlertDialog(
        title: Text('Searched Data'),
        content: Container(
          child: Text('No Data Found', textAlign: TextAlign.center),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('ok'),
          ),
        ],
      ),
    );
  }
}

class ProgressWidget extends StatefulWidget {
  const ProgressWidget({Key? key}) : super(key: key);

  @override
  _ProgressWidgetState createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> {
  @override
  void initState() {
    print('progress widget init');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}
