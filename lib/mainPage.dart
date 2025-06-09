import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:reale/Inbox.dart';
import "package:reale/list.dart";
import 'package:reale/profile.dart';
import 'package:reale/propertyManagement.dart';
import 'package:reale/updates.dart';

User? currentUser;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("An error occurred"));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("User data not found"));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        bool isApproved = userData["approved"] ?? false;

        return DefaultTabController(
          initialIndex: 0,
          length: 4,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              toolbarHeight: isApproved ? 1 : 55,
              backgroundColor: Colors.green,
              bottom: TabBar(
                isScrollable: isApproved,
                unselectedLabelColor: Colors.green.shade300,
                labelColor: Colors.white,
                indicatorColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 5,
                tabs: [
                  Tab(
                    child: Text(
                      isApproved ? 'Updates' : 'List',
                      style: const TextStyle(
                        fontFamily: "Times New Roman",
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Tab(
                    child: Text(
                      'Updates',
                      style: TextStyle(
                        fontFamily: "Times New Roman",
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Tab(
                    child: Text(
                      'Chats',
                      style: TextStyle(
                        fontFamily: "Times New Roman",
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Tab(
                    icon: Icon(Icons.settings),
                  ),
                ],
              ),
            ),
            drawer: isApproved ? null : const Drawer(
              child: Scaffold(body: Center(child: profile())),
            ),
            body: TabBarView(
              children: isApproved
                  ? const [
                      list(),
                      updates(),
                      inbox(),
                      propertyManagement(),
                    ]
                  : const [
                      Center(
                        child: Text(
                          "YOU ARE NOT APPROVED",
                          style: TextStyle(
                              fontFamily: "Times New Roman",
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                      ),
                      updates(),
                      inbox(),
                      Center(
                        child: Text(
                          "YOU ARE NOT APPROVED",
                          style: TextStyle(
                              fontFamily: "Times New Roman",
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                      ),
                    ],
            ),
          ),
        );
      },
    );
  }
}
