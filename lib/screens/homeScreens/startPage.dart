/*******************************
 * 러닝을 시작할 수 있는 페이지입니다.  *
 *******************************/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorun_dorun/utilities/firebaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  String _uemail = ""; //내 이름
  String _ugroup = ""; //내가 현재 속한 그룹
  String _clickedGroupId = ""; // 메시지 창에서 클릭한 그룹 ID
  String _clickedInviteId = ""; // 메시지 창에서 클릭한 초대 ID

  //스토리지에서 내 정보 가져오기
  _getMyData() async {
    if (mounted) {
      try {
        await StorageService().getUserID().then((value) {
          //내 아이디
          setState(() {
            _uid = value!;
          });
        });
        await StorageService().getUserName().then((value) {
          //내 이름
          setState(() {
            _uname = value!;
          });
        });
        await StorageService().getUserGroup().then((value) {
          //내 그룹
          setState(() {
            _ugroup = value!;
          });
        });
        await StorageService().getUserEmail().then((value) {
          //내 그룹
          setState(() {
            _uemail = value!;
          });
        });
      } catch (NullPointException) {}
    }
  }

  void _showRoomAlert(String err) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("접속 실패"),
          content: Text(err),
          actions: [
            CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getMyData(); // 시작할 때 내 정보 한번 가져온다.
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _getMyData();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 238, 238), //white
      appBar: AppBar( //앱 상단 바
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 34, 40, 49)),
        title: const Text(
          "마이룸",
          style: TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 34, 40, 49),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 238, 238, 238), //white
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _uname,
                style: const TextStyle(
                    fontFamily: "SCDream",
                    color: Color.fromARGB(255, 238, 238, 238), //white
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                _uemail,
                style: const TextStyle(
                  fontFamily: "SCDream",
                  color: Color.fromARGB(255, 238, 238, 238), //white
                  fontSize: 14,
                ),
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 173, 181), //teal
              ),
            ),
            ListTile(
              leading: const Icon(Icons.mark_as_unread_sharp),
              iconColor: const Color.fromARGB(255, 0, 173, 181),
              //teal
              focusColor: const Color.fromARGB(255, 0, 173, 181),
              //teal
              title: const Text(
                '메시지함',
                style: TextStyle(
                  fontFamily: "SCDream",
                  color: Color.fromARGB(255, 34, 40, 49), //black
                  fontSize: 14,
                ),
              ),
              onTap: () {
                _showMsgDialog();
              },
              trailing: const Icon(Icons.navigate_next),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              iconColor: const Color.fromARGB(255, 0, 173, 181),
              //teal
              focusColor: const Color.fromARGB(255, 0, 173, 181),
              //teal
              title: const Text(
                '설정',
                style: TextStyle(
                  fontFamily: "SCDream",
                  color: Color.fromARGB(255, 34, 40, 49), //black
                  fontSize: 14,
                ),
              ),
              onTap: () {

              },
              trailing: const Icon(Icons.navigate_next),
            ),
            ListTile(
              leading: const Icon(Icons.logout_sharp),
              iconColor: const Color.fromARGB(255, 0, 173, 181),
              //teal
              focusColor: const Color.fromARGB(255, 0, 173, 181),
              //teal
              title: const Text(
                '로그아웃',
                style: TextStyle(
                  fontFamily: "SCDream",
                  color: Color.fromARGB(255, 34, 40, 49), //black
                  fontSize: 14,
                ),
              ),
              onTap: () async {
                await StorageService().deleteAll();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/toInitialPage', (route) => false); //로그인
              },
              trailing: const Icon(Icons.navigate_next),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: 500,
              color: Colors.grey,
              child: const Text("아바타창") //내 아바타 들어갈 위치
              ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: MediaQuery.of(context).size.height-690,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(width: 20, color: (_ugroup == "")?Colors.teal:Colors.blue),
                      borderRadius: BorderRadius.circular(50),
                      color: (_ugroup == "")
                          ? const Color.fromARGB(255, 0, 173, 181)
                          : Colors.lightBlueAccent, //teal
                    ),
                    child: IconButton(
                      //달리기 버튼
                      icon: const Icon(Icons.directions_run_sharp),
                      iconSize: (40),
                      color: const Color.fromARGB(255, 238, 238, 238), //white
                      onPressed: () async {
                        Navigator.pushNamed(context, "/toMakeRoomPage",
                            arguments: ""); //메이크 룸 이동
                      },
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _showMsgDialog() {
    showDialog(
        // 메시지 창 뛰움
        context: context,
        builder: (context) {
          return AlertDialog(
            //메시지 창
            contentPadding: const EdgeInsets.only(top: 0),
            backgroundColor: const Color.fromARGB(255, 238, 238, 238), //white
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      "메시지함",
                      style: TextStyle(
                          fontFamily: "SCDream",
                          color: Color.fromARGB(255, 34, 40, 49), //black
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  StreamBuilder(
                      stream: _userCollection
                          .doc(currentUser.currentUser!.uid)
                          .collection("invite")
                          .snapshots(),
                      //유저 컬렉션 속 invite 컬렉션 스트림 받아오기
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        if (streamSnapshot.hasData) {
                          //초대 받은게 있으면 표시, 없으면 빈 컨테이너
                          return Expanded(
                            child: ListView.builder(
                              //친구목록 보이기
                              itemCount: streamSnapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                final DocumentSnapshot documentSnapshot =
                                    streamSnapshot
                                        .data!.docs[index]; //초대 다큐멘트 하나
                                return Card(
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    height: 60,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              documentSnapshot['senderName'] +
                                                  "님이",
                                              style: const TextStyle(
                                                fontFamily: "SCDream",
                                                color: Color.fromARGB(
                                                    255, 34, 40, 49), //black
                                                fontSize: 14,
                                              ),
                                            ),
                                            //초대 보낸 유저 이름
                                            const Text(
                                              "초대를 보냈습니다!",
                                              style: TextStyle(
                                                fontFamily: "SCDream",
                                                color: Color.fromARGB(
                                                    255, 34, 40, 49), //black
                                                fontSize: 14,
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.grey),
                                              child: IconButton(
                                                //초대 거절 버튼
                                                icon: Icon(Icons.close_sharp),
                                                onPressed: () async {
                                                  Navigator.of(context)
                                                      .pop(); //메시지 창 pop
                                                  await FirebaseService(
                                                    //초대 거절
                                                    uid: _uid,
                                                  ).refuseInvite(
                                                      documentSnapshot[
                                                          'inviteId']);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: const Color.fromARGB(
                                                    255, 0, 173, 181), //teal
                                              ),
                                              child: IconButton(
                                                //초대 수락 버튼
                                                icon: const Icon(
                                                  Icons.check_sharp,
                                                ),
                                                onPressed: () async {
                                                  _clickedGroupId =
                                                      documentSnapshot[
                                                          'groupId']; //선택한 그룹 아이디
                                                  _clickedInviteId =
                                                      documentSnapshot[
                                                          'inviteId']; //선택한 초대 아이디
                                                  try {
                                                    // 방 접속 시도
                                                    int memNum = await FirebaseService(
                                                            gid:
                                                                _clickedGroupId)
                                                        .getGroupNum(); //그룹 인원 받아오기
                                                    if (_ugroup == "") {
                                                      // 현재 속한 그룹이 없을 때,
                                                      if (memNum < 4) {
                                                        // 만약 그룹이 풀방이 아닐 때,
                                                        Navigator.popAndPushNamed(
                                                            context,
                                                            "/toMakeRoomPage",
                                                            arguments:
                                                                _clickedGroupId); //메이크룸 이동
                                                        await FirebaseService(
                                                                uid: _uid,
                                                                gid:
                                                                    _clickedGroupId)
                                                            .joinInvite(_uname,
                                                                _clickedInviteId); //초대 수락
                                                      } else {
                                                        // 그룹이 풀방일 시,
                                                        Navigator.of(context)
                                                            .pop();
                                                        _showRoomAlert(
                                                            "방이 최대 인원에 도달했습니다.");
                                                        await FirebaseService(
                                                          uid: _uid,
                                                        ).refuseInvite(
                                                            _clickedInviteId); //초대 거절
                                                      }
                                                    } else {
                                                      //속한 그룹이 있을 때
                                                      Navigator.of(context)
                                                          .pop();
                                                      _showRoomAlert(
                                                          "이미 속한 그룹이 있습니다.");
                                                      await FirebaseService(
                                                        uid: _uid,
                                                      ).refuseInvite(
                                                          _clickedInviteId); //초대 거절
                                                    }
                                                  } catch (e) {
                                                    //오류 발생시(존재하지 않는 방에 접속 시도)
                                                    print(e); //오류 프린트
                                                    Navigator.of(context).pop();
                                                    _showRoomAlert(
                                                        "존재하지 않는 방입니다.");
                                                    await FirebaseService(
                                                      uid: _uid,
                                                    ).refuseInvite(
                                                        _clickedInviteId); //초대 거절
                                                    //파이어베이스 초기화
                                                    await FirebaseService(
                                                      uid: _uid,
                                                    ).resetUserState(); //유저 상태(속한 그룹, 추방 여부) 초기화
                                                    StorageService()
                                                        .saveUserGroup(
                                                            ""); //속한 그룹 없음으로 변경
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      }),
                ],
              ),
            ),
          );
        });
  }
}
