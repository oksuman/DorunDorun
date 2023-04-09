import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // 앱 상단 바
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            "기록 관리",
            style: TextStyle(
                color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold
            ),
          ),
          backgroundColor: Colors.yellow,
          centerTitle: true,
        ),
        body: ElevatedButton( //달리기 버튼
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.yellow,
            ),
            onPressed: ()=>debugPrint("detail pushed"),
            child: const Text(
              "기록으로 달리기",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            )),
    );

  }
}
