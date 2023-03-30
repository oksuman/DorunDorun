import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

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
          title: const Text("Do run! Do run!")
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Container(
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
        ]
      )
    );
  }
}