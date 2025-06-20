import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:pm_app/Inbox.dart';
import 'package:pm_app/list.dart';
import 'package:pm_app/profile.dart';
import 'package:pm_app/propertyManagement.dart';
import 'package:pm_app/updates.dart';

User? currentUser;
var currentItem = 0;

class mainPage extends StatefulWidget {
  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  setUserOneTime() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    var tempUser = await _auth.currentUser;
    setState(() {
      currentUser = tempUser;
      // currentUser = TempConstant.TempUserId;
    });
  }

  @override
  void initState() {
    print('main page init');
    setUserOneTime();
    super.initState();
  }

  @override
  void dispose() {
    print('main page dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: FirebaseFirestore.instance
            .collection("users")
             .doc("${auth.currentUser?.uid}")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var document = snapshot.data;
            var userData = document.data();
            bool isApproved = userData["approved"];

            if (isApproved == true) {
              return DefaultTabController(
                initialIndex: 0,
                length: 4,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  /* drawer: Drawer(
                    child: Scaffold(
                      body: Center(child: profile()),
                    ),
                  ),*/
                  extendBodyBehindAppBar: false,
                  // TODO:
                  appBar: AppBar(
                    toolbarHeight: 1,
                    backgroundColor: Colors.green,
                    primary: true,
                    bottom: PreferredSize(
                      preferredSize: Size.copy(Size(100, 100)),
                      child: TabBar(
                        isScrollable: true,
                        unselectedLabelColor: Colors.green.shade300,
                        labelColor: Colors.white,
                        indicatorColor: Colors.white,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 5,
                        //labelPadding: const EdgeInsets.only(left: 20, right: 20),
                        tabs: <Widget>[
                          FittedBox(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: const Tab(
                                child: Text('Updates',
                                    style: TextStyle(
                                        fontFamily: "Times New Roman",
                                        fontWeight: FontWeight.w700,
                                        // color: Colors.black,
                                        fontSize: 14)),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: const Tab(
                              child: Text('List',
                                  style: TextStyle(
                                      fontFamily: "Times New Roman",
                                      fontWeight: FontWeight.w700,
                                      // color: Colors.black,
                                      fontSize: 14)),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Tab(
                              child: Container(
                                  child: Text('Chats',
                                      style: TextStyle(
                                          fontFamily: "Times New Roman",
                                          fontWeight: FontWeight.w700,
                                          // color: Colors.black,
                                          fontSize: 14))),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.05,
                            child: const Align(
                              alignment: Alignment.center,
                              child: Tab(
                                child: Icon(Icons.settings),
                                // iconMargin: const EdgeInsets.only(right: 10),
                                // child: Text('Menu',
                                //     style: TextStyle(
                                //         fontFamily: "Times New Roman",
                                //         fontWeight: FontWeight.w700,
                                //         // color: Colors.black,
                                //         fontSize: 14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  body: TabBarView(
                    children: <Widget>[
                      list(),
                      updates(),
                      inbox(),
                      propertyManagement(),
                      // Menu(), // remove this and place another page as main page

                    ],
                  ),
                ),
              );
            } else {
              // if user not approved
              return DefaultTabController(
                initialIndex: 0,
                length: 4,
                child: Scaffold(
                  drawer: Drawer(
                    child: Scaffold(
                      body: Center(child: profile()),
                    ),
                  ),
                  extendBodyBehindAppBar: false,
                  // TODO:
                  appBar: AppBar(
                    toolbarHeight: 55,
                    backgroundColor: Colors.green,
                    bottom: TabBar(
                      unselectedLabelColor: Colors.green.shade300,
                      labelColor: Colors.white,
                      indicatorColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 5,
                      tabs: const <Widget>[
                        Tab(
                          child: Text('List',
                              style: TextStyle(
                                  fontFamily: "Times New Roman",
                                  fontWeight: FontWeight.w700,
                                  //color: Colors.black,
                                  fontSize: 13)),
                        ),
                        Tab(
                          child: FittedBox(
                            child: Text('Updates',
                                style: TextStyle(
                                    fontFamily: "Times New Roman",
                                    fontWeight: FontWeight.w700,
                                    //color: Colors.black,
                                    fontSize: 13)),
                          ),
                        ),
                        Tab(
                            child: Text('Chats',
                                style: TextStyle(
                                    fontFamily: "Times New Roman",
                                    fontWeight: FontWeight.w700,
                                    //color: Colors.black,
                                    fontSize: 13))),
                        Tab(
                          child: Icon(Icons.settings),
                          iconMargin: EdgeInsets.all(0),
                          // child: Text('Menu',
                          //     style: TextStyle(
                          //         fontFamily: "Times New Roman",
                          //         fontWeight: FontWeight.w700,
                          //         //color: Colors.black,
                          //         fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: <Widget>[
                      // for list
                      const Scaffold(
                        body: Center(
                          child: Text("YOU ARE NOT APPROVED ",
                              style: TextStyle(
                                  fontFamily: "Times New Roman",
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  fontSize: 14)),
                        ),
                      ),
                      updates(),
                      inbox(),
                      // for setting
                      const Scaffold(
                        body: Center(
                          child: Text("YOU ARE NOT APPROVED aa",
                              style: TextStyle(
                                  fontFamily: "Times New Roman",
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  fontSize: 14)),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
          } else {
            return Center(child: Text("LOADING..."));
          }
        });
  }
}
