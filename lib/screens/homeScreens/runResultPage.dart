import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../analysisScreens/dataFormat.dart';
import '../homeScreens/RunningSetting.dart';

class RunResultPage extends StatefulWidget {
  final List<LatLng> pathMoved; // 이동한 경로
  final List<dynamic> snapshots;
  final int startTime; // 운동을 시작한 시점
  final int passedTime; // 운동 시작 후 흐른 시간
  final double distanceMoved; // 총 움직인 거리
  final int averagePace;
  final List<dynamic> pace;
  final bool goalCompleted;

  const RunResultPage({
    super.key,
    required this.pathMoved,
    required this.snapshots,
    required this.startTime,
    required this.passedTime,
    required this.distanceMoved,
    required this.averagePace,
    required this. pace,
    required this.goalCompleted,
  });

  @override
  State<RunResultPage> createState() => _RunResultPageState();
}

class _RunResultPageState extends State<RunResultPage> {
  final currentUser = FirebaseAuth.instance;
  late final String currentUserName;

  // user 컬렉션 참조
  final CollectionReference _userReference = FirebaseFirestore.instance.collection("users");

  late final LatLng center;
  late final int deltaTime;

  void _saveLog() {
    var data = {
      "start_time": DateTime.fromMillisecondsSinceEpoch(widget.startTime),
      "running_time": TimeFormatting.timeWriteFormatting(timeInSecond: widget.passedTime),
      "average_pace": TimeFormatting.timeWriteFormatting(
          timeInSecond : widget.averagePace,
      ),
      "total_distance": widget.distanceMoved,
      "snapshots": widget.snapshots,
      "pace" : widget.pace,
      "path": null,
    };
    _userReference
        .doc(currentUser.currentUser!.uid)
        .collection("log")
        .add(data)
        .then((doc) {
      debugPrint("$doc");
    });
  }

  bool _isLoading = false;  // 기록 저장 버튼 클릭 시 true로 변경
  Future<void> _saveLogWithPath() async{
    var data = {
      "start_time": DateTime.fromMillisecondsSinceEpoch(widget.startTime),
      "running_time": TimeFormatting.timeWriteFormatting(timeInSecond: widget.passedTime),
      "average_pace": TimeFormatting.timeWriteFormatting(
          timeInSecond : widget.averagePace,
      ),
      "total_distance": widget.distanceMoved,
      "snapshots": widget.snapshots,
      "pace" : widget.pace,
      "path": (widget.pathMoved.length > 300) ?
      LatLngFormatting.fromLatLngCompact(widget.pathMoved, 100) :
      LatLngFormatting.fromLatLng(widget.pathMoved),
    };
    await _userReference
        .doc(currentUser.currentUser!.uid)
        .collection("log")
        .add(data);
  }

  @override
  void initState() {
    super.initState();
    center = widget.pathMoved[widget.pathMoved.length ~/ 2];
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
        body: ListView(children: <Widget>[
          const SizedBox(height: 5),
          Text(
            DateFormatting.dateFormatting(DateTime.fromMillisecondsSinceEpoch(widget.startTime)),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 34, 40, 49), //black
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                border: Border.all(
              color: const Color.fromARGB(255, 0, 173, 181),
              width: 4.0,
            )),
            width: double.infinity,
            height: 400,
            alignment: Alignment.centerLeft,
            child: FlutterMap(
              options: MapOptions(
                center: center,
                minZoom: 13,
                zoom: 15,
                maxBounds: LatLngBounds(LatLng(30, 120), LatLng(40, 140)),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylineCulling: true,
                  polylines: [
                    Polyline(
                      points: widget.pathMoved,
                      color: const Color.fromARGB(255, 0, 173, 181),
                      borderColor: const Color.fromARGB(255, 0, 173, 181),
                      strokeWidth: 5,
                      borderStrokeWidth: 5,
                      isDotted: true,
                      // 속력에 따라 색깔 gradientColors 를 조정가능
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "달린 거리 : ${(widget.distanceMoved / unit1000Int).toStringAsFixed(2)} km",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 34, 40, 49), //black
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "운동한 시간 : ${TimeFormatting.timeWriteFormatting(timeInSecond: widget.passedTime)}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 34, 40, 49), //black
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "평균 페이스 : ${TimeFormatting.timeWriteFormatting(
                timeInSecond : widget.averagePace.round()
            )}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 34, 40, 49), //black
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          if(!_isLoading)
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true; // 비대기 작업 완료 후 대기 상태 해제
                });
                await _saveLogWithPath();
                Navigator.popAndPushNamed(context, "/toNavigationBarPage");
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 173, 181),
              ),
              child: const Text(
                '경로도 함께 저장하기',
                style: TextStyle(
                    fontFamily: "SCDream",
                    color: Color.fromARGB(255, 238, 238, 238), //white
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          if(_isLoading)
            const CircularProgressIndicator(),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              _saveLog();
              Navigator.popAndPushNamed(context, "/toNavigationBarPage");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 173, 181),
            ),
            child: const Text(
              '기록 저장하기',
              style: TextStyle(
                  fontFamily: "SCDream",
                  color: Color.fromARGB(255, 238, 238, 238), //white
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, "/toNavigationBarPage");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
            ),
            child: const Text(
              '기록 삭제하기',
              style: TextStyle(
                  fontFamily: "SCDream",
                  color: Color.fromARGB(255, 238, 238, 238), //white
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          )
        ]));
  }
}
