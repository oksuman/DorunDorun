import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import '../homeScreens/runResultPage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wakelock/wakelock.dart';
import '../homeScreens/RunningSetting.dart';
import '../analysisScreens/dataFormat.dart';
import '../../models/group.dart';

class GhostRunPage extends StatefulWidget {
  final List<dynamic> pace;
  final List<dynamic> snapshots;
  final String runningTime;
  final String averagePace;
  final String distanceMoved;
  final LocationData initialLocation;

  const GhostRunPage({
    super.key,
    required this.pace,
    required this.snapshots,
    required this.runningTime,
    required this.averagePace,
    required this.distanceMoved,
    required this.initialLocation,
  });

  @override
  State<GhostRunPage> createState() => _GhostRunPageState();
}

class _GhostRunPageState extends State<GhostRunPage> {
  late final LocationData initialLocation;
  late final int defaultTime; // 러닝을 시작한 시점(timestamp), 이 변수를 기준으로 흐른 시간을 고려
  double distanceMoved = 0; // 이번 러닝에서 달린 누적 거리
  int timesUnit = 0; // 단위거리를 주파한 횟수. 즉, distanceMoved % unit. unit 은 측정 단위로, 추후 변경
  int deltaTime = 0;
  int averagePace = 0; // sec-1km 의미 : 단위거리(1km)를 주파하는데 걸릴 것으로 예상되는 시간(sec)

  List<Map<String, Object>> snapshots = List<Map<String, Object>>.empty(growable: true);
  List<Map<int, Object>> pace = List<Map<int, Object>>.empty(growable: true); // 단위 거리를 지난 시간을 기록하자.

  Location location = Location();
  Distance distance = const Distance();


  //// Timer 관련 ////////////////////////////////////////////////////////////////
  Timer? _runningTimer;
  int _runningSeconds = 0; // 러닝이 시작하고 흐른 시간(seconds)
  void _startTimer() {
    _runningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _runningSeconds++;
      });
    });
  }

  void _stopTimer() {
    _runningTimer?.cancel();
  }

  String _timerFormatting(int seconds) {
    final timerView = DateFormat("HH: mm: ss"); // timer 가 보일 형식, 형식은 추후 변경 가능
    var dt = DateTime.fromMillisecondsSinceEpoch((seconds + 54000) * 1000);
    return timerView.format(dt);
  }
  //////////////////////////////////////////////////////////////////////////////////////

  //// Button 관련 /////////////////////////////////////////////////////////////////////
  IconData _runningControlBtn = Icons.pause; // 달리기 시작, 일시정지 버튼
  Color btnColor = Colors.blueGrey;
  bool _isRunning = true; // 일시정지 중이라면 false : 사용자가 타이머 버튼을 조작함으로서 변경됨
  bool _isMocked = false; // 일시정지 중이라면 true : GPS 데이터가 오랜기간 정지해있는지 여부
  void btnClicked() {
    _isRunning = !_isRunning;
    if (_isRunning) {
      _runningControlBtn = Icons.pause;
      btnColor = Colors.blueGrey;
      _startTimer();
    } else {
      _runningControlBtn = Icons.play_arrow;
      btnColor = Colors.amber;
      _stopTimer();
    }
  }
  ///////////////////////////////////////////////////////////////////////////////////

  //// TTS 관련 //////////////////////////////////////////////////////////////////////
  FlutterTts tts = FlutterTts();

  void setTts() async {
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
  }) async {
    await tts
        .speak("${times.toString()} $unit 지점을 통과하였습니다. 현재 페이스는 $pace 입니다.");
  }
  //////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    // GPS Tracking 설정
    /*
    ACCURACY : 정확도 설정
    INTERVAL : GPS 정보를 받아오는 주기. 단위는 MILLISECONDS
    DISTANCE FILTER : 몇 METER 단위로 정보를 받아올 것인지.
     */
    location.changeSettings(
      accuracy: LocationAccuracy.navigation,
      interval: 5000,
      distanceFilter: 10,
    );
    // Background Gps Tracking 활성화
    location.enableBackgroundMode(enable: true);
    // Background Gps Tracking 을 어떻게 표시할 것인지
    location.changeNotificationOptions(
      //TODO Background 작동시 보여주는 방식 설정
      /*
        https://docs.page/Lyokone/flutterlocation/features/notification
       */
    );
    setTts();
    _startTimer();

    initialLocation = widget.initialLocation;
    defaultTime = initialLocation.time!.toInt();
    var initData = {
      "runner": 'widget.userName',
      "accumulated_distance": 0,
      "delta_time": deltaTime,
      "velocity": 0,
    };
    // 초기 데이터를 업로드하고, 동시에 snapshots 에 저장
    snapshots.add(initData);
    // 시작 위치를 이동 경로에 추가

    Wakelock.enable();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
    );
  }
}
