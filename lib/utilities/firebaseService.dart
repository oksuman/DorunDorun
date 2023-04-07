/*******************************
* 파이어베이스 관련 클래스입니다.      *
*******************************/

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService{
  final String? uid; //자신의 id (user id)
  final String? fid; //상대방의 id (friend id)
  FirebaseService({this.uid, this.fid}); //argument로 받아오기

  final CollectionReference _userCollection =
    FirebaseFirestore.instance.collection("users"); //유저 컬렉션

  final CollectionReference _groupCollection =
    FirebaseFirestore.instance.collection("groups"); //그룹 컬렉션

  //유저 정보 데이터 저장
  Future savingUserData(String email, String fullName, String gender, String age, String height, String weight) async {
    //유저컬렉션에 (uid, 이메일, 닉네임, 성별, 나이, 키, 몸무게, 코인) 저장
    final DocumentReference userDocument = _userCollection.doc(uid);
    return await userDocument.set({
      "id": uid,
      "email": email,
      "fullName": fullName,
      "gender": gender,
      "age": age,
      "height": height,
      "weight": weight,
      "coins": 0,
      "group": "",
      "avatarId": (gender=="남자")?0:1,
    });
  }

  //유저 데이터 받아오기
  Future getUserData(String email) async {
    //이메일로 유저컬렉션에서 해당 유저 찾음(로그인시 사용)
    QuerySnapshot snapshot =
    await _userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //빠른 친구 요청
  Future fRequestFriend(String uemail, String ufn, String femail, String ffn) async {
    //자신의 유저 다큐멘트 안에 friend 컬렉션 생성
    final DocumentReference userDocument = _userCollection.doc(uid);
    final CollectionReference friendsCollection = userDocument.collection("friends");
    final DocumentReference friendsDocument = friendsCollection.doc(fid);

    //자신의 friend 컬렉션 안에 다큐멘트 추가(accepted: false -> 수락시 true로 바뀜)
    await friendsDocument.set({
      "id": fid,
      "email": femail,
      "fullName": ffn,
      "accepted": false,
    });

    //상대방의  다큐멘트 안에 waiting 컬렉션 생성
    final DocumentReference user2Document = _userCollection.doc(fid);
    final CollectionReference waitingCollection = user2Document.collection("waiting");
    final DocumentReference waitingDocument = waitingCollection.doc(uid);
    //상대방의 waiting 컬렉션 안에 자신 추가
    await waitingDocument.set({
      "id": uid,
      "email": uemail,
      "fullName": ufn,
    });
  }

  //친구 요청 수락
  Future acceptFriend(bool isAccepted) async {
    //자신의 friend, waiting 컬렉션
    final DocumentReference userDocument = _userCollection.doc(uid);
    final CollectionReference friendsCollection = userDocument.collection("friends");
    final CollectionReference waitingCollection = userDocument.collection("waiting");
    final DocumentReference friendsDocument = friendsCollection.doc(fid);
    final DocumentReference waitingDocument = waitingCollection.doc(fid);
    if(isAccepted) { //수락 시(반응속도 높이기 위해 앞으로 끌어다 둠)
      //자신의 waiting 다큐멘트 삭제
      await waitingDocument.delete();
    }

    //상대방의 = friend, waiting 컬렉션
    final DocumentReference user2Document = _userCollection.doc(fid);
    final CollectionReference friends2Collection = user2Document.collection("friends");
    final DocumentReference friends2Document = friends2Collection.doc(uid);

    if(isAccepted){ //수락 시
      final DocumentSnapshot userSnapshot = await userDocument.get();
      final DocumentSnapshot user2Snapshot = await user2Document.get();
      //자신의 friend 다큐멘트 생성(accepted: true)
      await friendsDocument.set({
        "id": fid,
        "email": user2Snapshot.get("email"),
        "fullName": user2Snapshot.get("fullName"),
        "accepted": true,
      });
      //상대방의 friend 다큐멘트 업데이트(accepted: true)
      await friends2Document.update({
        "id": uid,
        "email": userSnapshot.get("email"),
        "fullName": userSnapshot.get("fullName"),
        "accepted": true,
      });
    }else{ //거절 시
      //자신의 waiting 다큐멘트 삭제
      await waitingDocument.delete();
      //상대방의 friend 다큐멘트 삭제
      await friends2Document.delete();
    }
  }

  //친구 삭제
  Future finishFriend() async {
    //자신과 상대방의 friend 다큐멘트 삭제
    //자신의 friend 컬렉션
    final DocumentReference userDocument = _userCollection.doc(uid);
    final CollectionReference friendsCollection = userDocument.collection("friends");
    final DocumentReference friendsDocument = friendsCollection.doc(fid);
    await friendsDocument.delete();

    //상대방의 friend 컬렉션
    final DocumentReference user2Document = _userCollection.doc(fid);
    final CollectionReference friends2Collection = user2Document.collection("friends");
    final DocumentReference friends2Document = friends2Collection.doc(uid);
    await friends2Document.delete();
  }

  Future<String?> createGroup() async {
    DocumentReference groupDocument = await _groupCollection.add({
      "adminId": uid,
      "membersId": [],
      "groupId": "",
    });
    //멤버에 자신 추가
    await groupDocument.update({
      "membersId": FieldValue.arrayUnion([uid]),
      "groupId": groupDocument.id,
    });
    DocumentReference userDocument = _userCollection.doc(uid);
    await userDocument.update({
      "group": groupDocument.id,
    });
    return groupDocument.id;
  }
}
