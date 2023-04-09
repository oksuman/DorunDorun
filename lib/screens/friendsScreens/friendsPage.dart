/********************************************
 * 친구 상태를 확인할 수 있는 페이지입니다.
 * (현재 친구 목록, 친구 대기 목록)로 구성되어 있습니다.
 ********************************************/

import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    "친구 관리",
                    style: _leftClicked
                        ? TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)
                        : TextStyle(color: Colors.grey),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _leftClicked = false; //대기 목록 보이기
                    });
                  },
                  child: Text(
                    "친구 대기",
                    style: _leftClicked
                        ? TextStyle(color: Colors.grey)
                        : TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                )
              ],
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
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(documentSnapshot[
                                            'fullName']), //닉네임
                                        Text(documentSnapshot['email']), //이메일
                                      ],
                                    ),
                                    ElevatedButton(
                                      //친구 끝내기
                                      onPressed: () async {
                                        await FirebaseService(
                                                uid: currentUser.currentUser!.uid,
                                                fid: documentSnapshot['id'])
                                            .finishFriend(); //친구 삭제
                                      },
                                      child: Text("X"),
                                    )
                                  ],
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
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(documentSnapshot['fullName']),
                                        Text(documentSnapshot['email']),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                            //수락 거절 버튼
                                            onPressed: () async {
                                              await FirebaseService(
                                                      uid: currentUser.currentUser!.uid,
                                                      fid: documentSnapshot[
                                                          'id'])
                                                  .acceptFriend(
                                                      false); //친구 거절
                                            },
                                            child: Text("x")),
                                        ElevatedButton(
                                            //수락 승인 버튼
                                            onPressed: () async {
                                              await FirebaseService(
                                                      uid: currentUser.currentUser!.uid,
                                                      fid: documentSnapshot[
                                                          'id'])
                                                  .acceptFriend(true); //친구 수락
                                            },
                                            child: Text("+"))
                                      ],
                                    )
                                  ],
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