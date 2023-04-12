import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../analysisScreens/dataFormat.dart';

class RunResultPage extends StatefulWidget {

  final List<LatLng> pathMoved; // 이동한 경로
  final List<Map<String, Object>> snapshots;
  final int startTime; // 운동을 시작한 시점
  final int passedTime; // 운동 시작 후 흐른 시간
  final double distanceMoved; // 총 움직인 거리

  const RunResultPage({
    super.key,
    required this.pathMoved,
    required this.snapshots,
    required this.startTime,
    required this.passedTime,
    required this.distanceMoved,
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

  void _saveLog(){
    var data = {
      "start_time" : DateTime.fromMillisecondsSinceEpoch(widget.startTime),
      "running_time" : TimeFormating.timeFormating(timeInSecond: widget.passedTime),
      "average_pace" : "구현 예정",
      "total_distance" : widget.distanceMoved,
      "snapshots" : widget.snapshots,
      "path" : null,
    };
    _userReference.doc(currentUser.currentUser!.uid)
        .collection("log").add(data).then(
            (doc){
          debugPrint("$doc");
        }
    );;
  }
  void _saveLogWithPath(){
    var data = {
      "start_time" : DateTime.fromMillisecondsSinceEpoch(widget.startTime),
      "running_time" : TimeFormating.timeFormating(timeInSecond: widget.passedTime),
      "average_pace" : "구현 예정",
      "total_distance" : widget.distanceMoved,
      "snapshots" : widget.snapshots,
      "path" : LatLngFormating.fromLatLng(widget.pathMoved),
    };
    _userReference.doc(currentUser.currentUser!.uid)
      .collection("log").add(data).then(
        (doc){
          debugPrint("$doc");
        }
      );
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
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            "결과도르",
            style: TextStyle(
                color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold
            ),
          ),
          backgroundColor: Colors.yellow,
          centerTitle: true,
        ),
        body: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.greenAccent,
                    width: 8.0,
                  )
                ),
                height: 400,
                alignment: Alignment.centerLeft,
                child: FlutterMap(
                  options: MapOptions(
                    center: center,
                    minZoom: 13,
                    zoom: 15,
                    maxBounds: LatLngBounds(
                        LatLng(30, 120),
                        LatLng(40, 140)
                    ),
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
                          color: Colors.greenAccent,
                          borderColor: Colors.greenAccent,
                          strokeWidth: 8,
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
                "움직인 거리 : ${widget.distanceMoved.toStringAsFixed(2)} meter",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 15
                ),
              ),
              Text(
                "운동 시작 시간 : ${DateFormating.dateFormating(
                    DateTime.fromMillisecondsSinceEpoch(widget.startTime))}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 15
                ),
              ),
              Text(
                "운동한 시간 : ${TimeFormating.timeFormating(timeInSecond: widget.passedTime)}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 15
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: (){
                  _saveLogWithPath();
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/toNavigationBarPage");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                ),
                child : const Text(
                  '경로도 함께 저장하기',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 15
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: (){
                  _saveLog();
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/toNavigationBarPage");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                ),
                child : const Text(
                  '기록 저장하기',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/toNavigationBarPage");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                child : const Text(
                  '기록 삭제하기',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15
                  ),
                ),
              )
            ]
        )
    );
  }
}
