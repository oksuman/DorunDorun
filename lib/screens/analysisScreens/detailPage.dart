import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dataFormat.dart';
import 'package:location/location.dart';
import 'ghostRunPage.dart';
import '../homeScreens/RunningSetting.dart';

class DetailPage extends StatefulWidget {
  final List<dynamic>? pathMoved;
  final List<dynamic> pace;
  final List<dynamic> snapshots;
  final String startTime;
  final String runningTime;
  final String averagePace;
  final String distanceMoved;
  final String docID;

  // TODO : 임시방편 주먹구구식 코드 재개발
  // TODO : snapshots 추가

  const DetailPage({
    super.key,
    this.pathMoved,
    required this.pace,
    required this.snapshots,
    required this.startTime,
    required this.runningTime,
    required this.averagePace,
    required this.distanceMoved,
    required this.docID,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Location location = Location();

  final currentUser = FirebaseAuth.instance;
  // user 컬렉션 참조
  final CollectionReference _userReference =
  FirebaseFirestore.instance.collection("users");

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

        body: ListView(
                padding: const EdgeInsets.all(8),
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
                  const SizedBox(height: 50),
                  StreamBuilder(
                      stream: _userReference
                          .doc(currentUser.currentUser!.uid)
                          .collection("log")
                          .doc(widget.docID)
                          .collection("sub_log")
                          .orderBy('start_time', descending: true)
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> subLogs){
                        if(subLogs.hasData){
                          return Expanded(
                              child:  ListView.separated(
                                  physics: const ScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: subLogs.data!.docs.length,
                                  itemBuilder: (BuildContext context, int index){
                                    return Container(
                                      height: 25,
                                      width:  double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                      ),
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          Text(
                                              subLogs.data!.docs[index]['runner'],
                                              style: const TextStyle(
                                                  fontFamily: "SCDream",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 20
                                              )
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Text(
                                              subLogs.data!.docs[index]['average_pace'],
                                              style: const TextStyle(
                                                  fontFamily: "SCDream",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 20,
                                              )
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Text(
                                              "${(subLogs.data!.docs[index]['total_distance']  / unit1000Int).toStringAsFixed(2) } km",
                                              style: const TextStyle(
                                                  fontFamily: "SCDream",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 20
                                              )
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                separatorBuilder: (BuildContext context, int index) =>
                                const Divider(),
                              )
                          );
                        }
                        else{
                          debugPrint("rlatmdgn");
                          return const Center(child: CircularProgressIndicator());
                        }
                      }
                  ),
                  const SizedBox(height: 50),
                  Container(
                    color: Colors.grey,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: const Text("km 별 시간대 구현 예정"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await location.getLocation().then((res) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => GhostRunPage(
                              logPace : widget.pace,
                              snapshots: widget.snapshots,
                              averagePace: widget.averagePace,
                              distanceMoved:  widget.distanceMoved,
                              docID: widget.docID,
                              initialLocation: res,
                            )));
                      });

                    },
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
                ]),
       );
  }
}
