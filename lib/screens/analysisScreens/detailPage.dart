import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dataFormat.dart';

class DetailPage extends StatefulWidget {
  final List<dynamic>? pathMoved;
  final String startTime;
  final String runningTime;
  final String averagePace;
  final String distanceMoved;
  // TODO : 임시방편 주먹구구식 코드 재개발
  // TODO : snapshots 추가

  const DetailPage({
    super.key,
    this.pathMoved,
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
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            "운동 결과",
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
            if(widget.pathMoved != null)
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
                    center: LatLngFormating.toLatLng(widget.pathMoved!)[widget.pathMoved!.length~/2],
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
                          points: LatLngFormating.toLatLng(widget.pathMoved!),
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
                "움직인 거리 : ${widget.distanceMoved} km",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 15
                ),
              ),
              Text(
                "운동 시작 시간 : ${widget.startTime}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 15
                ),
              ),
              Text(
                "운동한 시간 : ${widget.runningTime}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 15
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: (){},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                ),
                child : const Text(
                  '기록과 함께 달리기',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15
                  ),
                ),
              ),
            ]
        )
    );
  }
}
