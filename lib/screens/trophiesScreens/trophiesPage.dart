import 'package:dorun_dorun/utilities/firebaseService.dart';
import 'package:flutter/material.dart';

import '../../utilities/storageService.dart';

class TrophiesPage extends StatefulWidget {
  const TrophiesPage({Key? key}) : super(key: key);

  @override
  State<TrophiesPage> createState() => _TrophiesPageState();
}

class _TrophiesPageState extends State<TrophiesPage> {
  String _uid = ""; //내 ID
  String _uname = ""; //내 이름
  int _runCount = 0;
  int _runLevel = 0;
  List<String> _achieveList = [
    "출발의 첫 발걸음",
    "꾸준한 러너",
    "달리기 중독자",
    "슈퍼러너",
    "러닝의 대가",
  ];
  List<String> _achCondList = [
    "1",
    "10",
    "20",
    "50",
    "100",
  ];

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
      } catch (NullPointException) {}
    }
  }
  _getRunCount() async{
    await _getMyData();
    _runCount = await FirebaseService(
        uid: _uid,)
        .getRunCount(); //그룹 삭제
    if(_runCount>100){
      _runLevel = 5;
    }
    else if(_runCount>50){
      _runLevel = 4;
    }
    else if(_runCount>20){
      _runLevel = 3;
    }
    else if(_runCount>10){
      _runLevel = 2;
    }
    else if(_runCount>0){
      _runLevel = 1;
    }
    setState(() {

    });
  }
  _showTrophy(int idx){
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
                    child: Text(
                      _achieveList[idx],
                      style: TextStyle(
                          fontFamily: "SCDream",
                          color: Color.fromARGB(255, 34, 40, 49), //black
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: 200,
                    height: 300,
                    color: Colors.grey,
                    child: Text("IMG"),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "달리기 ${_runCount} / ${_achCondList[idx]}",
                          style: TextStyle(
                              fontFamily: "SCDream",
                              color: Color.fromARGB(255, 34, 40, 49), //black
                              fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getRunCount();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 앱 상단 바
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 238, 238, 238)), //white
        title: const Text(
          "업적",
          style: TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 238, 238, 238), //white
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 0, 173, 181), //teal
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(255, 238, 238, 238),
      body: Column(
        children: [
          SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
                itemCount: 5,
                itemBuilder: (BuildContext ctx, int idx) {
                  return GestureDetector(
                    onTap: (){
                      _showTrophy(idx);
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (idx<_runLevel)
                            ?Color.fromARGB(255, 0, 173, 181)
                            :Colors.grey, //teal
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 100,
                      child: Center(
                          child: Text(_achieveList[idx],
                            style: TextStyle(
                              fontFamily: "SCDream",
                              color: Color.fromARGB(255, 34, 40, 49), //black
                              fontSize: 20,
                            ),
                          )
                      ),
                    ),
                  );
                }
            ),
          ),

        ],
      )

    );
  }
}
