import 'package:cloud_firestore/cloud_firestore.dart';

/*******************************
* 파이어베이스 관련 클래스입니다.      *
*******************************/
class FirebaseService{
  final String? uid; //자신의 id (user id)
  final String? fid; //상대방의 id (friend id)
  final String? gid; //그룹 id (friend id)
  FirebaseService({this.uid, this.fid, this.gid}); //argument로 받아오기

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
      "runs": 0,
      "group": "",
      "avatarId": (gender=="남자")?"00":"01",
      "isKicked": false
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

  //그룹 생성
  Future<String?> createGroup(String adminName) async {
    DocumentReference groupDocument = await _groupCollection.add({
      "groupState": "idle",
      "adminId": uid,
      "adminName": adminName,
      "membersId": [],
      "membersName": [],
      "membersReady": {uid:true},
      "groupId": "",
      "membersNum" : 1,
      "groupMode": "basic",
      "basicSetting": "목표 거리",
      "basicGoal": {"목표 거리":5, "목표 시간":30,},
      "coopSetting": "1단계",
      "compSetting": "최저 페이스",
      "compGoal": {"목표 거리":5, "최저 페이스":10,},
    });
    
    DocumentReference userDocument = _userCollection.doc(uid);
    final DocumentSnapshot userSnapshot = await userDocument.get();
    //멤버에 자신 추가
    await groupDocument.update({
      "membersId": FieldValue.arrayUnion([uid]),
      "membersName": FieldValue.arrayUnion([adminName]),
      "membersAvatar": {uid:userSnapshot.get("avatarId")},
      "groupId": groupDocument.id,
    });
    //내가 속한 그룹 업데이트
    await userDocument.update({
      "group": groupDocument.id,
    });
    return groupDocument.id; //새로 생성된 그룹 아이디 반환
  }

  //친구 초대
  Future inviteFriend(String senderName) async {
    final DocumentReference user2Document = _userCollection.doc(fid);
    final CollectionReference inviteCollection = user2Document.collection("invite");
    //유저 컬렉션 속 invite 컬렉션 추가
    DocumentReference inviteDocument = await inviteCollection.add({
      "inviteId": "",
      "groupId": gid,
      "senderId": uid,
      "senderName": senderName
    });
    await inviteDocument.update({
      "inviteId": inviteDocument.id,
    });
  }

  //그룹 인원 받기
  Future<int> getGroupNum() async {
    final DocumentReference groupDocument = _groupCollection.doc(gid);
    final DocumentSnapshot groupSnapshot = await groupDocument.get();
    return groupSnapshot.get("membersNum");
  }

  //유저 상태 초기화
  Future resetUserState() async {
    final DocumentReference userDocument = _userCollection.doc(uid);
    await userDocument.update({
      "group": "", //속한 그룹 없음
      "isKicked": false, //추방 여부 false
    });
  }

  //초대 수락
  Future joinInvite(String uname, String inviteId) async {
    final DocumentReference groupDocument = _groupCollection.doc(gid);
    final DocumentSnapshot groupSnapshot = await groupDocument.get();
    //그룹 다큐멘트 업데이트
    Map<String, bool> tempReady = {};
    groupSnapshot.get("membersReady").forEach((key, value) {
      if(value.toString()=="true")
        tempReady[key] = true;
      else
        tempReady[key] = false;
    });
    tempReady[uid!] = false;
    
    final DocumentReference userDocument = _userCollection.doc(uid);
    final DocumentSnapshot userSnapshot = await userDocument.get();
    Map<String, String> tempAvatar = {};
    groupSnapshot.get("membersAvatar").forEach((key, value) {
      tempAvatar[key] = value.toString();
    });
    tempAvatar[uid!] = userSnapshot.get("avatarId");
    
    await groupDocument.update({
      "membersId": FieldValue.arrayUnion([uid]),
      "membersName": FieldValue.arrayUnion([uname]),
      "membersNum" : FieldValue.increment(1),
      "membersReady": tempReady,
      "membersAvatar": tempAvatar,
    });
    //내가 속한 그룹 업데이트
    
    await userDocument.update({
      "group": gid,
    });
    //초대 컬렉션 속 다큐멘트 제거
    final CollectionReference inviteCollection = userDocument.collection(
        "invite");
    final DocumentReference inviteDocument = inviteCollection.doc(inviteId);
    await inviteDocument.delete();
  }

