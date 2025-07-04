import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:pm_app/listTab/selectPhase.dart";
import "package:pm_app/widgets/stylishCustomButton.dart";

class viewSceme extends StatefulWidget {
  final district;
  viewSceme({this.district});

  @override
  _viewScemeState createState() => _viewScemeState();
}

class _viewScemeState extends State<viewSceme> {
  @override
  Widget build(BuildContext context) {
    print('scheme route');
    return Scaffold(
      body: StreamBuilder<dynamic>(
          stream: FirebaseFirestore.instance
              .collection("Scheme")
              .orderBy("name", descending: false)
              .where("districtID", isEqualTo: "${widget.district}")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docData = snapshot.data;
              var docs = docData.docs;

              return ListView.builder(
                  itemCount: docs.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.green,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Select Scheme',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: MediaQuery.of(context).size.width - 50,
                            margin:
                                EdgeInsets.only(top: 15, bottom: 5, left: 20),
                            child: StylishCustomButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return selectPhase(
                                      scheme: "${docs[index]["id"]}");
                                }));
                              },
                              text: docs[index]["name"].toString(),
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
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return selectPhase(
                                    scheme: "${docs[index]["id"]}");
                              }));
                            },
                            text: docs[index]["name"].toString(),
                          ),
                        ),
                      );
                    }
                  });
            } else {
              return Container(
                child: Center(
                  child: Text('No Content'),
                ),
              );
            }
          }),
    );
  }
}
