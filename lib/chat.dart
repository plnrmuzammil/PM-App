// import 'dart:ui';
// import 'package:dash_chat_2/dash_chat_2.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import "package:flutter/material.dart";
// import "package:firebase_auth/firebase_auth.dart";
// import "package:firebase_core/firebase_core.dart";
// import "package:cloud_firestore/cloud_firestore.dart";
// import 'package:flutter/scheduler.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import "dart:io";
// import 'package:image_picker/image_picker.dart';
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
//     FlutterRingtonePlayer().play(
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
//         //image:el["img"] ,
//           createdAt: el["time"] != null ? el["time"].toDate() : DateTime.now(),
//           // video: el["vid"],
//           // image: el["img"],
//           text: "${el["msg"]}",
//           user: ChatUser(id: "${el["sender"]}")));
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
//                   await picker.pickImage(source: ImageSource.gallery);
//
//                   if (pickedFile != null) {
//                     _image = File(pickedFile.path);
//                              } else {
//                     print('No image selected.');
//                   }
//                 }
//
//
//
//                 return Column(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//
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
//                               NetworkImage(targetInfo!['profile'])),
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
//
//                     Expanded(child: DashChat(currentUser: ChatUser(
//                       id: userInfo!.id,
//                     ),
//                       messages: finalMessages.reversed.toList() ,
//
//                       onSend: (msg) async {
//                         if (globalmsg != "") {
//                           var a = await send(globalmsg);
//                           // Fluttertoast.showToast(msg: "gloab $globalmsg");
//                         }
//
//                         setState(() {});
//                       },
//                       inputOptions: InputOptions(
//                         textController: chattxted,
//                         inputTextStyle: const TextStyle( fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500, fontFamily: "Times New Roman",),
//                         sendButtonBuilder: defaultSendButton(color: Colors.green),
//                         alwaysShowSend: true,
//                         showTraillingBeforeSend: true,
//                         onTextChange: (msg) {
//                           globalmsg = msg;
//                           print(globalmsg);
//                         },
//                       ),
//
//                     )),
//
//
//
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
//
//
//


// plnr
// ✅ Full-featured Chat App with DashChat2 and Firebase

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

final picker = ImagePicker();

class chatScreen extends StatefulWidget {
  final String targetUid;
  chatScreen(this.targetUid);

  @override
  _chatScreenState createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  DocumentSnapshot? currentUserDoc;
  DocumentSnapshot? targetUserDoc;
  List messages = [];
  TextEditingController textController = TextEditingController();
  bool isTyping = false;
  String? editingMsgId;

  String getChatId(String uid1, String uid2) =>
      uid1.compareTo(uid2) <= 0 ? uid1 + uid2 : uid2 + uid1;

  @override
  void initState() {
    super.initState();
    fetchUsersAndMessages();
    updateTyping(false);
  }

