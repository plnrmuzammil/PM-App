import 'dart:async';
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:pm_app/constant.dart';
import 'package:pm_app/propertyDetailsNew.dart';
import 'package:simple_database/simple_database.dart';

import '../main.dart';

class ViewListings extends StatefulWidget {
  final String subBlock;
  static String? subBlockListing;

  ViewListings({required this.subBlock}) {
    subBlockListing = subBlock;
  }

  @override
  _ViewListingsState createState() => _ViewListingsState();
}

class _ViewListingsState extends State<ViewListings> {
  final StreamController<QuerySnapshot> _currentStream = StreamController<QuerySnapshot>();
  Stream<QuerySnapshot>? querySnapShot;
  SimpleDatabase listingPropertySelectedBasedOnRange = SimpleDatabase(name: 'listingPropertySearchDialog3');
  bool isFilteredExist = false;
  bool isFilteredDataLoading = false;
  bool isShowNoneData = false;

  // Helper method to safely convert Firestore data to displayable string
  String _safeGetString(dynamic value) {
    if (value == null) return 'N/A';
    if (value is List) {
      // Handle empty lists
      if (value.isEmpty) return 'N/A';
      // Convert each item to string and join with commas
      return value.map((e) => e?.toString() ?? 'N/A').join(', ');
    }
    return value.toString();
  }

  void cancellingStream() {
    FirebaseFirestore.instance
        .collection("listings")
        .where('provinceName', isEqualTo: listingModel.province)
        .where('districtName', isEqualTo: listingModel.district)
        .where("subblock", isEqualTo: widget.subBlock)
        .orderBy("time", descending: true)
        .get()
        .then((QuerySnapshot _query) {
      _currentStream.sink.add(_query);
    });
  }

