import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:google_fonts/google_fonts.dart";


class policy extends StatefulWidget {
  const policy({super.key});

  @override
  _policyState createState() => _policyState();
}

class _policyState extends State<policy> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("info").doc("info").snapshots(),
              builder: (context, AsyncSnapshot<
                  DocumentSnapshot> snapshot) {
                if(snapshot.hasData){
                  return Center(
                      child: Text(
                        "${snapshot.data!["policy"]}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont('Montserrat',fontWeight: FontWeight.w500,fontSize: 20),
                      )
                  );
                }
                else{
                  return const Text("LOADING");
                }

              }
          )
        ),
      ),
    );
  }
}
