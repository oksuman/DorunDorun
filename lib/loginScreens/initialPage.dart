/*******************************
 * 앱을 시작할 때 나오는 페이지입니다. *
 *******************************/

import 'package:flutter/material.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar( //앱 상단 바
          elevation: 0,
          title: const Text(
            "두런두런",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: Colors.yellow,
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Center(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Container( //로그인 이미지
                color: Colors.grey,
                width: 300,
                height: 300,
                child: const Text("Image1"),
              ),
            ),
            const Padding( //앱 부제 텍스트
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  "다른 장소에 있는 친구들과 함께 달려보세요!(가제)",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                )),
            Padding(
              padding: EdgeInsets.only(top: 40, left: 40, right: 40),
              child: Column(
                children: [
                  ElevatedButton( //이메일로 로그인하기 버튼
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.yellow,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/toSignInPage");
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "이메일로 로그인",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )),
                  ElevatedButton( //계정 생성하기 버튼
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.yellow,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/toSignUpPage");
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "계정 생성하기",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            )
          ],
        )));
  }
}
