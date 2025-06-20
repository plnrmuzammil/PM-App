import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:pm_app/chat.dart';

TextEditingController currentSearch = TextEditingController();

class newMessage extends StatefulWidget {
  @override
  _newMessageState createState() => _newMessageState();
}

class _newMessageState extends State<newMessage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              QuerySnapshot data = snapshot.data;
              List<QueryDocumentSnapshot> users = data.docs;

              return ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: TextField(
                        onChanged: (val) {
                          setState(() {});
                        },
                        controller: currentSearch,
                        decoration: InputDecoration(
                            hintText:
                                "Search By Name , Id Card , Phone , Email"),
                      )),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        if ((users[index].data()
                                as Map<String, dynamic>)["name"] !=
                            "") {
                          var username = (users[index].data()
                                  as Map<String, dynamic>)["name"]
                              .toString();
                          var idCard = (users[index].data()
                                  as Map<String, dynamic>)["idCard"]
                              .toString();
                          var email = (users[index].data()
                                  as Map<String, dynamic>)["email"]
                              .toString();
                          var phone = (users[index].data()
                                  as Map<String, dynamic>)["phone"]
                              .toString();

                          if (username.toLowerCase().contains(currentSearch
                                  .value.text
                                  .toString()
                                  .toLowerCase()) ||
                              idCard.toLowerCase().contains(currentSearch
                                  .value.text
                                  .toString()
                                  .toLowerCase()) ||
                              email.toLowerCase().contains(currentSearch
                                  .value.text
                                  .toString()
                                  .toLowerCase()) ||
                              phone.toLowerCase().contains(currentSearch
                                  .value.text
                                  .toString()
                                  .toLowerCase())) {
                            return Container(
                              margin:
                                  EdgeInsets.only(left: 5, right: 5, top: 10),
                              child: ButtonTheme(
                                child: MaterialButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return chatScreen(users[index].id);
                                      }));
                                    },
                                    padding:
                                        EdgeInsets.only(top: 20, bottom: 20),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                                margin:
                                                    EdgeInsets.only(left: 20),
                                                child: Icon(Icons.person)),
                                            Expanded(
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 60),
                                                child: Text(
                                                  (users[index].data() as Map<
                                                          String,
                                                          dynamic>)["name"]
                                                      .toString(),
                                                  style:
                                                      TextStyle(fontSize: 25),
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
                            return SizedBox(
                              height: 0,
                            );
                          }
                        } else {
                          return SizedBox(
                            height: 0,
                          );
                        }
                      }),
                ],
              );
            } else {
              return Text("EMPTY");
            }
          },
        ),
      ),
    );
  }
}