  //초대 거절
  Future refuseInvite(String inviteId) async {
    //초대 컬렉션 속 다큐멘트 제거
    final DocumentReference userDocument = _userCollection.doc(uid);
    final CollectionReference inviteCollection = userDocument.collection(
        "invite");
    final DocumentReference inviteDocument = inviteCollection.doc(inviteId);
    await inviteDocument.delete();
  }

  //그룹 나가기
  Future exitGroup(String uname) async {
    //그룹 업데이트
    final DocumentReference groupDocument = _groupCollection.doc(gid);
    final DocumentSnapshot groupSnapshot = await groupDocument.get();
    Map<String, bool> tempReady = {};
    groupSnapshot.get("membersReady").forEach((key, value) {
      if(value.toString()=="true")
        tempReady[key] = true;
      else
        tempReady[key] = false;
    });
    tempReady.remove(uid);

    Map<String, String> tempAvatar = {};
    groupSnapshot.get("membersAvatar").forEach((key, value) {
      tempAvatar[key] = value.toString();
    });
    tempAvatar.remove(uid);
    
    await groupDocument.update({
      "membersId": FieldValue.arrayRemove([uid]),
      "membersName": FieldValue.arrayRemove([uname]),
      "membersReady": tempReady,
      "membersAvatar": tempAvatar,
      "membersNum" : FieldValue.increment(-1),

    });
    //유저 상태 초기화
    final DocumentReference userDocument = _userCollection.doc(uid);
    await userDocument.update({
      "group": "",
      "isKicked": false,
    });
  }

  //호스트 나가기
  Future adminExitGroup(String uname, String nextName, String nextId) async {
    final DocumentReference groupDocument = _groupCollection.doc(gid);
    final DocumentSnapshot groupSnapshot = await groupDocument.get();
    //그룹 업데이트 + 호스트 넘겨주기
    Map<String, bool> tempReady = {};
    groupSnapshot.get("membersReady").forEach((key, value) {
      if(value.toString()=="true")
        tempReady[key] = true;
      else
        tempReady[key] = false;
    });
    tempReady.remove(uid);
    tempReady[nextId] = true;

    Map<String, String> tempAvatar = {};
    groupSnapshot.get("membersAvatar").forEach((key, value) {
      tempAvatar[key] = value.toString();
    });
    tempAvatar.remove(uid);
    
    await groupDocument.update({
      "adminId" : nextId,
      "adminName" : nextName,
      "membersId": FieldValue.arrayRemove([uid]),
      "membersName": FieldValue.arrayRemove([uname]),
      "membersReady": tempReady,
      "membersAvatar": tempAvatar,
      "membersNum" : FieldValue.increment(-1),
    });
    //유저 상태 초기화
    final DocumentReference userDocument = _userCollection.doc(uid);
    await userDocument.update({
      "group": "",
      "isKicked": false,
    });
  }

  //그룹 삭제
  Future endGroup() async {
    final DocumentReference groupDocument = _groupCollection.doc(gid);
    await groupDocument.delete();
    final DocumentReference userDocument = _userCollection.doc(uid);
    //유저상태 초기화
    await userDocument.update({
      "group": "",
      "isKicked": false,
    });
  }

