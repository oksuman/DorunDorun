import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dataFormat.dart';

class DetailPage extends StatefulWidget {
  final List<dynamic>? pathMoved;
  final List<dynamic> pace;
  final String startTime;
  final String runningTime;
  final String averagePace;
  final String distanceMoved;

  // TODO : 임시방편 주먹구구식 코드 재개발
  // TODO : snapshots 추가

  const DetailPage({
    super.key,
    this.pathMoved,
    required this.pace,
    required this.startTime,
    required this.runningTime,
    required this.averagePace,
    required this.distanceMoved,
  });

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
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 238, 238, 238)),
          //white
          title: const Text(
            "상세",
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
        body: ListView(padding: const EdgeInsets.all(8),
          children: <Widget>[
            const SizedBox(height: 5),
            Text(
              widget.startTime,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 34, 40, 49), //black
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            if (widget.pathMoved != null)
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border.all(
                  color: Colors.greenAccent,
                  width: 8.0,
                )),
                height: 400,
                alignment: Alignment.centerLeft,
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLngFormatting.toLatLng(
                        widget.pathMoved!)[widget.pathMoved!.length ~/ 2],
                    minZoom: 13,
                    zoom: 15,
                    maxBounds: LatLngBounds(LatLng(30, 120), LatLng(40, 140)),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    PolylineLayer(
                      polylineCulling: true,
                      polylines: [
                        Polyline(
                          points: LatLngFormatting.toLatLng(widget.pathMoved!),
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
              "달린 거리 : ${widget.distanceMoved} km",
              textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "SCDream",
                  color: Color.fromARGB(255, 34, 40, 49), //black
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
            ),
            const SizedBox(height: 10),
            Text(
              "운동한 시간 : ${widget.runningTime}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 34, 40, 49), //black
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "평균 페이스 : ${widget.averagePace}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 34, 40, 49), //black
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: const Text("km 별 시간대 구현 예정"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 173, 181),
              ),
              child: const Text(
                '기록과 함께 달리기',
                style: TextStyle(
                    fontFamily: "SCDream",
                    color: Color.fromARGB(255, 238, 238, 238), //white
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
        ]));
  }
}