  Future<void> getFilterData() async {
    setState(() => isFilteredDataLoading = true);

    final result = await listingPropertySelectedBasedOnRange.getAll();
    if (result.isEmpty) {
      final query = await FirebaseFirestore.instance
          .collection("listings")
          .where('provinceName', isEqualTo: listingModel.province)
          .where('districtName', isEqualTo: listingModel.district)
          .where("subblock", isEqualTo: widget.subBlock)
          .get();

      _currentStream.sink.add(query);
      setState(() {
        isFilteredExist = false;
        isFilteredDataLoading = false;
      });
      return;
    }

    final propertySearchDialog = <String, dynamic>{};
    for (var item in result) {
      propertySearchDialog['selectedProvince'] = item['selectedProvince']?.toString();
      propertySearchDialog['selectedDistrict'] = item['selectedDistrict']?.toString();
      propertySearchDialog['selectPropertySubType'] = item['selectPropertySubType']?.toString();
      propertySearchDialog['minRange'] = int.tryParse(item['minRange']?.toString() ?? '0') ?? 0;
      propertySearchDialog['maxRange'] = int.tryParse(item['maxRange']?.toString() ?? '0') ?? 0;
    }

    await FirebaseFirestore.instance
        .collection('listings')
        .where('provinceName', isEqualTo: propertySearchDialog['selectedProvince'])
        .where('districtName', isEqualTo: propertySearchDialog['selectedDistrict'])
        .where('subType', isEqualTo: propertySearchDialog['selectPropertySubType'])
        .where('area', isGreaterThanOrEqualTo: propertySearchDialog['minRange'].toString())
        .where('area', isLessThanOrEqualTo: propertySearchDialog['maxRange'].toString())
        .where("subblock", isEqualTo: widget.subBlock)
        .get()
        .then((QuerySnapshot query) {
      setState(() {
        isFilteredExist = true;
        isFilteredDataLoading = false;
        isShowNoneData = query.docs.isEmpty;
      });
      _currentStream.sink.add(query);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Listing'),
        actions: [
          IconButton(
            onPressed: () async {
              querySnapShot = await showDialog(
                context: context,
                builder: (context) => ListingRangeDialog(
                  refresh: cancellingStream,
                  addToStream: (snap) => _currentStream.sink.add(snap),
                  showNoneDataToUser: (val) => setState(() => isShowNoneData = val),
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.filter_list),
          )
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: isShowNoneData
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No Data Found', style: TextStyle(fontSize: 26)),
              TextButton(
                onPressed: () {
                  listingPropertySelectedBasedOnRange.clear();
                  cancellingStream();
                  setState(() => isShowNoneData = false);
                },
                child: const Text('Show All Data'),
              ),
            ],
          )
              : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("listings")
                .where("subblock", isEqualTo: widget.subBlock)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final documents = snapshot.data!.docs;
              if (documents.isEmpty) {
                return const Center(child: Text('No Content'));
              }

              return ListView.builder(
                itemCount: documents.length,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final docData = documents[index].data() as Map<String, dynamic>;
                  final time = (docData["time"] as Timestamp).toDate();
                  final timeFormat = _formatTime(time);

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PropertyDetailsNew(docData),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      child: Card(
                        elevation: 8,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: _getImageProvider(
                                  (docData["schemeImageURL"] is List && docData["schemeImageURL"].isNotEmpty)
                                      ? docData["schemeImageURL"][0]
                                      : null,
                                ),
                                backgroundColor: Colors.blue,
                                radius: 40,
                              ),

                              const SizedBox(width: 5),
                              Flexible(
                                child: Stack(
                                  children: [
                                    if (docData["sold"] == "yes") _buildSoldBadge(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.timer_rounded),
                                            const SizedBox(width: 3),
                                            Text(timeFormat),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: 210,
                                          child: Text(
                                            "Scheme: ${_safeGetString(docData["schemeName"])}",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        Text("Demand: ${_safeGetString(docData["demand"])}"),
                                        Row(
                                          children: [
                                            const Text("Posted By:"),
                                            Text(_safeGetString(docData["name"]),
                                                style: const TextStyle(color: Colors.orangeAccent)),
                                          ],
                                        ),
                                        if (docData["isShowPlotInfoToUser"] == true)
                                          Row(
                                            children: [
                                              const Text("Plot Info:"),
                                              Text(_safeGetString(docData["plotInfo"]),
                                                  style: const TextStyle(color: Colors.orangeAccent)),
                                            ],
                                          ),
                                        Text("District: ${_safeGetString(docData["districtName"])}"),
                                        Text("Province: ${_safeGetString(docData["provinceName"])}"),
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
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hours = time.hour > 12 ? time.hour - 12 : time.hour;
    final amPm = time.hour >= 12 ? 'pm' : 'am';
    return "${time.year}-${time.month}-${time.day} $hours:${time.minute} $amPm";
  }

  ImageProvider _getImageProvider(dynamic url) {
    if (url is String && url.isNotEmpty) {
      return NetworkImage(url);
    } else {
      return const NetworkImage("https://via.placeholder.com/150");
    }
  }


  Widget _buildSoldBadge() {
    return Positioned(
      right: 5,
      top: -25,
      child: Transform.rotate(
        angle: -0.8,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(bottom: 13),
          color: Colors.red,
          height: 105,
          child: Transform.rotate(
            angle: 1.6,
            child: const Text(
              'Sold',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class ListingRangeDialog extends StatefulWidget {
  final Function() refresh;
  final Function(QuerySnapshot) addToStream;
  final Function(bool) showNoneDataToUser;

  const ListingRangeDialog({
    required this.refresh,
    required this.addToStream,
    required this.showNoneDataToUser,
    Key? key,
  }) : super(key: key);

  @override
  _ListingRangeDialogState createState() => _ListingRangeDialogState();
}

class _ListingRangeDialogState extends State<ListingRangeDialog> {
  String? propertySubType;
  int minRange = 0;
  int maxRange = 0;
  String areaUnit = '';
  int _totalRecord = 0;
  bool isLoading = false;

  final List<String> subtypes = [
    'Food Court', 'Factory', 'Gym', 'Hall', 'Office',
    'Shop', 'Theatre', 'Warehouse', 'Farm House',
    'Guest House', 'Hostel', 'House', 'Penthouse',
    'Room', 'Villas', 'Commercial Land', 'Residential Land', 'Plot File',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedFilters();
  }

  Future<void> _loadSavedFilters() async {
    setState(() => isLoading = true);
    final db = SimpleDatabase(name: 'listingPropertySearchDialog2');
    final result = await db.getAll();

    if (result.isNotEmpty) {
      setState(() {
        propertySubType = result[0]['selectPropertySubType']?.toString();
        minRange = int.tryParse(result[0]['minRange']?.toString() ?? '0') ?? 0;
        maxRange = int.tryParse(result[0]['maxRange']?.toString() ?? '0') ?? 0;
        areaUnit = result[0]['areaUnit']?.toString() ?? '';
      });
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropDown(
              items: subtypes,
              hint: propertySubType != null ? Text(propertySubType!) : const Text("Select sub type"),
              onChanged: (String? val) => setState(() => propertySubType = val),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                DropDown(
                  items: const [5, 10, 20, 50, 100],
                  hint: Text(minRange.toString()),
                  onChanged: (int? val) => setState(() => minRange = val ?? 0),
                ),
                const Spacer(),
                DropDown(
                  items: const [300, 500, 1000, 2000, 4000, 5000],
                  hint: Text(maxRange.toString()),
                  onChanged: (int? val) => setState(() => maxRange = val ?? 0),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropDown(
              items: const ["Squareft", "Marla", "Canal", "Acre", "Hectare"],
              hint: areaUnit.isNotEmpty ? Text(areaUnit) : const Text("Select Unit"),
              onChanged: (String? val) => setState(() => areaUnit = val ?? ''),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: _applyFilters,
                  child: const Text('Search'),
                ),
                TextButton(
                  onPressed: _totalRecord > 0 ? _clearFilters : null,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyFilters() async {
    final filters = {
      'selectedProvince': listingModel.province,
      'selectedDistrict': listingModel.district,
      'selectPropertySubType': propertySubType,
      'minRange': minRange,
      'maxRange': maxRange,
      'areaUnit': areaUnit,
    };

    final db = SimpleDatabase(name: 'listingPropertySearchDialog2');
    await db.clear();
    await db.add(filters);

    Query query = FirebaseFirestore.instance
        .collection('listings')
        .where('provinceName', isEqualTo: listingModel.province)
        .where('districtName', isEqualTo: listingModel.district)
        .where("subblock", isEqualTo: ViewListings.subBlockListing);

    if (propertySubType != null) {
      query = query.where('subType', isEqualTo: propertySubType);
    }
    if (minRange > 0 || maxRange > 0) {
      query = query
          .where('area', isGreaterThanOrEqualTo: minRange.toString())
          .where('area', isLessThanOrEqualTo: maxRange.toString());
    }

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      widget.showNoneDataToUser(true);
      Navigator.pop(context);
    } else {
      widget.addToStream(snapshot);
      Navigator.pop(context);
    }
  }

  Future<void> _clearFilters() async {
    final db = SimpleDatabase(name: 'listingPropertySearchDialog2');
    await db.clear();
    widget.refresh();
    Navigator.pop(context);
  }
}