  //플레이어 추방
  Future kickPlayer(String fname) async {
    //그룹 업데이트
    final DocumentReference groupDocument = _groupCollection.doc(gid);
    final DocumentSnapshot groupSnapshot = await groupDocument.get();
    
    Map<String, bool> tempReady = {};
    groupSnapshot.get("membersReady").forEach((key, value) {
      if(value.toString()=="true")
        tempReady[key] = true;
      else
        tempReady[key] = false;
    });
    tempReady.remove(fid);

    Map<String, String> tempAvatar = {};
    groupSnapshot.get("membersAvatar").forEach((key, value) {
      tempAvatar[key] = value.toString();
    });
    tempAvatar.remove(fid);
    
    await groupDocument.update({
      "membersId": FieldValue.arrayRemove([fid]),
      "membersName": FieldValue.arrayRemove([fname]),
      "membersReady": tempReady,
      "membersAvatar": tempAvatar,
      "membersNum" : FieldValue.increment(-1),

    });
    //유저 상태 -> 추방
    final DocumentReference userDocument = _userCollection.doc(fid);
    await userDocument.update({
      "isKicked": true,
    });
  }

  //아바타 ID get
  Future<String> getAvatarId() async {
    final DocumentReference userDocument = _userCollection.doc(uid);
    final DocumentSnapshot userSnapshot = await userDocument.get();
    return userSnapshot.get("avatarId");
  }
  //아바타 ID set
  Future setAvatarId(String avatarId) async {
    final DocumentReference userDocument = _userCollection.doc(uid);
    await userDocument.update({
      "membersId": avatarId,
    });
  }

  Future setBasicMode(String bSetting, Map<String,dynamic> bGoal,) async {
    final DocumentReference groupDocument = _groupCollection.doc(gid);
    await groupDocument.update({
      "groupMode": "basic",
      "basicSetting": bSetting,
      "basicGoal": bGoal,
    });
  }
  Future setCoopMode(String copSetting) async {
    final DocumentReference groupDocument = _groupCollection.doc(gid);
    await groupDocument.update({
      "groupMode": "coop",
      "coopSetting": copSetting,
    });
  }
  Future setCompMode(String cmpSetting, Map<String,dynamic> cmpGoal) async {
    final DocumentReference groupDocument = _groupCollection.doc(gid);
    await groupDocument.update({
      "groupMode": "comp",
      "compSetting": cmpSetting,
      "compGoal": cmpGoal,
    });
  }
  Future setReady(bool isready) async {
    final DocumentReference groupDocument = _groupCollection.doc(gid);
    final DocumentSnapshot groupSnapshot = await groupDocument.get();
    Map<String, bool> tempReady = {};
    groupSnapshot.get("membersReady").forEach((key, value) {
      if(value.toString()=="true")
        tempReady[key] = true;
      else
        tempReady[key] = false;
    });
    tempReady[uid!] = isready;
    await groupDocument.update({
      "membersReady": tempReady,
    });
  }
  Future setGroupState(bool isRunning) async {
    final DocumentReference groupDocument = _groupCollection.doc(gid);
    String gstate = (isRunning)?"running":"idle";
    await groupDocument.update({
      "groupState": gstate,
    });
  }
  Future ttsSend(String senderName, String msg) async {
    final DocumentReference userDocument = _userCollection.doc(fid);
    final CollectionReference ttsCollection = userDocument.collection("tts");
    //유저 컬렉션 속 tts 컬렉션 추가
    DocumentReference ttsDocument = await ttsCollection.add({
      "ttsId": "",
      "senderId": uid,
      "senderName": senderName,
      "receiverId": fid,
      "message": msg,
    });
    await ttsDocument.update({
      "ttsId": ttsDocument.id,
    });
  }
  Future ttsClear(String ttsId) async {
    final DocumentReference userDocument = _userCollection.doc(uid);
    final CollectionReference ttsCollection = userDocument.collection("tts");
    final DocumentReference ttsDocument = ttsCollection.doc(ttsId);
    await ttsDocument.delete();
  }

  Future incRunCount() async {
    final DocumentReference userDocument = _userCollection.doc(uid);
    await userDocument.update({
      "runs": FieldValue.increment(1),
    });
  }

  Future<int> getRunCount() async {
    final DocumentReference userDocument = _userCollection.doc(uid);
    final DocumentSnapshot userSnapshot = await userDocument.get();
    return userSnapshot.get("runs");
  }
}
