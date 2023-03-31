/*******************************
* 파이어베이스 관련 클래스입니다.      *
*******************************/

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService{
  final String? uid;
  FirebaseService({this.uid});

  final CollectionReference userCollection =
    FirebaseFirestore.instance.collection("users");

  Future savingUserData(String email, String fullName, String gender, String age, String height, String weight) async {
    return await userCollection.doc(uid).set({
      "uid": uid,
      "email": email,
      "fullName": fullName,
      "gender": gender,
      "age": age,
      "height": height,
      "weight": weight,
      "coins": 0,
      "friends": [],
    });
  }

}
