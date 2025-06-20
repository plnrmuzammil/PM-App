import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:google_fonts/google_fonts.dart';
import "package:pm_app/chat.dart";

TextEditingController currentSearch = TextEditingController();

class dealers extends StatefulWidget {
  @override
  _dealersState createState() => _dealersState();
}

class _dealersState extends State<dealers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 30, left: 10, right: 10),
              child: TextField(
                onChanged: (val) {
                  setState(() {});
                },
                controller: currentSearch,
                textAlign: TextAlign.center,
                style: TextStyle(),
                decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    labelText: 'Search',
                    hintMaxLines: 3,
                    suffixIcon: Icon(Icons.search),
                    hintText: "Search by name,id card,email,phone"),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection("users").snapshots(),
                builder: (BuildContext context,AsyncSnapshot<QuerySnapshot>  snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot? data = snapshot.data;
                    List<QueryDocumentSnapshot>? users = data?.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: users!.length,
                      itemBuilder: (context, index) {
                        var username = (users[index].data() as Map<String,dynamic>)["name"].toString();
                        var idCard = (users[index].data()as Map<String,dynamic>)["idCard"].toString();
                        var email = (users[index].data() as Map<String,dynamic>)["email"].toString();
                        var phone = (users[index].data() as Map<String,dynamic>)["phone"].toString();
                        var businessOwner =
                        (users[index].data() as Map<String,dynamic>)["businessOwner"].toString();
                        var businessName =
                        (users[index].data() as Map<String,dynamic>)["businessName"].toString();

                        if ((users[index].data() as Map<String,dynamic>) ["approved"] == true) {
                          if (username.contains(
                                  currentSearch.value.text.toString()) ||
                              idCard.toString().toLowerCase().contains(
                                  currentSearch.value.text
                                      .toString()
                                      .toLowerCase()) ||
                              email.toString().toLowerCase().contains(
                                  currentSearch.value.text
                                      .toString()
                                      .toLowerCase()) ||
                              phone.toString().toLowerCase().contains(
                                  currentSearch.value.text
                                      .toString()
                                      .toLowerCase()) ||
                              businessOwner.toString().toLowerCase().contains(
                                  currentSearch.value.text
                                      .toString()
                                      .toLowerCase()) ||
                              businessName.toString().toLowerCase().contains(
                                  currentSearch.value.text
                                      .toString()
                                      .toLowerCase())) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin:
                                  EdgeInsets.only(left: 5, right: 5, bottom: 3),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return chatScreen(users[index].id);
                                  }));
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 7,
                                  color: Colors.white,
                                  child: Container(

                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            text: 'Name: ',
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${(users[index].data() as Map<String,dynamic>)["name"]}',
                                                style: GoogleFonts.getFont(
                                                    'Montserrat',
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          style: GoogleFonts.getFont(
                                              'Montserrat',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14),
                                        ),

                                        Text.rich(
                                          TextSpan(
                                            text: 'Owner: ',
                                            children: [
                                              TextSpan(
                                                text: '${businessOwner}',
                                                style: GoogleFonts.getFont(
                                                    'Montserrat',
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          style: GoogleFonts.getFont(
                                              'Montserrat',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14),
                                        ),

                                        Text.rich(
                                          TextSpan(
                                            text: 'Business Name: ',
                                            children: [
                                              TextSpan(
                                                text: '${businessName}',
                                                style: GoogleFonts.getFont(
                                                    'Montserrat',
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          style: GoogleFonts.getFont(
                                              'Montserrat',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
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
                      },
                    );
                  } else {
                    return Text("LOADING");
                  }
                },
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

