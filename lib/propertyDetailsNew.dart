import 'package:carousel_images/carousel_images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:pm_app/chat.dart';

import './widgets/custom_text_widget.dart';
import "./image_preview.dart";
import 'constant.dart';
import 'image_screen.dart';

var provinceName;
var districtName;

fetchUserInfo(id) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userInfo =
      await FirebaseFirestore.instance.collection('users').doc("${id}").get();
  return userInfo;
}

class propertyDetailsNew extends StatefulWidget {
  final data;
  String? currentListingDocumentID;

  propertyDetailsNew(this.data, {this.currentListingDocumentID});

  // @override
  // propertyDetailsState createState() => propertyDetailsState();

  @override
  State<propertyDetailsNew> createState() => _propertyDetailsState();
}

class _propertyDetailsState extends State<propertyDetailsNew> {
  List<String> _allPropertyImages = [];
  String? imgUrl;
  bool loadImage = false;
  final db = FirebaseFirestore.instance;
  Map<String, dynamic>? data;
  bool _isPropertyImagesLoading = false;

  //
  // Future<void> getPropertyImageData()async
  // {
  //   final imgData = await db.collection('listings').snapshots();
  //
  // }

  String dealerName = "";


  Future<void> getAllImages() async {
    _allPropertyImages.clear();
    setState(() {
      _isPropertyImagesLoading = true;
    });
    DocumentSnapshot _snapshot = await FirebaseFirestore.instance
        .collection("plots_images")
        .doc(widget.currentListingDocumentID)
        .get();
    print('Current Listing document id: ${widget.currentListingDocumentID}');
    if (_snapshot.exists == true) {
      print('non empty Listing document');
      for (String imageURL
          in (_snapshot.data() as Map<String, dynamic>).values) {
        _allPropertyImages.add(imageURL.toString());
      }
      print(
          'All images in current listing length: ${_allPropertyImages.length}');
      setState(() {
        print(
            'Current Listing document id: ${widget.currentListingDocumentID}');
      });
    } else {
      print('empty Listing document');
    }
  }


  Future<void> getBusinessName()async
  {
    print("${widget.data['seller']} *****************kjhkugk");
    //
    final da = await db.collection("users").doc(widget.data['seller']).get();
    setState(() {
      dealerName = da['businessName'];
    });

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('init state');
    print("plot info ${widget.data['plotInfo']}");
    getAllImages().then((value) {
      print("All images downloaded from plot_images");
      setState(() {
        _isPropertyImagesLoading = false;
      });
    });
    getBusinessName();
  }

