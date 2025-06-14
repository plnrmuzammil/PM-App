import 'package:dash_chat_2/dash_chat_2.dart';
import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/scheduler.dart';
import "dart:io";
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

var globalmsg = "";
File? _image;
final picker = ImagePicker();

class chatScreen extends StatefulWidget {
  final targetUid;
  const chatScreen(this.targetUid, {super.key});
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
    messages = messages;
  
    return 1;
  }

  send(msg) {
    FlutterRingtonePlayer.play(
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
                    //mmee ******************************************
                    // FirebaseStorage _storage = FirebaseStorage.instance;
                    //
                    // String fileName = _image.path;
                    // StorageReference firebaseStorageRef = FirebaseStorage
                    //     .instance
                    //     .ref()
                    //     .child('uploads/$fileName');
                    // StorageUploadTask uploadTask =
                    //     firebaseStorageRef.putFile(_image);
                    // StorageTaskSnapshot taskSnapshot =
                    //     await uploadTask.onComplete;
                    // taskSnapshot.ref.getDownloadURL().then(
                    //   (value) async {
                    //     await sendImage(value);
                    //   },
                    // );
                  } else {
                    print('No image selected.');
                  }
                }

                // Future getEmoji() async {
                //   // await getImage();
                //   showDialog(
                //       context: context,
                //       builder: (context) => EmojiPicker(
                //             rows: 3,
                //             columns: 7,
                //             buttonMode: ButtonMode.MATERIAL,
                //             recommendKeywords: ["racing", "horse"],
                //             numRecommended: 10,
                //             onEmojiSelected: (emoji, category) {
                //               print(emoji.emoji);
                //               globalmsg += emoji.emoji;
                //               print(emoji);
                //               chattxted.text += emoji.emoji;
                //             },
                //           ));
                // }

                return Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        // gradient: LinearGradient(
                        //     colors: [Colors.blue, Colors.green],
                        //     begin: const FractionalOffset(0.0, 0.0),
                        //     end: const FractionalOffset(0.7, 0.0),
                        //     stops: [0.0, 1.0],
                        //     tileMode: TileMode.clamp),
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
                              child: const Icon(
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
                            style: const TextStyle(
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




                    // Expanded(
                    //   child: DashChat(
                    //     currentUser: ChatUser(
                    //       id: userInfo!.id,
                    //     ),
                    //     // inputToolbarMargin: const EdgeInsets.all(0),
                    //     scrollController: chatscrolCtrl,
                    //     avatarBuilder: (dw) {
                    //       return Container();
                    //     },
                    //     showAvatarForEveryMessage: false,
                    //
                    //     text: "Hello",
                    //     inputTextStyle: TextStyle(
                    //       fontSize: 18,
                    //       color: Colors.black,
                    //       fontWeight: FontWeight.w500,
                    //       fontFamily: "Times New Roman",
                    //     ),
                    //     showLoadEarlierWidget: () {
                    //       return Text('___________-');
                    //     },
                    //     messageDecorationBuilder: (chat, bool) {
                    //       if (chat.user.uid != userInfo!.id) {
                    //         return BoxDecoration(
                    //           shape: BoxShape.rectangle,
                    //           color: Colors.blue,
                    //           borderRadius: BorderRadius.only(
                    //               topLeft: Radius.circular(20.0),
                    //               topRight: Radius.circular(20.0),
                    //               bottomLeft: Radius.zero,
                    //               bottomRight: Radius.circular(20.0) //,
                    //               ),
                    //         );
                    //       }
                    //
                    //       return BoxDecoration(
                    //         shape: BoxShape.rectangle,
                    //         color: Colors.green,
                    //         borderRadius: BorderRadius.only(
                    //           topLeft: Radius.circular(20.0),
                    //           topRight: Radius.circular(20.0),
                    //           bottomLeft: Radius.circular(20.0),
                    //           bottomRight: Radius.zero,
                    //         ),
                    //       );
                    //     },
                    //     //me $***************************
                    //     // messageTimeBuilder: (url, [c]) {
                    //     //   return Text(
                    //     //     getTimeEvent(c.createdAt),
                    //     //     style: TextStyle(
                    //     //       fontSize: 9,
                    //     //       color: Colors.white,
                    //     //       fontWeight: FontWeight.w100,
                    //     //       fontFamily: "Times New Roman",
                    //     //     ),
                    //     //   );
                    //     // },
                    //
                    //     textController: chattxted,
                    //     dateBuilder: (str) {
                    //       return Text(
                    //         getDateEvent(DateTime.parse(str.substring(
                    //               7,
                    //             ) +
                    //             str.substring(1, 3) +
                    //             str.substring(3, 6))),
                    //         style: TextStyle(
                    //           fontFamily: "Times New Roman",
                    //         ),
                    //       );
                    //     },
                    //     dateFormat: DateFormat(' MM-dd-yyyy'),
                    //     sendButtonBuilder: (s) {
                    //       return MaterialButton(
                    //           onPressed: () async {
                    //             await s();
                    //           },
                    //           child: Icon(
                    //             Icons.send,
                    //             size: 30,
                    //           ));
                    //     },
                    //     messages: finalMessages,
                    //     user: ChatUser(
                    //       uid: userInfo!.id,
                    //     ),
                    //     // text: "enter",
                    //     onTextChange: (msg) {
                    //       globalmsg = msg;
                    //       print(globalmsg);
                    //     },
                    //     onSend: (msg) async {
                    //       if (globalmsg != "") {
                    //         var a = await send(globalmsg);
                    //       }
                    //
                    //       setState(() {});
                    //     },
                    //     showUserAvatar: false,
                    //     sendOnEnter: true,
                    //     trailing: [
                    //       Container(
                    //         height: 70,
                    //         child: TextButton(
                    //           child: Icon(
                    //             Icons.insert_emoticon,
                    //             size: 30,
                    //           ),
                    //           onPressed: (){},
                    //           // async {
                    //           //   await getEmoji();
                    //           // },
                    //         ),
                    //       ),
                    //       TextButton(
                    //         child: Icon(
                    //           Icons.image,
                    //           size: 30,
                    //         ),
                    //         onPressed: () async {
                    //           await getImage();
                    //         },
                    //       )
                    //     ],
                    //   ),
                    // ),
                  ],
                );
              } else {
                return const Text("Loading");
              }

