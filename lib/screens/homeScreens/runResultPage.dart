import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class RunResultPage extends StatefulWidget {
  final List<LatLng> runResult;
  const RunResultPage({super.key, required this.runResult});

  @override
  State<RunResultPage> createState() => _RunResultPageState();
}

class _RunResultPageState extends State<RunResultPage> {
  late final LatLng center;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    center = widget.runResult[0];
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
                height: 500,
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
                          points: widget.runResult,
                          color: Colors.yellow,
                          borderColor: Colors.yellow,
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
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: (){},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                ),
                child : const Text(
                  '경로도 함께 기록',
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