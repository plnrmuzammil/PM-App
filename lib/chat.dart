import 'dart:ui';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "dart:io";
import 'package:image_picker/image_picker.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

var globalmsg = "";
File? _image;
final picker = ImagePicker();

class chatScreen extends StatefulWidget {
  final targetUid;
  chatScreen(this.targetUid);
  @override
  _chatScreenState createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  FirebaseApp? defaultApp;
  FirebaseAuth? auth = FirebaseAuth.instance;
  DocumentSnapshot? userInfo;
  DocumentSnapshot? targetInfo;
  List messages = [];
  DocumentSnapshot? messagesDoc;
  TextEditingController chattxted = TextEditingController(text: "");
  ScrollController chatscrolCtrl = ScrollController();
  decodeName(uid1, uid2) {
    var finalName = "";
    if (uid1.compareTo(uid2) < 0 || uid1.compareTo(uid2) == 0) {
      finalName = uid1 + uid2;
    } else {
      finalName = uid2 + uid1;
    }
    return finalName;
  }

  fetch() async {
    defaultApp = await Firebase.initializeApp();
    userInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc("${auth?.currentUser?.uid}")
        .get();
    targetInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc("${widget.targetUid}")
        .get();
    var msgName = decodeName(userInfo!.id, targetInfo!.id);
    print(msgName);
    messagesDoc = await FirebaseFirestore.instance
        .collection("userMessages")
        .doc("$msgName")
        .get();
    if (messagesDoc?.data() != null) {
      setState(() {
        messages = messagesDoc!["chat"];
      });
    }
    if (messages == null) {
      messages = [];
    } else {
      messages = messages;
    }

    return 1;
  }

  send(msg) {
    FlutterRingtonePlayer().play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: false,
      volume: .2,
    );
    var msgName = decodeName(userInfo!.id, targetInfo!.id);

    if (messagesDoc?.data() != null) {
      FirebaseFirestore.instance.collection("userMessages").doc(msgName).set({
        "chat": messagesDoc!["chat"] +
            [
              {"msg": "$msg", "sender": userInfo!.id, "time": DateTime.now()}
            ]
      });
    } else {
      FirebaseFirestore.instance.collection("userMessages").doc(msgName).set({
        "chat": [
          {"msg": "$msg", "sender": userInfo!.id, "time": DateTime.now()}
        ]
      });
    }
    SchedulerBinding.instance.addPostFrameCallback((_) => scrollToEnd());
  }

  sendImage(link) async {
    var msgName = decodeName(userInfo!.id, targetInfo!.id);

    if (messagesDoc?.data() != null) {
      FirebaseFirestore.instance.collection("userMessages").doc(msgName).set({
        "chat": messagesDoc!["chat"] +
            [
              {
                "msg": "",
                "sender": userInfo!.id,
                "img": link,
                "time": DateTime.now()
              }
            ]
      });
    } else {
      FirebaseFirestore.instance.collection("userMessages").doc(msgName).set({
        "chat": [
          {"msg": "", "sender": userInfo!.id, "img": link}
        ]
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ChatMessage> finalMessages = [];
    for (var el in messages) {
      finalMessages.add(ChatMessage(
        //image:el["img"] ,
          createdAt: el["time"] != null ? el["time"].toDate() : DateTime.now(),
          // video: el["vid"],
          // image: el["img"],
          text: "${el["msg"]}",
          user: ChatUser(id: "${el["sender"]}")));
    }

    fetch();
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
            future: fetch(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Future getImage() async {
                  final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    _image = File(pickedFile.path);
                             } else {
                    print('No image selected.');
                  }
                }



                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,

                      ),
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 25,
                            child: MaterialButton(
                              padding: const EdgeInsets.all(0.0),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          CircleAvatar(
                              backgroundImage:
                              NetworkImage(targetInfo!['profile'])),
                          Text(
                            " " + targetInfo!['businessOwner'],
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Times New Roman",
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(child: DashChat(currentUser: ChatUser(
                      id: userInfo!.id,
                    ),
                      messages: finalMessages.reversed.toList() ,

                      onSend: (msg) async {
                        if (globalmsg != "") {
                          var a = await send(globalmsg);
                          // Fluttertoast.showToast(msg: "gloab $globalmsg");
                        }

                        setState(() {});
                      },
                      inputOptions: InputOptions(
                        textController: chattxted,
                        inputTextStyle: const TextStyle( fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500, fontFamily: "Times New Roman",),
                        sendButtonBuilder: defaultSendButton(color: Colors.green),
                        alwaysShowSend: true,
                        showTraillingBeforeSend: true,
                        onTextChange: (msg) {
                          globalmsg = msg;
                          print(globalmsg);
                        },
                      ),

                    )),



                  ],
                );
              } else {
                return Text("Loading");
              }

//        return Center(child: Text("Target is ${widget.targetUid} Current User is ${auth.currentUser.uid}"));
            }),
      ),
    );
  }

  scrollToEnd() {
    new Future.delayed(const Duration(seconds: 2), () {
      chatscrolCtrl.animateTo(
        chatscrolCtrl.position.maxScrollExtent,
        duration: Duration(milliseconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    });
  }
}