  Future<void> fetchUsersAndMessages() async {
    await Firebase.initializeApp();
    currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get();
    targetUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.targetUid)
        .get();
    listenToMessages();
  }

  void listenToMessages() {
    String chatId = getChatId(auth.currentUser!.uid, widget.targetUid);
    FirebaseFirestore.instance
        .collection('userMessages')
        .doc(chatId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        setState(() => messages = doc['chat'] ?? []);
      }
    });
  }

  Future<void> updateTyping(bool typing) async {
    String chatId = getChatId(auth.currentUser!.uid, widget.targetUid);
    await FirebaseFirestore.instance
        .collection('typing')
        .doc(chatId)
        .set({auth.currentUser!.uid: typing}, SetOptions(merge: true));
  }

  Future<bool> isTargetTyping() async {
    String chatId = getChatId(auth.currentUser!.uid, widget.targetUid);
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('typing')
        .doc(chatId)
        .get();
    final data = doc.data() as Map<String, dynamic>?;
    return data?[widget.targetUid] ?? false;
  }

  Future<void> sendText(String text) async {
    String chatId = getChatId(currentUserDoc!.id, targetUserDoc!.id);
    final newMsg = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'msg': text,
      'sender': currentUserDoc!.id,
      'time': DateTime.now(),
      'read': false,
      'edited': false,
    };
    await FirebaseFirestore.instance.collection('userMessages').doc(chatId).set({
      'chat': FieldValue.arrayUnion([newMsg])
    }, SetOptions(merge: true));
    FlutterRingtonePlayer().playNotification();
  }

  Future<void> sendImage(File file) async {
    String chatId = getChatId(currentUserDoc!.id, targetUserDoc!.id);
    final ref = FirebaseStorage.instance
        .ref('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    final newMsg = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'msg': '[Image] $url',
      'sender': currentUserDoc!.id,
      'time': DateTime.now(),
      'read': false,
      'edited': false,
    };
    await FirebaseFirestore.instance.collection('userMessages').doc(chatId).set({
      'chat': FieldValue.arrayUnion([newMsg])
    }, SetOptions(merge: true));
    FlutterRingtonePlayer().playNotification();
  }

  Future<void> pickAndSendImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) sendImage(File(picked.path));
  }

  void markMessagesAsRead() async {
    String chatId = getChatId(currentUserDoc!.id, targetUserDoc!.id);
    bool updated = false;
    for (var msg in messages) {
      if (msg['sender'] == targetUserDoc!.id && msg['read'] == false) {
        msg['read'] = true;
        updated = true;
      }
    }
    if (updated) {
      await FirebaseFirestore.instance
          .collection('userMessages')
          .doc(chatId)
          .update({'chat': messages});
    }
  }

  void handleLongPress(ChatMessage msg) {
    if (msg.user.id == auth.currentUser!.uid) {
      showModalBottomSheet(
        context: context,
        builder: (_) => Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Edit"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  editingMsgId = msg.customProperties?['id'];
                  textController.text = msg.text;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text("Delete"),
              onTap: () async {
                Navigator.pop(context);
                final chatId = getChatId(currentUserDoc!.id, targetUserDoc!.id);
                messages.removeWhere((m) => m['id'] == msg.customProperties?['id']);
                await FirebaseFirestore.instance
                    .collection('userMessages')
                    .doc(chatId)
                    .update({'chat': messages});
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatUser = ChatUser(id: auth.currentUser!.uid);
    markMessagesAsRead();
    List<ChatMessage> finalMessages = messages.map((m) {
      String suffix = m['edited'] == true ? " (edited)" : "";
      return ChatMessage(
        text: (m['msg'] ?? '') + suffix,
        user: ChatUser(id: m['sender'] ?? ''),
        createdAt: m['time']?.toDate() ?? DateTime.now(),
        customProperties: {
          'id': m['id'],
          'read': m['read'],
          'sender': m['sender'],
        },
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
              NetworkImage(targetUserDoc?['profile'] ?? ''),
            ),
            SizedBox(width: 8),
            Text(targetUserDoc?['businessOwner'] ?? 'Chat'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: pickAndSendImage,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: DashChat(
              currentUser: chatUser,
              messages: finalMessages.reversed.toList(),
              onSend: (ChatMessage msg) async {
                if (editingMsgId != null) {
                  final chatId = getChatId(currentUserDoc!.id, targetUserDoc!.id);
                  final index = messages.indexWhere((e) => e['id'] == editingMsgId);
                  if (index != -1) {
                    messages[index]['msg'] = msg.text;
                    messages[index]['edited'] = true;
                    await FirebaseFirestore.instance
                        .collection('userMessages')
                        .doc(chatId)
                        .update({'chat': messages});
                  }
                  setState(() => editingMsgId = null);
                } else {
                  await sendText(msg.text);
                }
                textController.clear();
              },
              inputOptions: InputOptions(
                textController: textController,
                alwaysShowSend: true,
                showTraillingBeforeSend: true,
                inputToolbarPadding: EdgeInsets.all(8),
                sendButtonBuilder: (onSend) =>
                    IconButton(icon: Icon(Icons.send), onPressed: onSend),
                leading: [
                  IconButton(
                    icon: Icon(Icons.emoji_emotions),
                    onPressed: () => textController.text += "😊",
                  ),
                ],
                onTextChange: (text) {
                  setState(() => isTyping = text.trim().isNotEmpty);
                  updateTyping(isTyping);
                },
              ),
              messageOptions: MessageOptions(
                showCurrentUserAvatar: true,
                currentUserContainerColor: Colors.green[200],
                showOtherUsersAvatar: true,
                onLongPressMessage: handleLongPress,
              ),
            ),
          ),
          FutureBuilder(
            future: isTargetTyping(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == true) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 4),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Typing...",
                          style: TextStyle(color: Colors.grey))),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
