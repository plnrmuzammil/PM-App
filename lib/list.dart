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
  // List<Widget> _columnList = [];
  final StreamController<QuerySnapshot> _currentStream =
      StreamController<QuerySnapshot>.broadcast();

  final listData = FirebaseFirestore.instance.collection("listings");
  final picsData = FirebaseFirestore.instance.collection("listingsPics");

  //Stream<UserModel> get onCurrentUserChanged => _currentUserStreamCtrl.stream;
  //void updateCurrentUserUI() => _currentUserStreamCtrl.sink.add(_currentUser);

  String _currentIndividualListingID = '';

  Stream<QuerySnapshot>? querySnapShot;
  SimpleDatabase propertySelectedBasedOnRange =
      SimpleDatabase(name: 'propertySearchDialog');
  bool isFilteredExist = false;
  bool isFilteredDataLoading = false;
  bool isShowNoneData = false;
  var picList = [];

  Future<void> getFilterData() async {
    setState(() {
      isFilteredDataLoading = true;
    });
    // print('getFilterData() started');
    Map<String, dynamic> propertySearchDialog = Map<String, dynamic>();
    var result = await propertySelectedBasedOnRange.getAll();
    if (result.length == 0 || result.length == null) {
      // print('(result.length == 0 || result.length == null)');
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

    for (var item in await propertySelectedBasedOnRange.getAll()) {
      print('All Items: $item');
      propertySearchDialog['selectedProvince'] = item['selectedProvince'];
      propertySearchDialog['selectedProvinceID'] = item['selectedProvinceID'];
      propertySearchDialog['selectedCity'] = item['selectedCity'];
      propertySearchDialog['selectedCityID'] = item['selectedCityID'];
      propertySearchDialog['selectPropertySubType'] =
          item['selectPropertySubType'];
      propertySearchDialog['minRange'] = item['minRange'];
      propertySearchDialog['maxRange'] = item['maxRange'];
    }
    print('(var item in await propertySelectedBasedOnRange.getAll())');

    Future<void> querySnap = FirebaseFirestore.instance
        .collection('listings')
        .where(
          'provinceName',
          isEqualTo: propertySearchDialog['selectedProvince'].toLowerCase(),
        )
        .where('cityName',
            isEqualTo: propertySearchDialog['selectedCity'].toLowerCase())
        .where('subType',
            isEqualTo: propertySearchDialog['selectPropertySubType'])
        .where('area',
            isGreaterThanOrEqualTo: propertySearchDialog['minRange'].toString())
        .where('area',
            isLessThanOrEqualTo: propertySearchDialog['maxRange'].toString())
        .get()
        .then((QuerySnapshot query) {
      setState(() {
        //querySnapShot = Stream.fromFuture(Future.value(query));
        isFilteredExist = true;
        isFilteredDataLoading = false;
        print('query adding to a stream: <query Legnth>: ${query.docs.length}');
        _currentStream.sink.add(query);
        if (query.docs.length == 0) {
          isShowNoneData = true;
        }
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
    if (querySnapShot != null) {
      querySnapShot = null;
    }
    super.dispose();
  }

  void CancellingStream() {
    print('add null to stream');
    //_currentStream.sink.add();
    FirebaseFirestore.instance
        .collection("listings")
        .orderBy("time", descending: true)
        .get()
        .then((QuerySnapshot _query) => _currentStream.sink.add(_query));
  }

  void showNoneDataToUser(bool isTrue) {
    setState(() {
      isShowNoneData = true;
    });
  }

  void addToStream(QuerySnapshot _snap) {
    print('add to query snapshot stream');
    _currentStream.sink.add(_snap);
  }

  Future<void> getPicsData(String uid) async {
    print(uid);

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(bottom: 8),
          //height: MediaQuery.of(context).size.height,
          child: Column(
            //shrinkWrap: true,
            children: [


              Expanded(
                child: Container(
                  //height: MediaQuery.of(context).size.height * 0.8,
                  child: isShowNoneData
                      ? Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('No Data Found',
                                  style: TextStyle(fontSize: 26)),
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
                          stream: listData
                              .orderBy('time', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              QuerySnapshot? data = snapshot.data;
                              List<QueryDocumentSnapshot>? documents =
                                  data?.docs;

                              return ListView.builder(
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: documents?.length,
                                  itemBuilder: (context, index) {
                                    bool? check() {
                                      print(currentFilterName);
                                      DocumentSnapshot currentDoc =
                                          documents![index];
                                      var documentData = currentDoc.data();
                                      if (currentFilterName == "province") {
                                        if ((documentData as Map<String,
                                                dynamic>)["provinceName"]
                                            .toString()
                                            .toLowerCase()
                                            .contains(currentSearch.value.text
                                                .toString()
                                                .toLowerCase())) {
                                          return true;
                                        } else {
                                          return false;
                                        }
                                      } else if (currentFilterName == "type") {
                                        if ((documentData
                                                as Map<String, dynamic>)["type"]
                                            .toString()
                                            .toLowerCase()
                                            .contains(currentSearch.value.text
                                                .toString()
                                                .toLowerCase())) {
                                          return true;
                                        } else {
                                          return false;
                                        }
                                      } else if (currentFilterName == "sold") {
                                        if ((documentData
                                                as Map<String, dynamic>)["sold"]
                                            .toString()
                                            .toLowerCase()
                                            .contains(currentSearch.value.text
                                                .toString()
                                                .toLowerCase())) {
                                          return true;
                                        } else {
                                          return false;
                                        }
                                      } else if (currentFilterName == "area") {

                                        if ((documentData as Map<String,
                                                    dynamic>)["area"] !=
                                                null &&
                                            documentData["area"]
                                                .toString()
                                                .isNotEmpty) {
                                          if (int.tryParse(documentData["area"]
                                                      .toString())! >=
                                                  565 &&
                                              int.tryParse(documentData["area"]
                                                      .toString())! <=
                                                  565) {
                                            return true;
                                          } else {
                                            return false;
                                          }
                                        }
                                      }
                                    }

                                    final profilePic = (documents![index].data()
                                            as Map<String, dynamic>)[
                                        "schemeImageURL"];

                                    if (check() == true) {
                                      DateTime time = (documents![index].data()
                                              as Map<String, dynamic>)["time"]
                                          .toDate();
                                      var timeHours = time.hour;
                                      var timeMinutes = time.minute;
                                      var timeCode = "am";
                                      if (timeHours >= 12) {
                                        timeHours = timeHours - 12;
                                        timeCode = "pm";
                                      }
                                      var timeFormat =
                                          "${time.year}-${time.month}-${time.day} $timeHours:$timeMinutes $timeCode ";

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return propertyDetailsNew(
                                              documents[index].data(),
                                              currentListingDocumentID:
                                                  documents[index].id,
                                            );
                                          }));
                                        },
                                        child: Card(
                                          elevation: 8,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 0,
                                                  color: Colors.white),
                                            ),
                                            margin: const EdgeInsets.all(0),
                                            // margin: EdgeInsets.only(
                                            //     bottom: 40, left: 5, right: 5),
                                            padding: EdgeInsets.all(10),
                                            child: Container(


                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundImage: profilePic !=
                                                            ''
                                                        ? NetworkImage(
                                                            (documents[index]
                                                                            .data()
                                                                        as Map<
                                                                            String,
                                                                            dynamic>)[
                                                                    "schemeImageURL"] ??
                                                                '',
                                                          )
                                                        : NetworkImage(
                                                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5V0xbLGXgCE5b9LrnrrawNIaYO6qsZxBxRxkOI9yKtA&s"),


                                                    backgroundColor:
                                                        Colors.blue,
                                                    radius: 40,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Flexible(
                                                    child: Stack(
                                                      children: [
                                                        //show the stripe if its sold otherwise show nothing
                                                        (documents[index].data()
                                                                        as Map<
                                                                            String,
                                                                            dynamic>)[
                                                                    "sold"] ==
                                                                "yes"
                                                            ? Positioned(
                                                                right: 5, // 10
                                                                top: -25, // -15
                                                                //width: 29,
                                                                //height: 70,
                                                                child: Transform
                                                                    .rotate(
                                                                  angle: -0.8,
                                                                  child:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    margin:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            0),
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 0,
                                                                        left: 0,
                                                                        right:
                                                                            0,
                                                                        bottom:
                                                                            13),
                                                                    color: Colors
                                                                        .red,
                                                                    //width: 30,
                                                                    height: 105,
                                                                    child: Transform
                                                                        .rotate(
                                                                      angle:
                                                                          1.6,
                                                                      child:
                                                                          Text(
                                                                        'Sold',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(),

                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // for time
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Icon(
                                                                    Icons
                                                                        .timer_rounded,
                                                                    color:
                                                                        GreyColorWriting),
                                                                const SizedBox(
                                                                    width: 3),
                                                                Text(
                                                                  timeFormat,
                                                                  style: const TextStyle(
                                                                      color:
                                                                          GreyColorWriting,
                                                                      fontFamily:
                                                                          "Times New Roman",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Container(

                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 210,
                                                                    child: Text(
                                                                      "Scheme : ${(documents[index].data() as Map<String, dynamic>)["schemeName"]}",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          1,
                                                                      softWrap:
                                                                          true,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              GreyColorWriting,
                                                                          fontFamily:
                                                                              "Times New Roman",
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // demand
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    "Demand : ${(documents[index].data() as Map<String, dynamic>)["demand"]}",
                                                                    // overflow:
                                                                    //     TextOverflow
                                                                    //         .ellipsis,
                                                                    maxLines: 1,
                                                                    style:textstyleMainCard,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            (documents[index].data()
                                                                                as Map<String, dynamic>)[
                                                                            "isShowPlotInfoToUser"] ==
                                                                        true ||
                                                                    (documents[index].data() as Map<
                                                                            String,
                                                                            dynamic>)["isShowPlotInfoToUser"] ==
                                                                        false
                                                                ? Container()
                                                                : FittedBox(
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Text(
                                                                          "plot/house/room no: ",
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style: TextStyle(
                                                                              color: GreyColorWriting,
                                                                              fontFamily: "Times New Roman",
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 16),
                                                                        ),
                                                                        Text(
                                                                          "${(documents[index].data() as Map<String, dynamic>)["plotInfo"]}",
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style: const TextStyle(
                                                                              color: Colors.orangeAccent,
                                                                              fontFamily: "Times New Roman",
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 20),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                            // province name
                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    "City : ${(documents[index].data() as Map<String, dynamic>)["cityName"]}",
                                                                    // overflow:
                                                                    //     TextOverflow
                                                                    //         .ellipsis,
                                                                    //maxLines: 2,
                                                                    style: textstyleMainCard
                                                                  ),
                                                                ),

                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    "Province : ${(documents[index].data() as Map<String, dynamic>)["provinceName"]}",
                                                                    // overflow:
                                                                    //     TextOverflow
                                                                    //         .ellipsis,
                                                                    //maxLines: 2,
                                                                    style: textstyleMainCard
                                                                  ),
                                                                ),
                                                                // const Icon(
                                                                //   Icons
                                                                //       .location_on,
                                                                //   size: 20,
                                                                // )
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
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  });
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
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


class RangePropertyDialog extends StatefulWidget {
  Function refresh;
  Function addToStream;
  Function showNoneDataToUser;

  RangePropertyDialog(
      {required this.refresh,
      required this.addToStream,
      required this.showNoneDataToUser});

  @override
  RangePropertyDialogState createState() => RangePropertyDialogState();
}

class RangePropertyDialogState extends State<RangePropertyDialog> {
  Future<void> getAllCitiesFromFirebase() async {
    print('invoked.....getAllCitiesFromFirebase()');
    QuerySnapshot _snapshot = await FirebaseFirestore.instance
        .collection("cities")
        .orderBy("name", descending: false)
        .get();

    _allCityFromFirebase = [];
    _allCityIDFromFirebase = [];

    print(
        'city snapshot length: ${(_snapshot.docs.length as Map<String, dynamic>)}');
    //var el = _snapshot.docs;
    for (var e in _snapshot.docs) {
      if (e.data() != null) {
        print('current province id: $currentProvinceID');
        if ((e.data() as Map<String, dynamic>)["provinceID"] ==
            currentProvinceID) {
          _allCityFromFirebase.add((e.data() as Map<String, dynamic>)["name"]);
          _allCityIDFromFirebase.add((e.data() as Map<String, dynamic>)["id"]);
        }
      }
    }
    print('all cities names from firebase: $_allCityFromFirebase');
    setState(() {});
  }

  List<String> _allProvinceFromFirebase = [];
  List<String> _allProvinceIDFromFirebase = [];
  String currentProvinceID = '';

  List<String> _allCityFromFirebase = [];
  List<String> _allCityIDFromFirebase = [];
  String? currentCityID;

  bool _isProvinceSelected = false;
  bool _isCitySelected = false;

  bool _isSubTypeSelected = false;
  bool _isRangeSelected = false;

  String selectedProvince = 'Khyber Pakhtunkhwa';
  String selectedCity = '';
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

  SimpleDatabase propertySelectedBasedOnRange =
      SimpleDatabase(name: 'propertySearchDialog');
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
          _allProvinceFromFirebase
              .add((e.data() as Map<String, dynamic>)["name"]);
          _allProvinceIDFromFirebase
              .add((e.data() as Map<String, dynamic>)["id"]);
        }
      }

      setState(() {});

      propertyDialogData = SimpleDatabase(name: 'propertySearchDialog');
      propertyDialogData?.getAll().then((List<dynamic> userData) {
        isLoading = false;

        if (userData.length > 0) {
          selectedProvince = userData[0]['selectedProvince'];
          selectedCity = userData[0]['selectedCity'];
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
                      int provinceIndex =
                          _allProvinceFromFirebase.indexOf(val.toString());
                      print('province index: $provinceIndex');
                      if (provinceIndex != -1 && provinceIndex != null) {
                        currentProvinceID =
                            _allProvinceIDFromFirebase[provinceIndex]
                                .toString();
                        print('current province ID: $currentProvinceID');
                        print('province selected: $_isProvinceSelected');
                        setState(() {});
                        await getAllCitiesFromFirebase();
                      }
                    },
                  ),
                  SizedBox(height: 5),
                  // city
                  DropDown(
                    items: _allCityFromFirebase,
                    hint: selectedCity.length > 0
                        ? Text(selectedCity)
                        : Text("select city"),
                    onChanged: _allCityFromFirebase.length > 0
                        ? (val) async {
                            print('onChanged callback');
                            selectedCity = val.toString();
                            currentCityID = _allCityIDFromFirebase[
                                    _allCityFromFirebase
                                        .indexOf(val.toString())]
                                .toString();
                            print('selected city ID: $currentCityID');

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
                      }),
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
                            "300-500"
                          ],
                          hint: Text(minRange.toString()),
                          onChanged: (String? val) async {
                            _isRangeSelected = true;
                            print('overall range: $val');
                            var minMaxValue = val?.split('-');
                            minRange = int.tryParse(minMaxValue![0])!;

                            maxRange = int.tryParse(minMaxValue[1])!;
                            print(
                                'Splitting value range: ${minMaxValue.length}');
                            print(
                                'Min Range Complex: ${int.tryParse(minMaxValue[0])}');
                            print(
                                'Max Range Complex: ${int.tryParse(minMaxValue[1])}');
                          }),

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
                      }),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      // search button
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            print('Selected province: $selectedProvince');
                            print('Selected province ID: $currentProvinceID');
                            print('Selected city: $selectedCity');
                            print('Selected city ID: $currentCityID');
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
                          propertySearchDialog['selectedCity'] = selectedCity;
                          propertySearchDialog['selectedCityID'] =
                              currentCityID;
                          propertySearchDialog['selectPropertySubType'] =
                              propertySubType;
                          propertySearchDialog['minRange'] = minRange;
                          propertySearchDialog['maxRange'] = maxRange;
                          propertySearchDialog['areaUnit'] = areaUnit;

                          await propertySelectedBasedOnRange
                              .add(propertySearchDialog);

                          print('Range Based Property Selection attribute: ');
                          Future<QuerySnapshot> querySnap;
                          for (var item
                              in await propertySelectedBasedOnRange.getAll()) {
                            print('item: $item');
                          }
                          if (_isRangeSelected && _isSubTypeSelected) {
                            print(
                                "if (_isRangeSelected && _isSubTypeSelected) ");
                            querySnap = FirebaseFirestore.instance
                                .collection('listings')
                                .where(
                                  'provinceName',
                                  isEqualTo: selectedProvince,
                                )
                                .where('cityName', isEqualTo: selectedCity)
                                .where('subType', isEqualTo: propertySubType)
                                .where('area',
                                    isGreaterThanOrEqualTo: minRange.toString())
                                .where('area',
                                    isLessThanOrEqualTo: maxRange.toString())
                                .get();
                          } else if (_isSubTypeSelected &&
                              _isRangeSelected == false) {
                            print(
                                "if (_isSubTypeSelected &&_isRangeSelected == false) ");
                            querySnap = FirebaseFirestore.instance
                                .collection('listings')
                                .where(
                                  'provinceName',
                                  isEqualTo: selectedProvince,
                                )
                                .where('cityName', isEqualTo: selectedCity)
                                .where('subType', isEqualTo: propertySubType)
                                .
                                //where('area', isGreaterThanOrEqualTo: minRange.toString()).
                                //where('area', isLessThanOrEqualTo: maxRange.toString()).
                                get();
                          } else if (_isRangeSelected &&
                              _isSubTypeSelected == false) {
                            print(
                                "if (_isRangeSelected && _isSubTypeSelected == false)");
                            print(
                                '_isRangeSelected && _isSubTypeSelected == false');
                            querySnap = FirebaseFirestore.instance
                                .collection('listings')
                                .where(
                                  'provinceName',
                                  isEqualTo: selectedProvince,
                                )
                                .where('cityName', isEqualTo: selectedCity)
                                .where('area',
                                    isGreaterThanOrEqualTo: minRange.toString())
                                .where('area',
                                    isLessThanOrEqualTo: maxRange.toString())
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
                                .where('cityName', isEqualTo: selectedCity)
                                .

                                get();
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
            child: Text(
          'No Data Found',
          textAlign: TextAlign.center,
        )),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('ok')),
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