//        return Center(child: Text("Target is ${widget.targetUid} Current User is ${auth.currentUser.uid}"));
            }),
      ),
    );
  }

  scrollToEnd() {
    Future.delayed(const Duration(seconds: 2), () {
      chatscrolCtrl.animateTo(
        chatscrolCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    });
  }
}






// //  olld code with dash_chat: null deprecated api
//
// import 'dart:ui';
// import "package:dash_chat/dash_chat.dart";
// import 'package:firebase_storage/firebase_storage.dart';
// import "package:flutter/material.dart";
// import "package:firebase_auth/firebase_auth.dart";
// import "package:firebase_core/firebase_core.dart";
// import "package:cloud_firestore/cloud_firestore.dart";
// import 'package:flutter/scheduler.dart';
// import "dart:io";
// import 'package:image_picker/image_picker.dart';
// import 'package:reale/newCode/Functions.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
//
// var globalmsg = "";
// File? _image;
// final picker = ImagePicker();
//
// class chatScreen extends StatefulWidget {
//   final targetUid;
//   chatScreen(this.targetUid);
//   @override
//   _chatScreenState createState() => _chatScreenState();
// }
//
// class _chatScreenState extends State<chatScreen> {
//   FirebaseApp? defaultApp;
//   FirebaseAuth? auth = FirebaseAuth.instance;
//   DocumentSnapshot? userInfo;
//   DocumentSnapshot? targetInfo;
//   List messages = [];
//   DocumentSnapshot? messagesDoc;
//   TextEditingController chattxted = TextEditingController(text: "");
//   ScrollController chatscrolCtrl = ScrollController();
//   decodeName(uid1, uid2) {
//     var finalName = "";
//     if (uid1.compareTo(uid2) < 0 || uid1.compareTo(uid2) == 0) {
//       finalName = uid1 + uid2;
//     } else {
//       finalName = uid2 + uid1;
//     }
//     return finalName;
//   }
//
//   fetch() async {
//     defaultApp = await Firebase.initializeApp();
//     userInfo = await FirebaseFirestore.instance
//         .collection('users')
//         .doc("${auth?.currentUser?.uid}")
//         .get();
//     targetInfo = await FirebaseFirestore.instance
//         .collection('users')
//         .doc("${widget.targetUid}")
//         .get();
//     var msgName = decodeName(userInfo!.id, targetInfo!.id);
//     print(msgName);
//     messagesDoc = await FirebaseFirestore.instance
//         .collection("userMessages")
//         .doc("$msgName")
//         .get();
//     if (messagesDoc?.data() != null) {
//       setState(() {
//         messages = messagesDoc!["chat"];
//       });
//     }
//     if (messages == null) {
//       messages = [];
//     } else {
//       messages = messages;
//     }
//
//     return 1;
//   }
//
//   send(msg) {
//     FlutterRingtonePlayer.play(
//       android: AndroidSounds.notification,
//       ios: IosSounds.glass,
//       looping: false,
//       volume: .2,
//     );
//     var msgName = decodeName(userInfo!.id, targetInfo!.id);
//
//     if (messagesDoc?.data() != null) {
//       FirebaseFirestore.instance.collection("userMessages").doc(msgName).set({
//         "chat": messagesDoc!["chat"] +
//             [
//               {"msg": "$msg", "sender": userInfo!.id, "time": DateTime.now()}
//             ]
//       });
//     } else {
//       FirebaseFirestore.instance.collection("userMessages").doc(msgName).set({
//         "chat": [
//           {"msg": "$msg", "sender": userInfo!.id, "time": DateTime.now()}
//         ]
//       });
//     }
//     SchedulerBinding.instance.addPostFrameCallback((_) => scrollToEnd());
//   }
//
//   sendImage(link) async {
//     var msgName = decodeName(userInfo!.id, targetInfo!.id);
//
//     if (messagesDoc?.data() != null) {
//       FirebaseFirestore.instance.collection("userMessages").doc(msgName).set({
//         "chat": messagesDoc!["chat"] +
//             [
//               {
//                 "msg": "",
//                 "sender": userInfo!.id,
//                 "img": link,
//                 "time": DateTime.now()
//               }
//             ]
//       });
//     } else {
//       FirebaseFirestore.instance.collection("userMessages").doc(msgName).set({
//         "chat": [
//           {"msg": "", "sender": userInfo!.id, "img": link}
//         ]
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<ChatMessage> finalMessages = [];
//     for (var el in messages) {
//       finalMessages.add(ChatMessage(
//           //image:el["img"] ,
//           createdAt: el["time"] != null ? el["time"].toDate() : DateTime.now(),
//           video: el["vid"],
//           image: el["img"],
//           text: "${el["msg"]}",
//           user: ChatUser(uid: "${el["sender"]}")));
//     }
//
//     fetch();
//     return SafeArea(
//       child: Scaffold(
//         body: FutureBuilder(
//             future: fetch(),
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 Future getImage() async {
//                   final pickedFile =
//                       await picker.pickImage(source: ImageSource.gallery);
//
//                   if (pickedFile != null) {
//                     _image = File(pickedFile.path);
//                     //mmee ******************************************
//                     // FirebaseStorage _storage = FirebaseStorage.instance;
//                     //
//                     // String fileName = _image.path;
//                     // StorageReference firebaseStorageRef = FirebaseStorage
//                     //     .instance
//                     //     .ref()
//                     //     .child('uploads/$fileName');
//                     // StorageUploadTask uploadTask =
//                     //     firebaseStorageRef.putFile(_image);
//                     // StorageTaskSnapshot taskSnapshot =
//                     //     await uploadTask.onComplete;
//                     // taskSnapshot.ref.getDownloadURL().then(
//                     //   (value) async {
//                     //     await sendImage(value);
//                     //   },
//                     // );
//                   } else {
//                     print('No image selected.');
//                   }
//                 }
//
//                 // Future getEmoji() async {
//                 //   // await getImage();
//                 //   showDialog(
//                 //       context: context,
//                 //       builder: (context) => EmojiPicker(
//                 //             rows: 3,
//                 //             columns: 7,
//                 //             buttonMode: ButtonMode.MATERIAL,
//                 //             recommendKeywords: ["racing", "horse"],
//                 //             numRecommended: 10,
//                 //             onEmojiSelected: (emoji, category) {
//                 //               print(emoji.emoji);
//                 //               globalmsg += emoji.emoji;
//                 //               print(emoji);
//                 //               chattxted.text += emoji.emoji;
//                 //             },
//                 //           ));
//                 // }
//
//                 return Column(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         // gradient: LinearGradient(
//                         //     colors: [Colors.blue, Colors.green],
//                         //     begin: const FractionalOffset(0.0, 0.0),
//                         //     end: const FractionalOffset(0.7, 0.0),
//                         //     stops: [0.0, 1.0],
//                         //     tileMode: TileMode.clamp),
//                       ),
//                       height: 70,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             width: 25,
//                             child: MaterialButton(
//                               padding: const EdgeInsets.all(0.0),
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                               child: Icon(
//                                 Icons.arrow_back,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           CircleAvatar(
//                               backgroundImage:
//                                   NetworkImage(targetInfo!['profile'])),
//                           Text(
//                             " " + targetInfo!['businessOwner'],
//                             style: TextStyle(
//                               fontSize: 20,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w500,
//                               fontFamily: "Times New Roman",
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: DashChat(
//                         inputToolbarMargin: const EdgeInsets.all(0),
//                         scrollController: chatscrolCtrl,
//                         avatarBuilder: (dw) {
//                           return Container();
//                         },
//                         showAvatarForEveryMessage: false,
//                         //me *******orignil is below just
//                         // messageTextBuilder: (char, [ c]) {
//                         // messageTextBuilder: (char, [ c]) {
//                         //   return Text(
//                         //     char!,
//                         //     style: TextStyle(
//                         //       fontSize: 18,
//                         //       color: Colors.white,
//                         //       fontWeight: FontWeight.w500,
//                         //       fontFamily: "Times New Roman",
//                         //     ),
//                         //   );
//                         // },
//                         text: "Hello",
//                         inputTextStyle: TextStyle(
//                           fontSize: 18,
//                           color: Colors.black,
//                           fontWeight: FontWeight.w500,
//                           fontFamily: "Times New Roman",
//                         ),
//                         showLoadEarlierWidget: () {
//                           return Text('___________-');
//                         },
//                         messageDecorationBuilder: (chat, bool) {
//                           if (chat.user.uid != userInfo!.id) {
//                             return BoxDecoration(
//                               shape: BoxShape.rectangle,
//                               color: Colors.blue,
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(20.0),
//                                   topRight: Radius.circular(20.0),
//                                   bottomLeft: Radius.zero,
//                                   bottomRight: Radius.circular(20.0) //,
//                                   ),
//                             );
//                           }
//
//                           return BoxDecoration(
//                             shape: BoxShape.rectangle,
//                             color: Colors.green,
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(20.0),
//                               topRight: Radius.circular(20.0),
//                               bottomLeft: Radius.circular(20.0),
//                               bottomRight: Radius.zero,
//                             ),
//                           );
//                         },
//                         //me $***************************
//                         // messageTimeBuilder: (url, [c]) {
//                         //   return Text(
//                         //     getTimeEvent(c.createdAt),
//                         //     style: TextStyle(
//                         //       fontSize: 9,
//                         //       color: Colors.white,
//                         //       fontWeight: FontWeight.w100,
//                         //       fontFamily: "Times New Roman",
//                         //     ),
//                         //   );
//                         // },
//
//                         textController: chattxted,
//                         dateBuilder: (str) {
//                           return Text(
//                             getDateEvent(DateTime.parse(str.substring(
//                                   7,
//                                 ) +
//                                 str.substring(1, 3) +
//                                 str.substring(3, 6))),
//                             style: TextStyle(
//                               fontFamily: "Times New Roman",
//                             ),
//                           );
//                         },
//                         dateFormat: DateFormat(' MM-dd-yyyy'),
//                         sendButtonBuilder: (s) {
//                           return MaterialButton(
//                               onPressed: () async {
//                                 await s();
//                               },
//                               child: Icon(
//                                 Icons.send,
//                                 size: 30,
//                               ));
//                         },
//                         messages: finalMessages,
//                         user: ChatUser(
//                           uid: userInfo!.id,
//                         ),
//                         // text: "enter",
//                         onTextChange: (msg) {
//                           globalmsg = msg;
//                           print(globalmsg);
//                         },
//                         onSend: (msg) async {
//                           if (globalmsg != "") {
//                             var a = await send(globalmsg);
//                           }
//
//                           setState(() {});
//                         },
//                         showUserAvatar: false,
//                         sendOnEnter: true,
//                         trailing: [
//                           Container(
//                             height: 70,
//                             child: TextButton(
//                               child: Icon(
//                                 Icons.insert_emoticon,
//                                 size: 30,
//                               ),
//                               onPressed: (){},
//                               // async {
//                               //   await getEmoji();
//                               // },
//                             ),
//                           ),
//                           TextButton(
//                             child: Icon(
//                               Icons.image,
//                               size: 30,
//                             ),
//                             onPressed: () async {
//                               await getImage();
//                             },
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               } else {
//                 return Text("Loading");
//               }
//
// //        return Center(child: Text("Target is ${widget.targetUid} Current User is ${auth.currentUser.uid}"));
//             }),
//       ),
//     );
//   }
//
//   scrollToEnd() {
//     new Future.delayed(const Duration(seconds: 2), () {
//       chatscrolCtrl.animateTo(
//         chatscrolCtrl.position.maxScrollExtent,
//         duration: Duration(milliseconds: 1),
//         curve: Curves.fastOutSlowIn,
//       );
//     });
//   }
// }
