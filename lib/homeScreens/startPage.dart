/*******************************
 * 러닝을 시작할 수 있는 페이지입니다.  *
 *******************************/

import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton( //계정 생성하기 버튼
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.yellow,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/toRunningPage");
                },
                child: Text(
                  "달리기 시작",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
