import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:pm_app/listTab/selectSchemeNonScheme.dart";
import "package:pm_app/listTab/viewScheme.dart";
import "package:pm_app/main.dart";
import "package:pm_app/widgets/stylishCustomButton.dart";

class viewDistrict extends StatefulWidget {
  final province;
  viewDistrict({this.province});

  @override
  _viewDistrictState createState() => _viewDistrictState();
}

class _viewDistrictState extends State<viewDistrict> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StreamBuilder<dynamic>(
          stream: FirebaseFirestore.instance
              .collection("districts")
              .where("provinceID", isEqualTo: "${widget.province}")
              .orderBy("name", descending: false)
              .snapshots(),
          builder: (BuildContext context,AsyncSnapshot snapshot){


            if (snapshot.hasData){

              var docData = snapshot.data;
              var docs = docData.docs;

              print(docs.length);

              if(docs.length != 0)
                {
                  return ListView.builder(
                      itemCount: docs.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index){
                        if (index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                color: Colors.green,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Select District',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: MediaQuery.of(context).size.width - 50,
                                margin:
                                const EdgeInsets.only(top: 15, bottom: 5, left: 20),
                                child: StylishCustomButton(
                                  onPressed: () {
                                    listingModel.district = docs[index]["name"];
                                    // print('district name: ${docs[index]["name"]}');
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context){
                                          return SelectSchemeNonScheme(
                                              district: "${docs[index]["id"]}"
                                          );
                                          return viewSceme(
                                              district: "${docs[index]["id"]}");
                                        }));
                                  },
                                  text: docs[index]["name"],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width - 50,
                              margin: EdgeInsets.only(top: 15, bottom: 5),
                              child: StylishCustomButton(
                                onPressed: () {
                                  listingModel.district = docs[index]["name"];
                                  // print('district name: ${docs[index]["name"]}');
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                        return SelectSchemeNonScheme(district: "${docs[index]["id"]}");
                                        return viewSceme(district: "${docs[index]["id"]}");
                                      }));
                                },
                                text: docs[index]["name"],
                              ),
                            ),
                          );
                        }
                      });
                }
              else
                {
                  return const Center(
                    child: Text('No Content'),
                  );
                }


            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
