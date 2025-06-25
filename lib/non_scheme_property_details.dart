import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pm_app/widgets/custom_text_widget.dart';

import 'constant.dart';

class NonSchemePropertyDetails extends StatefulWidget {
  const NonSchemePropertyDetails({Key? key, this.data}) : super(key: key);

  final data;

  @override
  State<NonSchemePropertyDetails> createState() => _NonSchemePropertyDetailsState();
}

class _NonSchemePropertyDetailsState extends State<NonSchemePropertyDetails> {
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Details"),
      ),
      
      body: Column(
        children:
        [
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection("listings").snapshots(),
              builder:(BuildContext context,AsyncSnapshot snapshot)
              {
                if(snapshot.hasData)
                  {
                    return Container(
                      color: BackGroundComtainerColor,
                      padding: const EdgeInsets.all(7),
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child:Image.network(widget.data['schemeImageURL'], fit: BoxFit.cover,),
                    );
                  }
                else
                  {
                    return const Center(child: Text("No Image found"));
                  }
              }
          ),
          SingleChildScrollView(
            child: Expanded(
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
                                  text1: '$timeFormat',
                                  text2: '',
                                ),
                              ],
                            ),

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
                              text2: '${widget.data!["businessName"]}',
                            ),
                            CustomTextWidget(
                              text1: 'Owner: ',
                              text2: '${widget.data!["businessOwner"]}',
                            ),
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
                              text2: '${widget.data["districtName"]}',
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
                            widget.data["isShowPlotInfoToUser"] == null ||
                                widget.data["isShowPlotInfoToUser"] ==
                                    false
                                ? Container()
                                : CustomTextWidget(
                              text1: 'plot/house/room no: ',
                              text2:
                              '${widget.data["area"]} ${widget.data["plotInfo"]}',
                            ),

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
          ),
        ],
      ),
    );
  }
}