  @override
  Widget build(BuildContext context) {
    Timestamp posted = widget.data["time"];
    DateTime time = widget.data["time"].toDate();
    var timeHours = time.hour;
    var timeMinutes = time.minute;
    var timeCode = "am";
    if (timeHours >= 12) {
      timeHours = timeHours - 12;
      timeCode = "pm";
    }
    var timeFormat =
        "${time.year}-${time.month}-${time.day} $timeHours:$timeMinutes $timeCode ";
    return SafeArea(
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          //DocumentSnapshot doc = snapshot.data.;
          if (snapshot.hasData) {
            data = snapshot.data?.data() as Map<String, dynamic>?;
            // print('Firebase Map: $data');

            return SafeArea(
                child: Scaffold(
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.green,
                elevation: 10,
                //padding: EdgeInsets.all(15),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return chatScreen(widget.data["seller"]);
                  }));
                },
                child: Icon(Icons.message),
              ),
              appBar: AppBar(
                backgroundColor: Colors.green,
                title: Text('Detail'),
              ),
              body: Column(
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("plot_images").snapshots(),
                      builder: (BuildContext context, AsyncSnapshot snapshot)
                          {
                            if(snapshot.hasData)
                              {
                                return InkWell(
                                  onTap: (){
                                    if(widget.data['schemeImageURL'] != "") {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ImageScreen(url: widget
                                                      .data['schemeImageURL'],)));
                                    }
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(7),
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    child:widget.data['schemeImageURL'] == "" ? Image.network("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5V0xbLGXgCE5b9LrnrrawNIaYO6qsZxBxRxkOI9yKtA&s", fit: BoxFit.contain,) : Image.network(widget.data['schemeImageURL'], fit: BoxFit.cover,),
                                  ),
                                );
                              }
                            else
                              {
                                return const Center(child: Text("No Image found"));
                              }

                          }
                  ),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Card(
                            elevation: 12.0,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time),
                                      CustomTextWidget(
                                        text1: ' $timeFormat',
                                        text2: '',
                                      ),
                                    ],
                                  ),
                                  /*view location and demand*/

                                  /*demand and price*/
                                  CustomTextWidget(
                                    text1: 'Demand: ',
                                    text2: '${widget.data["demand"] ?? 'N/A'}',
                                  ),

                                  CustomTextWidget(
                                    text1: 'Sold: ',
                                    text2: '${widget.data["sold"]}',
                                  ),

                                  CustomTextWidget(
                                    text1: 'Posted By: ',
                                    text2: '${widget.data["name"]}',
                                  ),
                                  CustomTextWidget(
                                    text1: 'Dealer: ',
                                    text2: '$dealerName',
                                  ),
                                  widget.data!["isShowPlotInfoToUser"] ? CustomTextWidget(
                                    text1: 'Plot no: ',
                                    text2: "${widget.data!["plotInfo"]}",
                                  ) : Container(),
                                  CustomTextWidget(
                                    text1: 'Property Type: ',
                                    text2:
                                        '${widget.data["type"]} ${widget.data["subType"]}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            margin: EdgeInsets.all(2.0),
                            elevation: 8.0,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextWidget(
                                    text1: 'Listing For: ',
                                    text2: '${widget.data["sale"]}',
                                  ),
                                  CustomTextWidget(
                                    text1: 'Province: ',
                                    text2: '${widget.data["provinceName"]}',
                                  ),
                                  CustomTextWidget(
                                    text1: 'District: ',
                                    text2: '${widget.data["cityName"]}',
                                  ),
                                  CustomTextWidget(
                                    text1: 'Scheme: ',
                                    text2: '${widget.data["schemeName"]}',
                                  ),
                                  CustomTextWidget(
                                    text1: 'Phase: ',
                                    text2: '${widget.data["phaseName"]}',
                                  ),
                                  CustomTextWidget(
                                    text1: 'Block: ',
                                    text2: '${widget.data["blockName"]}',
                                  ),
                                  CustomTextWidget(
                                    text1: 'Sub Block: ',
                                    text2: '${widget.data["subBlockName"]}',
                                  ),
                                  CustomTextWidget(
                                    text1: 'Address: ',
                                    text2: '${widget.data["adress"]}',
                                  ),
                                  CustomTextWidget(
                                    text1: 'Total Area: ',
                                    text2:
                                        '${widget.data["area"]} ${widget.data["areaUnit"]}',
                                  ),
                                 widget.data['isShowPlotInfoToUser'] == false ? Container() : CustomTextWidget(
                                          text1: 'plot/house/room no: ',
                                          text2:
                                              '${widget.data["plotInfo"]}',
                                        ),
                                  /*CustomTextWidget(
                                        text1: 'Floors: ',
                                        text2: '${widget.data["floors"]}',
                                      ),
                                      // Text(
                                      //   " Floors: ${widget.data["floors"]}",
                                      //   style: TextStyle(
                                      //       color: Colors.black,
                                      //       fontFamily: "Times New Roman",
                                      //       fontWeight: FontWeight.w400,
                                      //       fontSize: 20),
                                      // ),
                                      CustomTextWidget(
                                        text1: 'Rooms: ',
                                        text2: '${widget.data["rooms"]}',
                                      ),
                                      // Text(
                                      //   " Rooms: ${widget.data["rooms"]}",
                                      //   style: TextStyle(
                                      //       color: Colors.black,
                                      //       fontFamily: "Times New Roman",
                                      //       fontWeight: FontWeight.w400,
                                      //       fontSize: 20),
                                      // ),
                                      CustomTextWidget(
                                        text1: 'Kitchens: ',
                                        text2: '${widget.data["kitchens"]}',
                                      ),
                                      // Text(
                                      //   " Kitchens: ${widget.data["kitchens"]}",
                                      //   style: TextStyle(
                                      //       color: Colors.black,
                                      //       fontFamily: "Times New Roman",
                                      //       fontWeight: FontWeight.w400,
                                      //       fontSize: 20),
                                      // ),
                                      CustomTextWidget(
                                        text1: 'Washrooms: ',
                                        text2: '${widget.data["washroom"]}',
                                      ),
                                      // Text(
                                      //   " Washrooms: ${widget.data["washroom"]}",
                                      //   style: TextStyle(
                                      //       color: Colors.black,
                                      //       fontFamily: "Times New Roman",
                                      //       fontWeight: FontWeight.w400,
                                      //       fontSize: 20),
                                      // ),
                                      CustomTextWidget(
                                        text1: 'Parkings: ',
                                        text2: '${widget.data["parkings"]}',
                                      ),
                                      // Text(
                                      //   " Parkings: ${widget.data["parkings"]}",
                                      //   style: TextStyle(
                                      //       color: Colors.black,
                                      //       fontFamily: "Times New Roman",
                                      //       fontWeight: FontWeight.w400,
                                      //       fontSize: 20),
                                      // ),*/
                                  /*address component*/
                                  SizedBox(height: 30),
                                  CustomTextWidget(
                                    text1: 'Description: ',
                                  ),

                                  CustomTextWidget(
                                    text1: '',
                                    text2: "${widget.data["description"]}",
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              //},)
            ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
