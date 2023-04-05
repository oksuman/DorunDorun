/*****************************
 * 친구를 추가할 수 있는 페이지입니다.*
 *****************************/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utilities/firebaseService.dart';
import '../../utilities/storageService.dart';

class FindFriendPage extends StatefulWidget {
  const FindFriendPage({Key? key}) : super(key: key);

  @override
  State<FindFriendPage> createState() => _FindFriendPageState();
}

class _FindFriendPageState extends State<FindFriendPage> {
  final CollectionReference _userCollection =
    FirebaseFirestore.instance.collection("users"); //유저 컬렉션
  List<Map<String, dynamic>> _allUserData = []; //모든 유저 데이터
  List<List<String>> _searchedList = []; //검색된 리스트
  List<List<String>> _friendList = []; //친구 리스트
  List<List<String>> _waitingList = []; //보낸 수락 대기 리스트
  List<List<String>> _myWaitList = []; //내가 수락 대기 리스트
  String _uid = "";

  //스토리지에서 id 받아오기
  _getMyID() async {
    await StorageService().getUserID().then((value) {
      setState(() {
        _uid = value!;
      });
    });
  }

  //모든 유저 데이터 받아오기
  _getAllUsers() async{
    QuerySnapshot querySnapshot
    = await _userCollection.get();
    _allUserData
    = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  //친구목록, 대기목록 받아오기
  _getAllFriendList() async {
    //friend 컬렉션
    final DocumentReference userDocument = _userCollection.doc(_uid);
    final CollectionReference friendsCollection =
      userDocument.collection("friends");
    QuerySnapshot querySnapshot = await friendsCollection.get();
    List<Map<String, dynamic>> _allFriendsData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    List<List<String>> tempfList = [];
    List<List<String>> tempwList = [];
    for (int i = 0; i < _allFriendsData.length; i++) { //모든 friend 다큐멘트 확인
      bool isAccepted = _allFriendsData[i]["accepted"];
      String tempName = _allFriendsData[i]["fullName"];
      String tempEmail = _allFriendsData[i]["email"];
      String tempID = _allFriendsData[i]["id"];
      List<String> tempElement = [tempName, tempEmail, tempID];
      if (isAccepted) { //수락 됐을 시
        tempfList.add(tempElement); //친구리스트 추가
      }else{ //수락 아직 안 됐을 시
        tempwList.add(tempElement); //대기리스트 추가
      }
    }
    _friendList.clear();
    _waitingList.clear();
    _friendList = tempfList;
    _waitingList = tempwList;
    print(_friendList);
    print(_waitingList);
    setState(() {});
  }

  _getMyWaitList() async {
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
    _myWaitList.clear();
    _myWaitList = tempList; //waiting 라스트에 모두 저장
    setState(() {});
  }

  //검색 리스트 갱신
  _updateNameList(String searchName) async {
    List<List<String>> tempList = [];
    for(int i=0; i<_allUserData.length; i++){
      String tempName = _allUserData[i]["fullName"];
      String tempEmail = _allUserData[i]["email"];
      String tempID = _allUserData[i]["id"];
      List<String> tempElement = [tempName, tempEmail, tempID];
      //중복 닉네임 & 자신의 ID & 이미 친구 목록인지 & 대기 목록인지 확인
      if(_checkSimilarName(tempName, searchName)
          && tempID!=_uid
          && !(_checkElementContain(_friendList,tempElement))
          && !(_checkElementContain(_myWaitList,tempElement))
      ){
        tempList.add(tempElement);
      }
    }
    _searchedList.clear();
    _searchedList = tempList;
  }

  //이름 유사성 확인
  bool _checkSimilarName(String search, String typed){
    //입력 값이 찾는 값보다 많으면 다름
    if(typed.length>search.length)
      return false;
    //입력 값이 0이면 다름
    if (typed.length==0){
      return false;
    }
    //유사도 확인
    for(int i = 0; i<typed.length; i++){
      if(typed[i]!=search[i]){
        return false;
      }
    }
    return true;
  }

  //리스토 속 요소 포함 여부 확인
  bool _checkElementContain(List<List<String>> checkList, List<String> element){
    bool isContaining = false;
    checkList.forEach((e) {
      if(listEquals(e, element)){
        isContaining = true;
      }
    });
    return isContaining;
  }

  //스크린 업데이트
  _updateScreen() async{
    _getMyWaitList(); //모든 유저 데이터 받기
    setState(() {});
  }

  @override
  //초기화
  void initState() {
    super.initState();
    _getMyID(); //자신의 uid 받기
    _getAllUsers(); //모든 유저 데이터 받기
  }

  @override
  Widget build(BuildContext context) {
    _updateScreen();
    List<bool> isWaitingList = [];
    return Scaffold(
      appBar: AppBar(
        // 앱 상단 바
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text(
          "친구 추가",
          style: TextStyle(
              color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Form(
                child: TextFormField(
                  onTap: (){
                    setState(() {
                      _getMyWaitList(); //모든 유저 데이터 받기
                      _getAllFriendList(); //친구,대기 목록 받기
                    });
                  },
                  onChanged: (value) async { //텍스트 필드 값 바뀔 시
                    setState(() {
                      _updateNameList(value); //검색 리스트 업데이트
                    });
                  },
                  onSaved: (value) async {
                    setState(() {
                      _updateNameList(value!);
                    });
                  },
                ),
              ),
              _searchedList.isEmpty
                  ? Container()
                  : Container(
                      height: 500,
                      child: ListView.builder( //검색리스트 보이기
                        itemCount: _searchedList.length,
                        itemBuilder: (BuildContext context, int index) {
                          bool isWaiting = false; //수락 대기중인지
                          _waitingList.forEach((element) { //수락 대기 목록 중 대기중인 index 확인
                            if(listEquals(_searchedList[index],element))
                              isWaiting = true;
                          });
                          isWaitingList.add(isWaiting); //대기중인 index 저장

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(_searchedList[index][0]), //이름
                                  Text(_searchedList[index][1]), //이메일
                                ],
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    if(!isWaiting){ //대기 중이지 않으면,
                                      setState(() {
                                        _waitingList.add(_searchedList[index]);
                                      });
                                      await FirebaseService(
                                          uid: _uid,
                                          fid: _searchedList[index][2])
                                          .requestFriend(); //파이어베이스 친구 요청
                                    }

                                  },
                                  child: (isWaitingList[index])?Text("대기중"):Text("+"))
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
