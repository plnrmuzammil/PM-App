import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pm_app/non_scheme_property_details_new.dart';

import '../non_scheme_property_details.dart';

class ViewNonSchemeListing extends StatefulWidget {
  const ViewNonSchemeListing({Key? key, this.scheme}) : super(key: key);


  final scheme;

  @override
  State<ViewNonSchemeListing> createState() => _ViewNonSchemeListingState();
}

class _ViewNonSchemeListingState extends State<ViewNonSchemeListing> {

  final db = FirebaseFirestore.instance.collection("listings");
  QuerySnapshot? _snap;
  List<DocumentSnapshot>? documentSnapshot;
  
  String subType = "";
  String maxRange = "";
  String minRange = "";
  String unit = "";
  bool isFilter = false;

  List<String> subtypes =[
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
    'Commercial',
    'Residential',
    'Land / Plot',
  ];


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("View listing"),
        actions: [
          IconButton(
              onPressed: ()
              {
                Get.defaultDialog(title: "Filter",radius: 0.0 , content: Container(
                  height: 250.0,
                  width: 300,
                  child: ListView(
                    children: [

                      Text(
                        'Filter',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      
                      DropDown(
                          items: subtypes,
                          hint: Text("select sub type"),
                          onChanged: (val)
                          {
                            setState(() {
                              subType = val.toString();
                            });
                          }),
                      
                      const SizedBox(height: 5),
                      
                      Row(
                        children: [
                          DropDown(
                              items: [5, 10, 20, 50, 100],
                              hint: Text("select min Range"),
                              onChanged: (val) async
                              {
                                setState(() {
                                  minRange = val.toString();
                                });
                              }),
                          Spacer(),
                          DropDown(
                              items: [300, 500, 1000, 2000, 4000, 5000],
                              hint: Text("select max range"),
                              onChanged: (val)
                              {
                                setState(() {
                                  maxRange = val.toString();
                                });
                              }
                              ),
                        ],
                      ),

                      SizedBox(height: 5),

                      DropDown(
                          items: ["Squareft", "Marla", "Canal", "Acre", "Hectare"],
                          hint: Text("Select Unit"),
                          onChanged: (val) async {
                            setState((){
                              unit = val.toString();
                            });
                          },),

                      SizedBox(height: 5),
                      Row(
                        children: [

                          TextButton(
                            onPressed:()
                            {
                              Get.back();
                              setState(() {
                                isFilter = true;
                              });
                              print("scheme ${widget.scheme}");
                              print("syb type ${subType}");
                            },
                            child: Text('search'),
                          ),

                          TextButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            child: Text('Exit'),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('clear Filter'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
              },
              icon: Icon(Icons.filter_list_sharp))
        ],
      ),
      body: isFilter ? StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("listings")
            .where('scheme', isEqualTo: "${widget.scheme}").where('type', isEqualTo: '${subType}')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
        {
          if(snapshot.hasData)
          {
            QuerySnapshot? querySnapshot = snapshot.data;
            List<QueryDocumentSnapshot> documents = querySnapshot!.docs;

            print("document length ${documents.length}");

            if(documents.length != 0)
            {
              return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index)
                  {
                    DateTime time = (documents[index].data() as Map<String, dynamic>)['time'].toDate();
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
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => NonSchemePropertyDetailsNew(
                          data: documents[index].data(),
                        )));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        child: Card(
                          elevation: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 0,
                                  color: Colors.white
                              ),
                            ),
                            margin: const EdgeInsets.all(0),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [

                                (documents[index].data() as Map<String, dynamic>)['schemeImageURL'] == null ?
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 40,
                                  child: Text("No Image"),
                                ) : CircleAvatar(
                                  backgroundImage: NetworkImage((documents[index].data() as Map<String, dynamic>)['schemeImageURL']),
                                  backgroundColor: Colors.blue,
                                  radius: 40,
                                ),


                                SizedBox(
                                  width: 5,
                                ),
                                Flexible(
                                  child: Stack(
                                    children: [
                                      //show the stripe if its sold otherwise show nothing
                                      ( documents[index].data()as Map<String,dynamic>)[
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
                                            margin: const EdgeInsets
                                                .all(0),
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
                                              Icon(Icons
                                                  .timer_rounded),
                                              SizedBox(
                                                  width: 3),
                                              Text(
                                                "$timeFormat",
                                                style:const TextStyle(
                                                    color: Colors
                                                        .black,
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
                                          const  SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            // width:
                                            //     MediaQuery.of(
                                            //             context)
                                            //         .size
                                            //         .width,
                                            //---------
                                            /*for scheme*/
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .start,
                                              children: [
                                                SizedBox(
                                                  width: 170,
                                                  child: Text(
                                                    "Scheme : ${(documents[index].data()as Map<String,dynamic>)["schemeName"]}",
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    maxLines:
                                                    2,
                                                    softWrap:
                                                    true,
                                                    style: TextStyle(
                                                        color: Colors
                                                            .black,
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
                                                  "Demand : ${(documents[index].data()as Map<String,dynamic>)["demand"]}",
                                                  // overflow:
                                                  //     TextOverflow
                                                  //         .ellipsis,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      color: Colors
                                                          .black,
                                                      fontFamily:
                                                      "Times New Roman",
                                                      fontWeight:
                                                      FontWeight
                                                          .w700,
                                                      fontSize:
                                                      14),
                                                ),
                                              ),
                                            ],
                                          ),
                                          //posted by
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .start,
                                            children: [
                                              const Text(
                                                "Posted By:",
                                                textAlign:
                                                TextAlign
                                                    .left,
                                                style:TextStyle(
                                                    color: Colors
                                                        .black,
                                                    fontFamily:
                                                    "Times New Roman",
                                                    fontWeight:
                                                    FontWeight
                                                        .w700,
                                                    fontSize:
                                                    16),
                                              ),
                                              Text(
                                                "${(documents[index].data()as Map<String,dynamic>)["businessName"]}",
                                                textAlign:
                                                TextAlign
                                                    .left,
                                                style:const TextStyle(
                                                    color: Colors
                                                        .orangeAccent,
                                                    fontFamily:
                                                    "Times New Roman",
                                                    fontWeight:
                                                    FontWeight
                                                        .w700,
                                                    fontSize:
                                                    20),
                                              ),
                                            ],
                                          ),
                                          // plot info
                                          (documents[index].data()as Map<String,dynamic>)[
                                          "isShowPlotInfoToUser"] ==
                                              null ||
                                              (documents[index]
                                                  .data()as Map<String,dynamic>)["isShowPlotInfoToUser"] ==
                                                  false
                                              ? Container()
                                              : Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .start,
                                            children: [
                                              const Text(
                                                "Plot Info:",
                                                textAlign:
                                                TextAlign.left,
                                                style: TextStyle(
                                                    color: Colors
                                                        .black,
                                                    fontFamily:
                                                    "Times New Roman",
                                                    fontWeight:
                                                    FontWeight.w700,
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                "${(documents[index].data()as Map<String,dynamic>)["plotInfo"]}",
                                                textAlign:
                                                TextAlign.left,
                                                style:const TextStyle(
                                                    color: Colors
                                                        .orangeAccent,
                                                    fontFamily:
                                                    "Times New Roman",
                                                    fontWeight:
                                                    FontWeight.w700,
                                                    fontSize: 20),
                                              ),
                                            ],
                                          ),
                                          // province name
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .start,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  "Province : ${(documents[index].data()as Map<String,dynamic>)["cityName"]} ${(documents[index].data()as Map<String,dynamic>)["provinceName"]}",
                                                  // overflow:
                                                  //     TextOverflow
                                                  //         .ellipsis,
                                                  //maxLines: 2,
                                                  style:const TextStyle(
                                                      color: Colors
                                                          .black,
                                                      fontFamily:
                                                      "Times New Roman",
                                                      fontWeight:
                                                      FontWeight
                                                          .w700,
                                                      fontSize:
                                                      14),
                                                ),
                                              ),
                                              const Icon(
                                                Icons
                                                    .location_on,
                                                size: 30,
                                              )
                                            ],
                                          ),
                                          // seller info

                                          /*Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                StreamBuilder(
                                                                  stream: FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "users")
                                                                      .doc(documents[index]
                                                                              .data()[
                                                                          "seller"])
                                                                      .snapshots(),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (snapshot
                                                                        .hasData) {
                                                                      return Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            "Seller : ",
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontFamily: "Times New Roman",
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: 14),
                                                                          ),
                                                                          Text(
                                                                            "${snapshot.data.data()["businessName"]}",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.deepOrangeAccent,
                                                                              fontFamily: "Times New Roman",
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 14,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.fade,
                                                                          )
                                                                        ],
                                                                      );
                                                                    } else {
                                                                      return Text(
                                                                          "LOADING");
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ),*/
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
                  }
              );
            }
            else
            {
              return const Center(
                child: Text("No Content"),
              );
            }
          }
          else
          {
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ) : StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("listings")
            .where('scheme', isEqualTo: "${widget.scheme}")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
        {

          if(snapshot.hasData)
          {
            QuerySnapshot? querySnapshot = snapshot.data;
            List<QueryDocumentSnapshot> documents = querySnapshot!.docs;

            if(documents.length != 0)
            {
              return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index)
                  {
                    DateTime time = (documents[index].data() as Map<String, dynamic>)['time'].toDate();
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
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => NonSchemePropertyDetailsNew(
                          data: documents[index].data(),
                        )));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        child: Card(
                          elevation: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 0,
                                  color: Colors.white
                              ),
                            ),
                            margin: const EdgeInsets.all(0),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [

                                (documents[index].data() as Map<String, dynamic>)['schemeImageURL'] == null ?
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 40,
                                  child: Text("No Image"),
                                ) : CircleAvatar(
                                  backgroundImage: NetworkImage((documents[index].data() as Map<String, dynamic>)['schemeImageURL']),
                                  backgroundColor: Colors.blue,
                                  radius: 40,
                                ),


                                SizedBox(
                                  width: 5,
                                ),
                                Flexible(
                                  child: Stack(
                                    children: [
                                      //show the stripe if its sold otherwise show nothing
                                      ( documents[index].data()as Map<String,dynamic>)[
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
                                            margin: const EdgeInsets
                                                .all(0),
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
                                              Icon(Icons
                                                  .timer_rounded),
                                              SizedBox(
                                                  width: 3),
                                              Text(
                                                "$timeFormat",
                                                style:const TextStyle(
                                                    color: Colors
                                                        .black,
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
                                          const  SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            // width:
                                            //     MediaQuery.of(
                                            //             context)
                                            //         .size
                                            //         .width,
                                            //---------
                                            /*for scheme*/
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .start,
                                              children: [
                                                SizedBox(
                                                  width: 170,
                                                  child: Text(
                                                    "Scheme : ${(documents[index].data()as Map<String,dynamic>)["schemeName"]}",
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    maxLines:
                                                    2,
                                                    softWrap:
                                                    true,
                                                    style: TextStyle(
                                                        color: Colors
                                                            .black,
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
                                                  "Demand : ${(documents[index].data()as Map<String,dynamic>)["demand"]}",
                                                  // overflow:
                                                  //     TextOverflow
                                                  //         .ellipsis,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      color: Colors
                                                          .black,
                                                      fontFamily:
                                                      "Times New Roman",
                                                      fontWeight:
                                                      FontWeight
                                                          .w700,
                                                      fontSize:
                                                      14),
                                                ),
                                              ),
                                            ],
                                          ),
                                          //posted by
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .start,
                                            children: [
                                              const Text(
                                                "Posted By:",
                                                textAlign:
                                                TextAlign
                                                    .left,
                                                style:TextStyle(
                                                    color: Colors
                                                        .black,
                                                    fontFamily:
                                                    "Times New Roman",
                                                    fontWeight:
                                                    FontWeight
                                                        .w700,
                                                    fontSize:
                                                    16),
                                              ),
                                              Text(
                                                "${(documents[index].data()as Map<String,dynamic>)["businessName"]}",
                                                textAlign:
                                                TextAlign
                                                    .left,
                                                style:const TextStyle(
                                                    color: Colors
                                                        .orangeAccent,
                                                    fontFamily:
                                                    "Times New Roman",
                                                    fontWeight:
                                                    FontWeight
                                                        .w700,
                                                    fontSize:
                                                    20),
                                              ),
                                            ],
                                          ),
                                          // plot info
                                          (documents[index].data()as Map<String,dynamic>)[
                                          "isShowPlotInfoToUser"] ==
                                              null ||
                                              (documents[index]
                                                  .data()as Map<String,dynamic>)["isShowPlotInfoToUser"] ==
                                                  false
                                              ? Container()
                                              : Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .start,
                                            children: [
                                              const Text(
                                                "Plot Info:",
                                                textAlign:
                                                TextAlign.left,
                                                style: TextStyle(
                                                    color: Colors
                                                        .black,
                                                    fontFamily:
                                                    "Times New Roman",
                                                    fontWeight:
                                                    FontWeight.w700,
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                "${(documents[index].data()as Map<String,dynamic>)["plotInfo"]}",
                                                textAlign:
                                                TextAlign.left,
                                                style:const TextStyle(
                                                    color: Colors
                                                        .orangeAccent,
                                                    fontFamily:
                                                    "Times New Roman",
                                                    fontWeight:
                                                    FontWeight.w700,
                                                    fontSize: 20),
                                              ),
                                            ],
                                          ),
                                          // province name
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .start,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  "Province : ${(documents[index].data()as Map<String,dynamic>)["cityName"]} ${(documents[index].data()as Map<String,dynamic>)["provinceName"]}",
                                                  // overflow:
                                                  //     TextOverflow
                                                  //         .ellipsis,
                                                  //maxLines: 2,
                                                  style:const TextStyle(
                                                      color: Colors
                                                          .black,
                                                      fontFamily:
                                                      "Times New Roman",
                                                      fontWeight:
                                                      FontWeight
                                                          .w700,
                                                      fontSize:
                                                      14),
                                                ),
                                              ),
                                              const Icon(
                                                Icons
                                                    .location_on,
                                                size: 30,
                                              )
                                            ],
                                          ),
                                          // seller info

                                          /*Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                StreamBuilder(
                                                                  stream: FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "users")
                                                                      .doc(documents[index]
                                                                              .data()[
                                                                          "seller"])
                                                                      .snapshots(),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (snapshot
                                                                        .hasData) {
                                                                      return Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            "Seller : ",
                                                                            style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontFamily: "Times New Roman",
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: 14),
                                                                          ),
                                                                          Text(
                                                                            "${snapshot.data.data()["businessName"]}",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.deepOrangeAccent,
                                                                              fontFamily: "Times New Roman",
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 14,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.fade,
                                                                          )
                                                                        ],
                                                                      );
                                                                    } else {
                                                                      return Text(
                                                                          "LOADING");
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ),*/
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
                  }
              );
            }
            else
            {
              return const Center(
                child: Text("No Content"),
              );
            }
          }
          else
          {
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ),
    );
  }
}
