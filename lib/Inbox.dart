import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:pm_app/chat.dart';
import 'package:pm_app/newMessage.dart';

// import 'package:reale/newMessage.dart';

TextEditingController currentSearch = TextEditingController();

class inbox extends StatefulWidget {
  @override
  _inboxState createState() => _inboxState();
}

class _inboxState extends State<inbox> {

  fetchUserInfo(id) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var userInfo =
        await FirebaseFirestore.instance.collection('users').doc("${id}").get();
    print(auth.currentUser!.uid);
    return userInfo;
  }

  message(id, msg, time) {
    return FutureBuilder<dynamic>(
      future: fetchUserInfo(id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Timestamp msgTime = time ?? Timestamp.now();
          var status = "";
          Duration diff = DateTime.now().difference(msgTime.toDate());

          if (diff.inSeconds < 60) {
            status = "Just Now";
          } else if (diff.inMinutes < 60) {
            status = "${diff.inMinutes.floor()} minutes ago ";
          } else if (diff.inMinutes > 60 && diff.inHours < 24) {
            status = "${(diff.inMinutes / 60).floor()} hours ago";
          } else if (diff.inHours >= 24) {
            status = "${(diff.inHours / 24).floor()} days ago";
          }

          return Container(
            margin: EdgeInsets.only(left: 5, right: 5, bottom: 20),
            child: ButtonTheme(
              child: MaterialButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return chatScreen(id);
                    }));
                  },
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 20),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(
                                    snapshot.data.data()["profile"] ?? "none"),
                              )),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Text(
                                snapshot.data.data()["name"],
                                style: TextStyle(
                                    fontFamily: "Times New Roman",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(right: 10),
                            child: Text(
                              "${status}",
                              style: TextStyle(
                                  fontFamily: "Times New Roman",
                                  fontWeight: FontWeight.w100,
                                  fontSize: 13),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(top: 10, left: 30),
                              child: Text(
                                msg,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: "Times New Roman",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          );
        } else {
          return Container(
            margin: EdgeInsets.all(10),
            height: 40,
            width: 40,
            child: CircleAvatar(
              child: Text(""),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: Container(
          margin: EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //me ************************************
                  return newMessage();
                  // return policy();
                }));
              },
              child: Icon(
                Icons.chat,
                size: 30,
                color: Colors.white,
              )),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Expanded(
              child: StreamBuilder<dynamic>(
                stream: FirebaseFirestore.instance
                    .collection('userMessages')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print('has data');
                    QuerySnapshot data = snapshot.data;
                    List<DocumentSnapshot> userMessages = data.docs;
                    return ListView.builder(
                        itemCount: userMessages.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          FirebaseAuth auth = FirebaseAuth.instance;
                          if (userMessages[index]
                              .id
                              .contains(auth.currentUser!.uid)) {
                            var targetId = userMessages[index]
                                .id
                                .toString()
                                .replaceFirst(auth.currentUser!.uid, "");
                            var recentMessage = ((userMessages[index]
                                .data()as Map<String,dynamic>)["chat"]
                                .last["msg"]);
                            var time = ((userMessages[index]
                                .data()as Map<String,dynamic>)["chat"]
                                .last["time"]);
                            if (time == null) {
                              print("time is null");
                            }
                            return message("${targetId}", recentMessage,
                                time); //This is the id of the user we chatted with
                          } else {
                            return SizedBox(
                              height: 0,
                            );
                          }
                        });
                  } else {
                    print('LOADING data ');
                    return Text("LOADING");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
