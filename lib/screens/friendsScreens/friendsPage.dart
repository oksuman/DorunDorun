/********************************************
 * 친구 상태를 확인할 수 있는 페이지입니다.
 * (현재 친구 목록, 친구 대기 목록)로 구성되어 있습니다.
 ********************************************/

import 'package:dorun_dorun/utilities/storageService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utilities/firebaseService.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  bool _leftClicked = true;
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection("users"); //파이베이스 유저 컬렉션 가져오기
  List<List<String>> _friendList = []; //현재 친구 목록
  List<List<String>> _waitList = []; //현재 수락 대기 중 목록
  String _uid = "";

  //스토리지로부터 uid 받아오기
  _getMyID() async {
    await StorageService().getUserID().then((value) {
      setState(() {
        _uid = value!;
      });
    });
  }

  //friend 목록 받아오기
  _getFriendList() async {
    //자신의 friend 컬렉션 받이오기
    final DocumentReference userDocument = _userCollection.doc(_uid);
    final CollectionReference friendsCollection =
        userDocument.collection("friends");
    QuerySnapshot querySnapshot = await friendsCollection.get();
    List<Map<String, dynamic>> _allFriendsData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    List<List<String>> tempList = [];
    for (int i = 0; i < _allFriendsData.length; i++) { //자신의 friend안 다큐멘트 모두 확인
      bool isAccepted = _allFriendsData[i]["accepted"];
      String tempName = _allFriendsData[i]["fullName"];
      String tempEmail = _allFriendsData[i]["email"];
      String tempID = _allFriendsData[i]["id"];
      if (isAccepted) { //자신의 friend안 다큐멘트 중 accepted 된 친구들만 찾음
        List<String> tempElement = [tempName, tempEmail, tempID];
        tempList.add(tempElement);
      }
    }
    _friendList.clear();
    _friendList = tempList; //friend 리스트에 accepted 된 친구들 저장
    setState(() {});
  }

  //수락 대기 목록 받아오기
  _getWaitList() async {
    //자신의 waiting 컬렉션 받아오기
    final DocumentReference userDocument = _userCollection.doc(_uid);
    final CollectionReference waitingCollection =
        userDocument.collection("waiting");
    QuerySnapshot querySnapshot = await waitingCollection.get();

    List<Map<String, dynamic>> waitingData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    List<List<String>> tempList = [];
    for (int i = 0; i < waitingData.length; i++) { //자신의 waiting 다큐멘트 모두 저장
      String tempName = waitingData[i]["fullName"];
      String tempEmail = waitingData[i]["email"];
      String tempID = waitingData[i]["id"];
      List<String> tempElement = [tempName, tempEmail, tempID];
      tempList.add(tempElement);
    }
    _waitList.clear();
    _waitList = tempList; //waiting 라스트에 모두 저장
    setState(() {});
  }

  //스크린 업데이트
  _updateScreen() async{
    await _getFriendList(); //친구목록 받아오기
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getMyID(); //유저 id 받아오기
    _getWaitList(); //대기목록 받아오기
  }

  @override
  Widget build(BuildContext context) {
    _updateScreen(); //스크린 업데이트
    return Scaffold(
      appBar: AppBar(
        // 앱 상단 바
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text(
          "친구 관리",
          style: TextStyle(
              color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/toFindFriendPage"); //친구 추가 페이지로
              },
              icon: Icon(Icons.person_add_alt_1))
        ],
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _getFriendList(); //친구 목록 갱신
                        _leftClicked = true; //친구 목록 보이기
                      });
                    },
                    child: Text("친구 관리",style: _leftClicked?TextStyle(color: Colors.green, fontWeight: FontWeight.bold):TextStyle(color: Colors.grey),),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _getWaitList(); //대기 목록 갱신
                        _leftClicked = false; //대기 목록 보이기
                      });
                    },
                    child: Text("친구 대기",style: _leftClicked?TextStyle(color: Colors.grey):TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
                  )
                ],
              ),
              (_leftClicked) //친구 목록 or 대기목록
                  ? _friendList.isEmpty //친구목록
                      ? Container()
                      : Container(
                          height: 500,
                          child: ListView.builder( //친구목록 보이기
                            itemCount: _friendList.length,
                            itemBuilder: (BuildContext context, int index) {

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(_friendList[index][0]), //닉네임
                                      Text(_friendList[index][1]), //이메일
                                    ],
                                  ),
                                  ElevatedButton( //친구 끝내기
                                    onPressed: () async{
                                      final fid = _friendList[index][2]; //친구 id
                                      setState(() {
                                        _friendList.removeAt(index); //친구 리스트에서 삭제
                                      });
                                      await FirebaseService(
                                          uid: _uid, fid: fid)
                                          .finishFriend(); //친구 삭제
                                    },
                                    child: Text("X"),
                                  )
                                ],
                              );
                            },
                          ),
                        )
                  : _waitList.isEmpty //수락 대기 목록
                      ? Container()
                      : Container(
                          height: 500,
                          child: ListView.builder( //수락 리스트 보이기
                            itemCount: _waitList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(_waitList[index][0]),
                                      Text(_waitList[index][1]),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      ElevatedButton( //수락 거절 버튼
                                          onPressed: () async {
                                            final fid = _waitList[index][2];
                                            setState(() {
                                              _waitList.removeAt(index);
                                            });
                                            await FirebaseService(
                                                uid: _uid, fid: fid)
                                                .acceptFriend(false); //친구 거절
                                          },
                                          child: Text("x")),
                                      ElevatedButton( //수락 승인 버튼
                                          onPressed: () async {
                                            final fid = _waitList[index][2];
                                            setState(() {
                                              _waitList.removeAt(index);
                                            });
                                            await FirebaseService(
                                                uid: _uid, fid: fid)
                                                .acceptFriend(true); //친구 수락
                                          },
                                          child: Text("+"))
                                    ],
                                  )
                                ],
                              );
                            },
                          ),
                        )
            ],
          ),
        ),
      ),
    );
  }
}
