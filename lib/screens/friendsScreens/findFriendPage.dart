/*****************************
 * 친구를 추가할 수 있는 페이지입니다.*
 *****************************/

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
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
  final currentUser = FirebaseAuth.instance;
  List<Map<String, dynamic>> _allWaitingData = []; //waiting 컬렉션 데이터
  List<Map<String, dynamic>> _allFriendsData = []; //friends 컬렉션 데이터

  List<String> _acceptedFList = []; //초대받은 친구 리스트
  List<String> _nAcceptedFList = []; //초대 아직 안 받은 친구 리스트
  List<String> _waitingList = []; //내가 수락 대기 리스트
  String _uid = "";
  String _uemail = "";
  String _uname = "";
  String _typedName = "";

  StreamSubscription? _friendListen = null; //친구 목록 스트림 구독(종료시 끊음)
  StreamSubscription? _waitingListen = null; //대기 목록 스트림 구독(종료시 끊음)

  //스토리지에서 id 받아오기
  _getMyData() async {
    await StorageService().getUserID().then((value) {
      setState(() {
        _uid = value!;
      });
    });
    await StorageService().getUserEmail().then((value) {
      setState(() {
        _uemail = value!;
      });
    });
    await StorageService().getUserName().then((value) {
      setState(() {
        _uname = value!;
      });
    });
  }


  _getFriendList(){
    final DocumentReference userDocument = _userCollection.doc(_uid);
    final CollectionReference friendsCollection =
    userDocument.collection("friends");
    _friendListen = friendsCollection.snapshots().listen((event) {
      _allFriendsData = event.docs.map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
    List<String> tempAList = [];
    List<String> tempNAList = [];
    for (int i = 0; i < _allFriendsData.length; i++) {
      //모든 friend 다큐멘트 확인
      bool isAccepted = _allFriendsData[i]["accepted"];
      if (isAccepted) {
        //수락 됐을 시
        tempAList.add(_allFriendsData[i]["fullName"]); //친구리스트 추가
      } else {
        //수락 아직 안 됐을 시
        tempNAList.add(_allFriendsData[i]["fullName"]); //대기리스트 추가
      }
    }
    _acceptedFList.clear();
    _nAcceptedFList.clear();
    _acceptedFList = tempAList;
    _nAcceptedFList = tempNAList;
  }

  _getWaitingList(){
    final DocumentReference userDocument = _userCollection.doc(_uid);
    final CollectionReference waitingCollection =
    userDocument.collection("waiting");
    _waitingListen = waitingCollection.snapshots().listen((event) {
      _allWaitingData = event.docs.map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
    List<String> tempWList = [];
    for (int i = 0; i < _allWaitingData.length; i++) {
      //자신의 waiting 다큐멘트 모두 저장
      tempWList.add(_allWaitingData[i]["fullName"]);
    }
    _waitingList.clear();
    _waitingList = tempWList; //waiting 라스트에 모두 저장
  }

  //검색 목록 대상 여부
  bool _isinSearchList(String fullName, String id) {
    if (_checkSimilarName(fullName, _typedName) &&
        id != _uid &&
        !(_acceptedFList.contains(fullName)) &&
        !(_waitingList.contains(fullName)))
      return true;
    else
      return false;
  }

  //이름 유사성 확인
  bool _checkSimilarName(String search, String typed) {
    //입력 값이 찾는 값보다 많으면 다름
    if (typed.length > search.length) return false;
    //입력 값이 0이면 다름
    if (typed.length == 0) {
      return false;
    }
    //유사도 확인
    for (int i = 0; i < typed.length; i++) {
      if (typed[i] != search[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  //초기화
  void initState() {
    super.initState();
    _getMyData(); //자신의 uid 받기
  }

  @override
  //종료 시
  void dispose() {
    super.dispose();
    try{
      _friendListen!.cancel(); //친구 목록 스트림 구독 끊음(최적화)
      _waitingListen!.cancel(); //대기 목록 스트림 구독 끊음(최적화)
    }catch(e){
      print("스트림이 닫히지 않았습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          // 앱 상단 바
          elevation: 0,
          iconTheme: IconThemeData(color: Color.fromARGB(255, 238, 238, 238)), //white
          title: const Text(
            "친구 추가",
            style: TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 238, 238, 238), //white
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color.fromARGB(255, 0, 173, 181), //teal
          centerTitle: true,
        ),
        backgroundColor: Color.fromARGB(255, 238, 238, 238), //white
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Form(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                      });
                    },
                    onChanged: (value) async {
                      //텍스트 필드 값 바뀔 시
                      setState(() {
                        _typedName = value;
                      });
                    },
                    onSaved: (value) async {
                      setState(() {
                        _typedName = value!;
                      });
                    },
                  ),
                ),
              ),
              Container(width: MediaQuery.of(context).size.width, height: 1, color: Colors.grey,),
              Expanded(
                child: StreamBuilder(
                    stream: _userCollection.snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if(streamSnapshot.hasData){
                        return ListView.builder(
                          //검색리스트 보이기
                          itemCount: streamSnapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            _getFriendList(); //친구목록 받아오기
                            _getWaitingList(); //대기목록 받아오기
                            List<bool> isPressedList = []; //대기중 버튼 리스트
                            for(int i = 0; i<streamSnapshot.data!.docs.length; i++){
                              if(_nAcceptedFList.contains(
                                  streamSnapshot.data!.docs[i]['fullName']))
                                isPressedList.add(true);
                              else
                                isPressedList.add(false);
                            } //대기중 버튼 리스트 갱신
                            final DocumentSnapshot documentSnapshot =
                            streamSnapshot.data!.docs[index];
                            if (_isinSearchList(
                                documentSnapshot['fullName'],
                                documentSnapshot['id'])) {
                              return Card(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 20, right: 10),
                                  height: 60,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(documentSnapshot[
                                          'fullName'],
                                            style: const TextStyle(
                                              fontFamily: "SCDream",
                                              color: Color.fromARGB(255, 34, 40, 49), //black
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ), //이름
                                          Text(documentSnapshot['email'],
                                            style: const TextStyle(
                                              fontFamily: "SCDream",
                                              color: Color.fromARGB(255, 34, 40, 49), //black
                                              fontSize: 12,
                                            ),
                                          ), //이메일
                                        ],
                                      ),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            backgroundColor: const Color.fromARGB(255, 0, 173, 181), //teal
                                            elevation: 0,
                                          ),
                                          onPressed: () async {
                                            if (!_nAcceptedFList.contains(
                                                documentSnapshot['fullName'])) {
                                              //대기 중이지 않으면,
                                              setState(() {
                                                isPressedList[index]=true;
                                                _nAcceptedFList.add(documentSnapshot['fullName']);
                                              });//바로 버튼 변경
                                              await FirebaseService(
                                                  uid: _uid,
                                                  fid: documentSnapshot[
                                                  'id'])
                                                  .fRequestFriend(
                                                  _uemail,
                                                  _uname,
                                                  documentSnapshot['email'],
                                                  documentSnapshot['fullName']
                                              ); //파이어베이스 친구 요청(속도 높이기 위해 매개변수 전달)
                                            }
                                          },
                                          child: (isPressedList[index])
                                              ? const Text("대기중",
                                            style: TextStyle(
                                              fontFamily: "SCDream",
                                              color: Color.fromARGB(255, 238, 238, 238), //white
                                              fontSize: 12,
                                            ),
                                          )
                                              : const Text("신 청",
                                            style: TextStyle(
                                              fontFamily: "SCDream",
                                              color: Color.fromARGB(255, 238, 238, 238), //white
                                              fontSize: 12,
                                            ),
                                          )
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }else{
                              return Container();
                            }
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}