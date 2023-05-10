import 'package:dorun_dorun/Screens/analysisScreens/detailPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dataFormat.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final currentUser = FirebaseAuth.instance;

  // user 컬렉션 참조
  final CollectionReference _userReference =
      FirebaseFirestore.instance.collection("users");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // 앱 상단 바
          elevation: 0,
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 238, 238, 238)),
          //white
          title: const Text(
            "결과",
            style: TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 238, 238, 238), //white
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 173, 181),
          //teal
          centerTitle: true,
        ),
        body: StreamBuilder(
            stream: _userReference
                .doc(currentUser.currentUser!.uid)
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
                  padding: const EdgeInsets.all(15),
                  itemCount: logs.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Container(
                          height: 125,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 173, 181),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                // 운동 시작 날짜 표시
                                Text(
                                  DateFormatting.dateFormatting(logs
                                      .data!.docs[index]["start_time"]
                                      .toDate()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: "SCDream",
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 238, 238, 238),
                                      fontSize: 20),
                                ),
                                // 평균 페이스 표시
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                    '운동 시간 ${logs.data!.docs[index]["running_time"]}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "SCDream",
                                        color: Color.fromARGB(255, 34, 40, 49),
                                        fontSize: 15)),
                                Text(
                                    '페이스 ${logs.data!.docs[index]["average_pace"]}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "SCDream",
                                        color: Color.fromARGB(255, 34, 40, 49),
                                        fontSize: 15)),
                                // 달린 거리 표시
                                Text(
                                    '달린 거리 ${(logs.data!.docs[index]["total_distance"] / 1000).toStringAsFixed(2)} km',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "SCDream",
                                        color: Color.fromARGB(255, 34, 40, 49),
                                        fontSize: 15)),
                              ],
                            ),
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
            }));
  }
}
