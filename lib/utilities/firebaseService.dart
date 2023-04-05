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
    });
  }

  //유저 데이터 받아오기
  Future getUserData(String email) async {
    //이메일로 유저컬렉션에서 해당 유저 찾음(로그인시 사용)
    QuerySnapshot snapshot =
    await _userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //친구 요청
  Future requestFriend() async {
    //자신의 유저 다큐멘트 안에 friend 컬렉션 생성
    final DocumentReference userDocument = _userCollection.doc(uid);
    final CollectionReference friendsCollection = userDocument.collection("friends");
    final DocumentReference friendsDocument = friendsCollection.doc(fid);
    final DocumentSnapshot userSnapshot = await userDocument.get();

    //상대방의  다큐멘트 안에 waiting 컬렉션 생성
    final DocumentReference user2Document = _userCollection.doc(fid);
    final CollectionReference waitingCollection = user2Document.collection("waiting");
    final DocumentReference waitingDocument = waitingCollection.doc(uid);
    final DocumentSnapshot user2Snapshot = await user2Document.get();

    //자신의 friend 컬렉션 안에 다큐멘트 추가(accepted: false -> 수락시 true로 바뀜)
    await friendsDocument.set({
      "id": fid,
      "email": user2Snapshot.get("email"),
      "fullName": user2Snapshot.get("fullName"),
      "accepted": false,
    });

    //상대방의 waiting 컬렉션 안에 자신 추가
    await waitingDocument.set({
      "id": uid,
      "email": userSnapshot.get("email"),
      "fullName": userSnapshot.get("fullName"),
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
    final DocumentSnapshot userSnapshot = await userDocument.get();

    //상대방의 = friend, waiting 컬렉션
    final DocumentReference user2Document = _userCollection.doc(fid);
    final CollectionReference friends2Collection = user2Document.collection("friends");
    final CollectionReference waiting2Collection = user2Document.collection("waiting");
    final DocumentReference friends2Document = friends2Collection.doc(uid);
    final DocumentReference waiting2Document = waiting2Collection.doc(uid);
    final DocumentSnapshot user2Snapshot = await user2Document.get();


    if(isAccepted){ //수락 시
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
      //자신의 waiting 다큐멘트 삭제
      await waitingDocument.delete();
    }else{ //거절 시
      //자신의 waiting 다큐멘트 삭제
      await waitingDocument.delete();
      //상대방의 friend 다큐멘트 삭제
      await friends2Document.delete();
    }

  }

  //친구 삭제
  Future finishFriend() async {
    //자신의 friend 컬렉션
    final DocumentReference userDocument = _userCollection.doc(uid);
    final CollectionReference friendsCollection = userDocument.collection("friends");
    final DocumentReference friendsDocument = friendsCollection.doc(fid);

    //상대방의 friend 컬렉션
    final DocumentReference user2Document = _userCollection.doc(fid);
    final CollectionReference friends2Collection = user2Document.collection("friends");
    final DocumentReference friends2Document = friends2Collection.doc(uid);

    //자신과 상대방의 friend 다큐멘트 삭제
    await friendsDocument.delete();
    await friends2Document.delete();
  }
}
