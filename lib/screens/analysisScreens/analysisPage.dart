import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  /*
    @param date : 년/월/일/시/분/초 정보가 있는 Datetime 자료형
    @return formatDate : 형식이 맞춰진 날짜 string

    datetime을 받아 보기 좋은 형식의 날짜 String으로 반환한다.
    형식은 추후에 변경 가능
   */
  String dateFormating(DateTime date){
    var formatDate = DateFormat('yy년, MMM dd, ' 'ha').format(date);
    return formatDate;
  }

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
        body: StreamBuilder(
            stream: _userReference
                .doc(currentUser.currentUser!.uid)
                .collection("log")
                .snapshots(),
            builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> logs
            /*
            logs : 내 이전 운동 기록들
              start_time : 운동을 시작한 시간
              average_pace : 평균 페이스
              total_distance : 총 달린 거리
              snapshots : gps 기록들 모음 List<Map<String, dynamic>>
            */
                ) {
              if(logs.hasData){
                return  ListView.separated(
                  padding: const EdgeInsets.all(15),
                  itemCount: logs.data!.docs.length,
                  itemBuilder: (BuildContext context, int index){
                    var itemCount = logs.data!.docs.length ?? 0;
                    var reverseIndex = itemCount - 1 - index;
                    return ListTile(
                      title: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.yellow[300],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                // 운동 시작 날짜 표시
                                Text(
                                  dateFormating(logs.data!.docs[reverseIndex]["start_time"].toDate()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 20
                                  ),
                                ),
                                // 평균 페이스 표시
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                    '페이스 ${logs.data!.docs[reverseIndex]["average_pace"]}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15
                                    )
                                ),
                                // 달린 거리 표시
                                Text(
                                    '달린 거리 ${(logs.data!.docs[reverseIndex]["total_distance"]/1000).toStringAsFixed(2)} km',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15
                                    )
                                ),
                              ],
                            ),
                          )
                      ),
                      // 해당 기록을 터치했을 경우, 자세한 기록 정보를 볼 수 있는 페이지로 이동
                      onTap: (){
                        Navigator.of(context).pushNamed('/toDetailPage');
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index)=> const Divider(),
                );
              }
              else{
                return const Center(child: CircularProgressIndicator());
              }
            }
        )
    );
  }
}

