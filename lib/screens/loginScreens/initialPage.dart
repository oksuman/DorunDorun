/*******************************
 * 앱을 시작할 때 나오는 페이지입니다. *
 *******************************/

import 'package:flutter/material.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 173, 181), //teal
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding( //앱 제목
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "두런두런",
                      style: TextStyle(
                          fontFamily: "SCDream",
                          color: Color.fromARGB(255, 238, 238, 238), //white
                          fontWeight: FontWeight.w900,
                          fontSize: 60),
                    )),
                Container(
                  child: Image.asset("assets/images/run_title.png"),
                ),
                const Padding( //앱 제목
                    padding: EdgeInsets.only(top:20, bottom: 100),
                    child: Text(
                      "다른 공간에서도 함께 즐기는 러닝",
                      style: TextStyle(
                          fontFamily: "SCDream",
                          color: Color.fromARGB(255, 238, 238, 238), //white
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  child: Column(
                    children: [
                      ElevatedButton( //이메일로 로그인하기 버튼
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.teal,
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, "/toSignInPage");
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Text(
                                "이메일로 로그인",
                                style: TextStyle(
                                  fontFamily: "SCDream",
                                  color: Color.fromARGB(255, 238, 238, 238),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )),
                      ElevatedButton( //계정 생성하기 버튼
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Color.fromARGB(255, 238, 238, 238),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, "/toSignUpPage");
                            //Navigator.pushNamed(context, "/toMakeUserPage");
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Text(
                                "계정 생성하기",
                                style: TextStyle(
                                  fontFamily: "SCDream",
                                  color: Color.fromARGB(255, 34, 40, 49), //black
                                  fontSize: 16,
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