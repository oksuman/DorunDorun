/*************************************
 * 러닝을 진행하면서 보게 되는 페이지 입니다.  *
 *************************************/

//여기에 추가하면 유니티, 기록, 음성 부분 들어가면 될 듯
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'runResultPage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'RunningSetting.dart';
import 'package:wakelock/wakelock.dart';

class RunningPage extends StatefulWidget {
  const RunningPage({Key? key}) : super(key: key);
  @override
  State<RunningPage> createState() => _RunningPageState();
}

/*
  혼자 뛰는 경우의 RunningPageState 입니다.
*/
class _RunningPageState extends State<RunningPage> {
  final currentUser = FirebaseAuth.instance;
  // user 컬렉션 참조
  final CollectionReference _userReference =
  FirebaseFirestore.instance.collection("users");
  // 이번 러닝 기록을 저장할 document의 레퍼런스
  late final DocumentReference _logReference;

  Location location = Location();
  Distance distance = const Distance();

  late final int defaultTime; // 러닝을 시작한 시점(timestamp), 이 변수를 기준으로 흐른 시간을 고려
  double distanceMoved = 0; // 이번 러닝에서 달린 누적 거리
  int timesUnit = 0; // 단위거리를 주파한 횟수. 즉, distanceMoved % unit. unit은 측정 단위로, 추후 변경

  bool isMocked = false; // 멈춰 있는지, true 라면 멈춰있음
  List<LatLng> pathMoved = List<LatLng>.empty(growable: true); // 이번 러닝에서 이동한 경로. (위도,경도) 쌍의 리스트
  /*
    snapshots : 순간 기록 들을 저장
      accumulated_distance : 현 시점까지 이동한 누적거리
      delta_time : 운동을 시작하고 지난 시간 (milliseconds)
      velocity : 현 시점의 순간 속도
   */
  List<Map<String, Object>> snapshots = List<Map<String, Object>>.empty(growable: true);

