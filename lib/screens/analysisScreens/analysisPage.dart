import 'package:dorun_dorun/Screens/analysisScreens/detailPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dataFormat.dart';
import '../../utilities/storageService.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String? _thisUserId = ""; //로그 확인할 아이디
  String _uid = "";
  String _uname = "";
  String _ugroup = "";
  final currentUser = FirebaseAuth.instance;

  // user 컬렉션 참조
  final CollectionReference _userReference =
      FirebaseFirestore.instance.collection("users");

  _getMyData() async {
    await StorageService().getUserID().then((value) {
      setState(() {
        _uid = value!;
      });
    });
    await StorageService().getUserName().then((value) {
      setState(() {
        _uname = value!;
      });
    });
    await StorageService().getUserGroup().then((value) {
      setState(() {
        _ugroup = value!;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMyData();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    _thisUserId = ModalRoute.of(context)?.settings.arguments as String?; //인자 전 페이지에서 받아오기
    //print(_uid);
    return Scaffold(
        appBar: AppBar(
          // 앱 상단 바
          automaticallyImplyLeading: false,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color.fromARGB(255, 34, 40, 49)),
          title: const Text(
            "결과",
            style: TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 34, 40, 49),
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(255, 238, 238, 238), //white
          centerTitle: true,
        ),
        backgroundColor: Color.fromARGB(255, 238, 238, 238),
        body: (_uid!="")?StreamBuilder(
            stream: _userReference
                .doc((_thisUserId!=null)?_thisUserId:_uid) //전달받은 id or current user id
                .collection("log")
                .orderBy('start_time', descending: true)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> logs
              /*
                logs : 내 이전 운동 기록들

                start_time : 운동을 시작한 시간
                average_pace : 평균 페이스
                total_distance : 총 달린 거리
                snapshots : gps 기록들 모음 List<Map<String, dynamic>>
                path? : 경로 nullable!!!!! 확인 요망 !!!!!
              */
                ) {
              if (logs.hasData) {
                return ListView.separated(
                  itemCount: logs.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 운동 시작 날짜 표시
                              Text(
                                DateFormatting.dateFormatting(logs
                                    .data!.docs[index]["start_time"]
                                    .toDate()),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontFamily: "SCDream",
                                    fontWeight: FontWeight.w900,
                                    color: Color.fromARGB(255, 0, 173, 181),
                                    fontSize: 20),
                              ),
                              // 평균 페이스 표시
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  '운동 시간 ${logs.data!.docs[index]["running_time"]}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "SCDream",
                                      color: Color.fromARGB(255, 34, 40, 49),
                                      fontSize: 14)),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                  '페이스 ${logs.data!.docs[index]["average_pace"]}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "SCDream",
                                      color: Color.fromARGB(255, 34, 40, 49),
                                      fontSize: 14)),
                              // 달린 거리 표시
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                  '달린 거리 ${(logs.data!.docs[index]["total_distance"] / 1000).toStringAsFixed(2)} km',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "SCDream",
                                      color: Color.fromARGB(255, 34, 40, 49),
                                      fontSize: 14)),
                            ],
                          )),
                      // 해당 기록을 터치했을 경우, 자세한 기록 정보를 볼 수 있는 페이지로 이동
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DetailPage(
                                  pathMoved: logs.data!.docs[index]['path'],
                                  pace: logs.data!.docs[index]['pace'],
                                  snapshots : logs.data!.docs[index]['snapshots'],
                                  startTime: DateFormatting.dateFormatting(logs
                                      .data!.docs[index]["start_time"]
                                      .toDate()),
                                  runningTime: logs.data!.docs[index]
                                      ["running_time"],
                                  averagePace: logs.data!.docs[index]
                                      ["average_pace"],
                                  distanceMoved: (logs.data!.docs[index]
                                              ["total_distance"] / 1000)
                                      .toStringAsFixed(2),
                                  docID : logs.data!.docs[index].reference.id,
                                )));
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })
            : Center(child: CircularProgressIndicator())
    );
  }
}
