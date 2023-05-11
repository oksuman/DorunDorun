/********************************************
 * 친구 상태를 확인할 수 있는 페이지입니다.
 * (현재 친구 목록, 친구 대기 목록)로 구성되어 있습니다.
 ********************************************/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  final currentUser = FirebaseAuth.instance;
  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection("users"); //파이베이스 유저 컬렉션 가져오기

  _showCancelDialog(String fid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("친구 삭제"),
          content: Text("정말 친구 목록에서 삭제하겠습니까?"),
          actions: [
            CupertinoButton(
              child: Text("취소"),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            CupertinoButton(
              child: Text("삭제"),
              onPressed: () async{
                Navigator.pop(context);
                await FirebaseService(
                    uid: currentUser.currentUser!.uid,
                    fid: fid)
                    .finishFriend(); //친구 삭제
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 앱 상단 바
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 238, 238, 238)), //white
        title: const Text(
          "친구 관리",
          style: TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 238, 238, 238), //white
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/toFindFriendPage"); //친구 추가 페이지로
              },
              icon: Icon(Icons.person_add_alt_1_sharp))
        ],
        backgroundColor: Color.fromARGB(255, 0, 173, 181), //teal
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(255, 238, 238, 238),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _leftClicked = true; //친구 목록 보이기
                    });
                  },
                  child: Container(
                    width: 120,
                    height: 40,
                    child: Center(
                      child: Text(
                        "친구 목록",
                        style: _leftClicked
                            ? TextStyle(
                            fontFamily: "SCDream",
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 173, 181),
                            fontWeight: FontWeight.bold
                        ) : TextStyle(
                          fontFamily: "SCDream",
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _leftClicked = false; //대기 목록 보이기
                    });
                  },
                  child: Container(
                    width: 120,
                    height: 40,
                    child: Center(
                      child: Text(
                        "친구 대기",
                        style: !_leftClicked
                            ? TextStyle(
                            fontFamily: "SCDream",
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 173, 181),
                            fontWeight: FontWeight.bold
                        ) : TextStyle(
                          fontFamily: "SCDream",
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              color: Colors.grey,
            ),
            (_leftClicked) //친구 목록 or 대기목록
                ? Expanded(
              child: StreamBuilder(
                  stream: _userCollection
                      .doc(currentUser.currentUser!.uid)
                      .collection("friends")
                      .where('accepted', isEqualTo: true)
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData) {
                      return ListView.builder(
                        //친구목록 보이기
                        itemCount: streamSnapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];
                          return Card(
                            child: Container(
                              padding: const EdgeInsets.only(left: 10, right: 10),
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
                                        style: TextStyle(
                                          fontFamily: "SCDream",
                                          color: Color.fromARGB(255, 34, 40, 49), //black
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ), //닉네임
                                      Text(documentSnapshot['email'],
                                        style: TextStyle(
                                          fontFamily: "SCDream",
                                          color: Color.fromARGB(255, 34, 40, 49), //black
                                          fontSize: 12,
                                        ),
                                      ), //이메일
                                    ],
                                  ),
                                  SizedBox(width: 10,),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Color.fromARGB(255, 0, 173, 181), //teal
                                        ),
                                        child: IconButton(
                                          //친구 끝내기
                                          icon: Icon(Icons.list_sharp),
                                          onPressed: () async {
                                            Navigator.pushNamed(context, "/toAnalysisPage",
                                                arguments: documentSnapshot['id']);
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Color.fromARGB(255, 0, 173, 181), //teal
                                        ),
                                        child: IconButton(
                                          //친구 끝내기
                                          icon: Icon(Icons.volume_up_sharp),
                                          onPressed: () async {

                                          },
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: Colors.grey
                                        ),
                                        child: IconButton(
                                          //친구 끝내기
                                          icon: Icon(Icons.close_sharp),
                                          onPressed: () async {
                                            _showCancelDialog(documentSnapshot['id']);
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
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            )
                : Expanded(
              child: StreamBuilder(
                  stream: _userCollection
                      .doc(currentUser.currentUser!.uid)
                      .collection("waiting")
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData) {
                      return ListView.builder(
                        //수락 리스트 보이기
                        itemCount: streamSnapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];
                          return Card(
                            child: Container(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              height: 60,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(documentSnapshot['fullName'],
                                        style: TextStyle(
                                          fontFamily: "SCDream",
                                          color: Color.fromARGB(255, 34, 40, 49), //black
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(documentSnapshot['email'],
                                        style: TextStyle(
                                          fontFamily: "SCDream",
                                          color: Color.fromARGB(255, 34, 40, 49), //black
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.grey, //teal
                                        ),
                                        child: IconButton(
                                            icon: Icon(Icons.close_sharp),
                                            //수락 거절 버튼
                                            onPressed: () async {
                                              await FirebaseService(
                                                  uid: currentUser.currentUser!.uid,
                                                  fid: documentSnapshot[
                                                  'id'])
                                                  .acceptFriend(
                                                  false); //친구 거절
                                            }
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Color.fromARGB(255, 0, 173, 181), //teal
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.check_sharp),
                                          //수락 승인 버튼
                                          onPressed: () async {
                                            await FirebaseService(
                                                uid: currentUser.currentUser!.uid,
                                                fid: documentSnapshot[
                                                'id'])
                                                .acceptFriend(true); //친구 수락
                                          },
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            )
          ],
        ),
      ),
    );
  }
}