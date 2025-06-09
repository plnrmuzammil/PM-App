import "package:cloud_firestore/cloud_firestore.dart";

FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference users = FirebaseFirestore.instance.collection('users');

setUserDetails(uid, {name = "", profile = "", email = "", phone = ""}) async {
  //name=name==null?"":name;
  //profile=profile==null?"":profile;
  email = email ?? "";
  phone = phone ?? "";

  DocumentSnapshot doc = await users.doc(uid).get();
  var existingData = doc.data() as  Map<String,dynamic>;

  print('Existing data is not null');
  existingData["id"] = existingData["id"] ?? uid;
  existingData["approved"] =
      existingData["approved"] ?? false;
  existingData["name"] = existingData["name"] ?? "";
  existingData["profile"] = existingData["profile"] ?? "";
  existingData["phone"] = phone;
  existingData["email"] = email;
  existingData["officeAddress"] = existingData["officeAddress"] ?? "";
  existingData["registrationDocumentBackPic"] ?? "";
  existingData["registrationDocumentFrontPic"] ?? "";
  existingData["registrationNumber"] ?? "";
  existingData["businessName"] ?? "";
  existingData["businessOwner"] ?? "";
  existingData["idCardFrontPic"] ?? "";
  existingData["idCardBackPic"] ?? "";

  await users.doc(uid).update(existingData);
  return null;
}
