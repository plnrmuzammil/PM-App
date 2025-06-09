import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:reale/chat.dart';

TextEditingController currentSearch = TextEditingController();

class newMessage extends StatefulWidget {
  const newMessage({super.key});

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
                physics: const BouncingScrollPhysics(),
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: TextField(
                        onChanged: (val) {
                          setState(() {});
                        },
                        controller: currentSearch,
                        decoration: const InputDecoration(
                            hintText:
                                "Search By Name , Id Card , Phone , Email"),
                      )),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      physics: const BouncingScrollPhysics(),
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
                                  const EdgeInsets.only(left: 5, right: 5, top: 10),
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
                                        const EdgeInsets.only(top: 20, bottom: 20),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                                margin:
                                                    const EdgeInsets.only(left: 20),
                                                child: const Icon(Icons.person)),
                                            Expanded(
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.only(left: 60),
                                                child: Text(
                                                  (users[index].data() as Map<
                                                          String,
                                                          dynamic>)["name"]
                                                      .toString(),
                                                  style:
                                                      const TextStyle(fontSize: 25),
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
                            return const SizedBox(
                              height: 0,
                            );
                          }
                        } else {
                          return const SizedBox(
                            height: 0,
                          );
                        }
                      }),
                ],
              );
            } else {
              return const Text("EMPTY");
            }
          },
        ),
      ),
    );
  }
}