  //// Timer 관련 ////
  Timer? _runningTimer;
  int _runningSeconds = 0; // 러닝이 시작하고 흐른 시간(seconds)
  void _startTimer(){
    _runningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _runningSeconds++;
      });
    });
  }
  void _stopTimer(){
    _runningTimer?.cancel();
  }
    String _timerFormating(int seconds){
    final timerView = DateFormat("HH: mm: ss"); // timer가 보일 형식, 형식은 추후 변경 가능
    var dt = DateTime.fromMillisecondsSinceEpoch((seconds+54000)*1000);
    return timerView.format(dt);
  }
  ///////////////////

  //// Button 관련 ////
  IconData _runningControlBtn = Icons.pause; // 달리기 시작, 일시정지 버튼
  Color btnColor = Colors.blueGrey;
  bool _isRunning = true; // 일시정지 중이라면 false
  void btnClicked(){
    _isRunning = !_isRunning;
    if(_isRunning ){
      _runningControlBtn = Icons.pause;
      btnColor = Colors.blueGrey;
      _startTimer();
    }
    else{
      _runningControlBtn = Icons.play_arrow;
      btnColor = Colors.amber;
      _stopTimer();
    }
  }
  ////////////////////

  //// TTS 관련 ////
  FlutterTts tts = FlutterTts();

  void setTts() async{
    await tts.setLanguage('ko-KR');
    await tts.setVolume(1.0);
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);
    Map<String, String> voice = {
      "name": "ko-kr-x-koc-local",
      "locale": "ko-KR",
      "quality": "400",
    };
    await tts.setVoice(voice);
  }

  void ttsGuide({
      required int times,
      required String unit,
      required String pace,
  })async{
    await tts.speak("${times.toString()} $unit 지점을 통과하였습니다. 현재 페이스는 $pace 입니다.");
  }

  /////////////////

  @override
  void initState() {
    super.initState();
    setTts();
    _startTimer();
    Wakelock.enable();
  }

  @override
  Widget build(BuildContext context) {
    var initialLocation = ModalRoute.of(context)!.settings.arguments as LocationData;

    if(pathMoved.isEmpty){
      defaultTime = initialLocation.time!.toInt();
      snapshots.add({
        "accumulated_distance": 0,
        "delta_time" : 0,
        "velocity" : 0,
      });
      // 새 운동 기록 초기화
      var initData = {
        "average_pace" : "아직띠", //null, 임시로 0
        "start_time" : DateTime.fromMillisecondsSinceEpoch(defaultTime),
        "total_distance" : 0, //null, 임시로 0
        "snapshots" : snapshots,
      };
      // 새 운동 기록 생성
      _userReference.doc(currentUser.currentUser!.uid)
          .collection("log").add(initData).then(
              (docid)=>_logReference = docid
      );
      // 시작 위치를 이동 경로에 추가
      pathMoved.add(LatLng(
          initialLocation.latitude!, initialLocation.longitude!));
    }

    return Scaffold(
      appBar: AppBar(
        // 앱 상단 바
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "달려봅세",
          style: TextStyle(
              color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /*
             Timer : 운동 시작 후 경과된 시간을 표시하기 위한 용도로
             gps timestamp, firebase 서버시간과는 독립적인 시간
             */
            Container(
              padding: const EdgeInsets.all(8.0),
              child : Text(
                _timerFormating(_runningSeconds),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 30,
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            /*
            움직인 거리, 평균 페이스 표시 화면
            현재는 평균 페이스 대신 순간 속도를 보인다.
            TODO : 평균 페이스 계산 구현
             */
            StreamBuilder<LocationData>(
              initialData: initialLocation,
              stream: location.onLocationChanged,
              builder: (context, stream) {
                /*
                LocationData
                latitude : 위도
                longitude : 경도
                time : timestamp, milliseconds
                accuracy : 정확도
                velocity : 속도, 기본 단위는 m/s
                */
                final changedLocation = stream.data;  // 새로 받아온 gps 정보

                // 가장 마지막에 기록된 위치 정보
                final previousLatitude = pathMoved.last.latitude;
                final previousLongitude = pathMoved.last.longitude;

                // 받아온 gps 정보로 변수 초기화. 받아온 값이 null이라면 이전 값을 넣거나 0으로 초기화
                final currentLatitude =
                    changedLocation?.latitude ?? previousLatitude;
                final currentLongitude =
                    changedLocation?.longitude ?? previousLongitude;
                // 임시적으로 존재하는 변수들
                final currentSpeed = changedLocation?.speed ?? 0;
                final currentTime = changedLocation?.time ?? 0;
                // 가장 마지막에 기록된 위치 정보와 새로운 정보를 비교하여 다르다면 갱신
                // 정확도값이 20 이상인 경우에만 위치변경으로 인정
                if (currentLatitude != previousLatitude &&
                    currentLongitude != previousLongitude) {

                  final cur = LatLng(currentLatitude, currentLongitude);
                  final distanceDelta = distance.as(const LengthUnit(1.0), cur, pathMoved.last);
                  // 움직인 거리 업데이트
                  distanceMoved += distanceDelta;
                  //// 누적 거리가 특정 조건에 달하면 TTS 안내를 실시한다. 현재는 100m 마다 음성 읽기, 추후 변경 가능 ////
                  if(distanceMoved.toInt() ~/ unit100Int > timesUnit){
                    timesUnit++;
                    ttsGuide(
                        times: timesUnit,
                        unit: unit100Meter,
                        pace: "아직띠"
                    );
                  }
                  // 지난 시간 업데이트
                  var deltaTime = currentTime.toInt() - defaultTime;
                  // 지나온 경로에 새로운 포인트 추가
                  pathMoved.add(cur);
                  // 기록 저장
                  snapshots.add(
                   {
                     "accumulated_distance": distanceMoved,
                     "delta_time" : deltaTime,
                     "velocity" : currentSpeed,
                    }
                  );
                  _logReference.update({"snapshots" : snapshots});
                  _logReference.update({"accumulated_distance" : distanceMoved});

                  debugPrint("accuracy : ${changedLocation?.accuracy}");
                  debugPrint("distanceDelta : $distanceDelta");
                  debugPrint("new : $cur");
                  debugPrint("path : $pathMoved");

                  }
                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "움직인 거리 : ${distanceMoved.toStringAsFixed(2)} meter",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15
                          ),
                        ),
                        Text(
                          "순간 속도 : ${currentSpeed.toStringAsFixed(2)} m/s",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            /*
            gps 데이터를 stream으로 받아와 화면을 주기적으로 update
            현재는 임시로 화면을 구축해둔 상태
            TODO : unity 화면으로 gps 데이터를 표현
            */
            const SizedBox(
              height: 25,
            ),
            Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: 500,
              child: const Text("달리기 창"),
            ),
            const SizedBox(
              height: 25,
            ),
            // 운동 시작, 운동 종료 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton(
                  onPressed: () => setState(() {
                    btnClicked();
                  }),
                  heroTag: 'pause/restart running',
                  backgroundColor: btnColor,
                  child: Icon(_runningControlBtn),
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            RunResultPage(runResult: pathMoved)));
                  },
                  heroTag: 'strop running',
                  backgroundColor: Colors.blueGrey,
                  child: const Text("Exit"),
                ),
              ],
            )
          ],
        ),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    _runningTimer?.cancel();
  }
}
