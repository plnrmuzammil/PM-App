import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:reale/listTab/viewBlock.dart";
import 'package:reale/widgets/stylishCustomButton.dart';

class selectPhase extends StatefulWidget {
  final scheme;
  const selectPhase({super.key, this.scheme});

  @override
  _selectPhaseState createState() => _selectPhaseState();
}

class _selectPhaseState extends State<selectPhase> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<dynamic>(
          stream: FirebaseFirestore.instance
              .collection("Phase")
              //.orderBy("name", descending: false)
              .where("schemeID", isEqualTo: "${widget.scheme}")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docData = snapshot.data;
              var docs = docData.docs;

              return ListView.builder(
                  itemCount: docs.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
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
                                'Select Zone',
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
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return viewBlock(
                                      phase: "${docs[index]["id"]}");
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
                          margin: const EdgeInsets.only(top: 15, bottom: 5),
                          child: StylishCustomButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return viewBlock(phase: "${docs[index]["id"]}");
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
                child: const Center(
                  child: Text('No Content'),
                ),
              );
            }
          }),
    );
  }
}
