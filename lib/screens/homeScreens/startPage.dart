/*******************************
 * 러닝을 시작할 수 있는 페이지입니다.  *
 *******************************/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorun_dorun/utilities/firebaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utilities/storageService.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final currentUser = FirebaseAuth.instance;
  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection("users"); //파이베이스 유저 컬렉션 가져오기
  String _uid = ""; //내 ID
  String _uname = ""; //내 이름
  String _ugroup = ""; //내가 현재 속한 그룹
  String _clickedGroupId = ""; // 메시지 창에서 클릭한 그룹 ID
  String _clickedInviteId = ""; // 메시지 창에서 클릭한 초대 ID

  //스토리지에서 내 정보 가져오기
  _getMyData() async {
    await StorageService().getUserID().then((value) { //내 아이디
      setState(() {
        _uid = value!;
      });
    });
    await StorageService().getUserName().then((value) { //내 이름
      setState(() {
        _uname = value!;
      });
    });
    await StorageService().getUserGroup().then((value) { //내 그룹
      setState(() {
        _ugroup = value!;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getMyData(); // 시작할 때 내 정보 한번 가져온다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // 앱 상단 바
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text(
          "시작화면",
          style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      drawer: Drawer(

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 500,
              color: Colors.grey,
              child: Text("아바타창") //내 아바타 들어갈 위치
            ),
            SizedBox(height:45),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton( //메시지함 버튼
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.yellow,
                    ),
                    onPressed: () async{
                      showDialog( // 메시지 창 뛰움
                          context: context,
                          builder: (context) {
                            return AlertDialog( //메시지 창
                              contentPadding: EdgeInsets.only(top: 0),
                              content: Container(
                                width: MediaQuery.of(context).size.width*0.8,
                                height: MediaQuery.of(context).size.height*0.6,
                                child: Column(
                                  children: [
                                    Text("메시지함"),
                                    StreamBuilder(
                                        stream: _userCollection
                                            .doc(currentUser.currentUser!.uid)
                                            .collection("invite")
                                            .snapshots(), //유저 컬렉션 속 invite 컬렉션 스트림 받아오기
                                        builder: (context,
                                            AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                                          if (streamSnapshot.hasData) { //초대 받은게 있으면 표시, 없으면 빈 컨테이너
                                            return Expanded(
                                              child: ListView.builder(
                                                //친구목록 보이기
                                                itemCount: streamSnapshot.data!.docs.length,
                                                itemBuilder:
                                                    (BuildContext context, int index) {
                                                  final DocumentSnapshot documentSnapshot =
                                                  streamSnapshot.data!.docs[index]; //초대 다큐멘트 하나
                                                  return Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Text(documentSnapshot['senderName']+"님이"), //초대 보낸 유저 이름
                                                          Text("초대를 보냈습니다!")
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          ElevatedButton(//초대 거절 버튼
                                                            onPressed: () async {
                                                              Navigator.of(context).pop(); //메시지 창 pop
                                                              await FirebaseService( //초대 거절
                                                                  uid: _uid,
                                                                  )
                                                                  .refuseInvite(documentSnapshot['inviteId']);
                                                            },
                                                            child: Text("X"),
                                                          ),
                                                          ElevatedButton(//초대 수락 버튼
                                                            onPressed: () async {
                                                              _clickedGroupId = documentSnapshot['groupId']; //선택한 그룹 아이디
                                                              _clickedInviteId = documentSnapshot['inviteId']; //선택한 초대 아이디
                                                              try{// 방 접속 시도
                                                                int memNum = await FirebaseService(
                                                                    gid: _clickedGroupId)
                                                                    .getGroupNum(); //그룹 인원 받아오기
                                                                if(_ugroup==""){ // 현재 속한 그룹이 없을 때,
                                                                  if(memNum<4){ // 만약 그룹이 풀방이 아닐 때,
                                                                    Navigator.popAndPushNamed(context, "/toMakeRoomPage", arguments: _clickedGroupId); //메이크룸 이동
                                                                    await FirebaseService(
                                                                        uid: _uid,
                                                                        gid: _clickedGroupId)
                                                                        .joinInvite(
                                                                        _uname,
                                                                        _clickedInviteId); //초대 수락
                                                                  }else{ // 그룹이 풀방일 시,
                                                                    print("풀방입니다.");
                                                                    Navigator.of(context).pop();
                                                                    await FirebaseService(
                                                                      uid: _uid,
                                                                    )
                                                                        .refuseInvite(_clickedInviteId); //초대 거절
                                                                  }
                                                                }else{ //속한 그룹이 있을 때
                                                                  print("이미 접속한 방이 있습니다.");
                                                                  Navigator.of(context).pop();
                                                                  await FirebaseService(
                                                                    uid: _uid,
                                                                  )
                                                                      .refuseInvite(_clickedInviteId); //초대 거절
                                                                }
                                                              }catch(e){ //오류 발생시(존재하지 않는 방에 접속 시도)
                                                                print(e);//오류 프린트
                                                                print("존재하지 않는 방입니다.");
                                                                Navigator.of(context).pop();
                                                                await FirebaseService(
                                                                  uid: _uid,
                                                                )
                                                                    .refuseInvite(_clickedInviteId); //초대 거절
                                                                //파이어베이스 초기화
                                                                await FirebaseService(
                                                                  uid: _uid,
                                                                ).
                                                                resetUserState(); //유저 상태(속한 그룹, 추방 여부) 초기화
                                                                StorageService().saveUserGroup(""); //속한 그룹 없음으로 변경
                                                              }
                                                            },
                                                            child: Text("O"),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  );
                                                },
                                              ),
                                            );
                                          }
                                          return Center(
                                              child: CircularProgressIndicator());
                                        }),
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    child: Text(
                      "메시지함",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    )),
                ElevatedButton( //달리기 버튼
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.yellow,
                    ),
                    onPressed: () async{
                      Navigator.pushNamed(context, "/toMakeRoomPage", arguments: ""); //메이크 룸 이동
                    },

                    child: Text(
                      "시작",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    )),
                ElevatedButton( //아바타 버튼
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.yellow,
                    ),
                    onPressed: () async{

                    },

                    child: Text(
                      "아바타",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    )),
              ],
            )

          ],
        ),
      ),
    );


  }
}
