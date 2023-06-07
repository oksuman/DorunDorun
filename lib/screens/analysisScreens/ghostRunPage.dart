import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wakelock/wakelock.dart';
import '../homeScreens/RunningSetting.dart';
import '../analysisScreens/dataFormat.dart';
import '../../utilities/storageService.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GhostRunPage extends StatefulWidget {
  final List<dynamic> logPace;
  final List<dynamic> snapshots;
  final String averagePace;
  final String distanceMoved;
  final String docID;
  final LocationData initialLocation;

  const GhostRunPage({
    super.key,
    required this.logPace,
    required this.snapshots,
    required this.averagePace,
    required this.distanceMoved,
    required this.docID,
    required this.initialLocation,
  });

  @override
  State<GhostRunPage> createState() => _GhostRunPageState();
}

class _GhostRunPageState extends State<GhostRunPage> {

  late final LocationData initialLocation;
  late final int defaultTime; // 러닝을 시작한 시점(timestamp), 이 변수를 기준으로 흐른 시간을 고려
  num distanceMoved = 0; // 이번 러닝에서 달린 누적 거리
  int timesUnit = 0; // 단위거리를 주파한 횟수. 즉, distanceMoved % unit. unit 은 측정 단위로, 추후 변경
  int deltaTime = 0;
  int averagePace = 0; // sec-1km 의미 : 단위거리(1km)를 주파하는데 걸릴 것으로 예상되는 시간(sec)

  late double previousLatitude;
  late double previousLongitude;
  List<Map<int, Object>> pace = List<Map<int, Object>>.empty(growable: true); // 단위 거리를 지난 시간을 기록하자.

  Location location = Location();
  Distance distance = const Distance();

  //// 상대 LOG 관련 ////
  int logIndex = 0;
  late int logNum ; // snapshot 원소 수, 기록이 몇개인지
  int logTimesUnit = 0;
  late int logDeltaTime;
  late num logDistanceMoved;
  int logAveragePace = 0;
  bool logFinished = false;

  //// User 정보 관련 /////////////////////////////////////////////////////////////
  final currentUser = FirebaseAuth.instance;
  late final DocumentReference docRef;
  // user 컬렉션 참조
  final CollectionReference _userReference = FirebaseFirestore.instance.collection("users");
  late final String userName;
  getUserName() async {
    await StorageService().getUserName().then(
        (value) {
          userName = value!;
        }
    );
  }
  ///////////////////////////////////////////////////////////////////////////////

  //// 기록 남기기 관련 - 기존 기록에 꼬리표 //////////////////////////////////////////
  late Map<String, dynamic> _data;
  void _saveLog(Map<String, dynamic> data){
    _userReference
        .doc(currentUser.currentUser!.uid)
        .collection("log")
        .doc(widget.docID)
        .collection("sub_log")
        .add(data).then((value) => debugPrint("ADD $value"));
  }
  /*
    data 에 들어가야할 항목
    "runner" : String 누구의 기록인지
    "average_pace" : String 평균 페이스
    "total_distance" : number 총 달린 거리
    "start_time" : datetime 운동 시작 날짜 (년,월,일,시간..)

   */
  ///////////////////////////////////////////////////////////////////////////////


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

  void ttsGuideGhost1({
    required int times,
    required String unit,
    required String pace,
    required num distanceDiff,
  }) async {
    var guideVerse = (distanceDiff > 0) ? "앞에 있습니다" : "뒤에 있습니다";

    await tts
        .speak("${times.toString()} $unit 지점을 통과하였습니다. 현재 페이스는 $pace 입니다. 현재 상대는 ${distanceDiff.abs()} 미터 $guideVerse");
  }

  void ttsGuideGhost2({
    required int times,
    required String unit,
    required String pace,
  }) async {

    await tts
        .speak("상대가 ${times.toString()} $unit 지점을 통과하였습니다. 상대의 현재 페이스는 $pace 입니다.");
  }

  void ttsFinish() async{
    await tts
        .speak("상대방의 운동이 종료되었습니다.");
  }
  //////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    getUserName();
    // GPS Tracking 설정
    /*
    ACCURACY : 정확도 설정
    INTERVAL : GPS 정보를 받아오는 주기. 단위는 MILLISECONDS
    DISTANCE FILTER : 몇 METER 단위로 정보를 받아올 것인지.
     */
    location.changeSettings(
      accuracy: LocationAccuracy.navigation,
      interval: 3000,
      distanceFilter: 5,
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
    previousLatitude = initialLocation.latitude!;
    previousLongitude = initialLocation.longitude!;
    logNum = widget.snapshots.length;
    debugPrint("ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ");
    debugPrint("lognum : $logNum");
    debugPrint("log snapshots : ${widget.snapshots}");

    logDeltaTime = widget.snapshots[logIndex]['delta_time'];
    logDistanceMoved = widget.snapshots[logIndex]['accumulated_distance'];
    debugPrint(" widget 에서 :  ${widget.snapshots.length}");
    logIndex++;
    if(widget.snapshots.length == 1){
      logFinished = true;
    }
    Wakelock.enable();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  color: const Color.fromARGB(255, 0, 173, 181),
                ),
                /*
             Timer : 운동 시작 후 경과된 시간을 표시하기 위한 용도로
             gps timestamp, firebase 서버시간과는 독립적인 시간
             */
                Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 0, 173, 181),
                  child: Text(
                    _timerFormatting(_runningSeconds),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: "SCDream",
                        color: Color.fromARGB(255, 238, 238, 238), //white
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 20,
                  color: const Color.fromARGB(255, 0, 173, 181),
                ),
                const SizedBox(
                  height: 20,
                ),
                ////////////////////////////////////// 여기까지가 시계 ///////////////////////////////////////
                StreamBuilder<LocationData>(
                    initialData: initialLocation,
                    stream: location.onLocationChanged,
                    builder: (context, stream) {
                      debugPrint("ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡFㅡㅡㅡㅡㅡㅡㅡㅡㅡ");
                      debugPrint("$logIndex");
                      debugPrint("ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡFㅡㅡㅡㅡㅡㅡㅡㅡㅡ");
                      if(_isRunning && !_isMocked){
                        /*
                    LocationData
                    latitude : 위도
                    longitude : 경도
                    time : timestamp, milliseconds
                    accuracy : 정확도
                    velocity : 속도, 기본 단위는 m/s
                    */
                        final changedLocation = stream.data; // 새로 받아온 gps 정보

                        // 받아온 gps 정보로 변수 초기화. 받아온 값이 null 이라면 이전 값을 넣거나 0으로 초기화
                        final currentLatitude = changedLocation?.latitude ?? previousLatitude;
                        final currentLongitude = changedLocation?.longitude ?? previousLongitude;
                        _isMocked = changedLocation?.isMock ?? true;

                        // 임시적으로 존재하는 변수들
                        final currentSpeed = changedLocation?.speed ?? 0;
                        final currentTime = changedLocation?.time ?? 0;

                        // 가장 마지막에 기록된 위치 정보와 새로운 정보를 비교하여 두 값이 다르고 && 정확도 값이 5보다 작은 경우에만 갱신
                        /*
                      정확도 : 사용자가 해당 gps 데이터 근방 x미터(즉 반지름이 x인 원 안)에 있을 확률(신뢰도)가 y 퍼센트 이상이다.
                      에서 x값을 당당하는 것이 accuracy 이다.
                     */
                        debugPrint("여기까진 실행중임");
                        debugPrint("여기까진 실행중임 ${changedLocation?.accuracy}");
                        if ((currentLatitude != previousLatitude ||
                            currentLongitude != previousLongitude) &&
                            (changedLocation?.accuracy ?? 10) < 10) {
                          debugPrint("실행중임");
                          final cur = LatLng(currentLatitude, currentLongitude);
                          final distanceDelta = distance.as(LengthUnit.Meter, cur, LatLng(previousLatitude, previousLongitude));
                          // 움직인 거리 업데이트
                          distanceMoved += distanceDelta;
                          //// 누적 거리가 특정 조건에 달하면 TTS 안내를 실시한다. 현재는 1km 마다 음성 읽기, 추후 변경 가능 ////
                          if (distanceMoved.toInt() ~/ unit1000Int > timesUnit) {
                            timesUnit++;
                            ttsGuideGhost1(
                              times: timesUnit, unit: unit1Kilo,
                              pace: TimeFormatting.timeVoiceFormatting(
                                timeInSecond : averagePace,
                              ),
                              distanceDiff : logDistanceMoved - distanceMoved,
                            );
                            pace.add({
                              timesUnit : deltaTime
                            });
                          }
                          // 지난 시간 업데이트
                          deltaTime = (currentTime.toInt() - defaultTime) ~/ 1000; // 단위 : 초
                          // 평균 페이스 갱신
                          averagePace = ((unit1000Int * deltaTime)/distanceMoved).round();
                          previousLatitude = currentLatitude;
                          previousLongitude = currentLongitude;
                        }
                        //// LOG 와 관련된 작업
                        debugPrint("살아있나 $logFinished");
                        if(!logFinished){
                          debugPrint("deltaTime : $deltaTime");
                          debugPrint("log : ${widget.snapshots[logIndex]['delta_time']}");
                          if(_runningSeconds >= widget.snapshots[logIndex]['delta_time']){
                            logIndex++;
                            if(logIndex == logNum-1){
                              ttsFinish();
                              logFinished = true;
                            }
                            else{
                              logDeltaTime = widget.snapshots[logIndex]['delta_time'];
                              logDistanceMoved = widget.snapshots[logIndex]['accumulated_distance'];
                              debugPrint("ㅡㅡㅡㅡㅡ유령꺼");
                              debugPrint("시간 : $logDeltaTime");
                              debugPrint("거리 : $logDistanceMoved");
                              logAveragePace  = ((unit1000Int * logDeltaTime)/logDistanceMoved).round();
                              // 상대가 단위거리 주파했는지 확인
                              if (distanceMoved.toInt() ~/ unit1000Int > logTimesUnit) {
                                logTimesUnit++;
                                ttsGuideGhost2(
                                  times: logTimesUnit, unit: unit1Kilo,
                                  pace: TimeFormatting.timeVoiceFormatting(
                                    timeInSecond : logAveragePace,
                                  ),
                                );
                              }
                            }
                          }
                        }
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                /////////////////// 내가 현재 뛰고 있는 정보 /////////////////////
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // 현재 페이스
                                    Text(
                                      TimeFormatting.timeWriteFormatting(
                                        timeInSecond : averagePace,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: "SCDream",
                                        color: Color.fromARGB(255, 34, 40, 49), //black
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      // 현재 움직인 거리
                                      (distanceMoved/unit1000Int).toStringAsFixed(2),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: "SCDream",
                                        color: Color.fromARGB(255, 34, 40, 49), //black
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                /////////////////////// 목록 //////////////////////////
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      color: const Color.fromARGB(255, 0, 173, 181),
                                      child: const Text(
                                        " PACE ",
                                        style: TextStyle(
                                            fontFamily: "SCDream",
                                            color: Color.fromARGB(255, 238, 238, 238), //white
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(

                                      color: const Color.fromARGB(255, 0, 173, 181),
                                      child: const Text(
                                        " KM ",
                                        style: TextStyle(
                                            fontFamily: "SCDream",
                                            color: Color.fromARGB(255, 238, 238, 238), //white
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),

                                ///////////////////////과거 기록 (가져온)//////////////////////////
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // 과거 페이스
                                    Text(
                                      TimeFormatting.timeWriteFormatting(
                                        timeInSecond : logAveragePace,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: "SCDream",
                                        color: Color.fromARGB(255, 34, 40, 49), //black
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      // 과거 움직인 거리
                                      (logDistanceMoved/unit1000Int).toStringAsFixed(2),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: "SCDream",
                                        color: Color.fromARGB(255, 34, 40, 49), //black
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            /*
                          gps 데이터를 stream 으로 받아와 화면을 주기적으로 update
                          현재는 임시로 화면을 구축해둔 상태
                          TODO : unity 화면으로 gps 데이터를 표현
                          */
                            const SizedBox(
                              height: 25,
                            ),
                            SingleChildScrollView(
                              child : Container(
                                color: Colors.grey,
                                width: MediaQuery.of(context).size.width,
                                height: 400,
                                child: const Text("달리기 창"),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                const SizedBox(
                  height: 25,
                ),
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
                        showDialog(
                            context: context,
                            builder: (BuildContext context){
                              String? userInput;
                              if(logFinished){
                                return AlertDialog(
                                  title: const Text("운동을 완료하였습니다!"),
                                  titlePadding: const EdgeInsets.all(20),
                                  contentPadding: const EdgeInsets.only(top: 0),
                                  backgroundColor: const Color.fromARGB(255, 238, 238, 238),
                                  content: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    height: 150,
                                    child: SingleChildScrollView( // SingleChildScrollView 추가
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(height: 5),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "담벼락에 남길 한마디를 입력해주세요",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: "SCDream",
                                                  color: Color.fromARGB(255, 34, 40, 49), // black
                                                  fontSize: 17,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              TextFormField(
                                                onChanged: (value) {
                                                  // 입력 값이 변경될 때마다 호출되는 콜백
                                                  setState(() {
                                                    userInput = value; // 입력 값을 변수에 저장
                                                  });
                                                },
                                                decoration: const InputDecoration(
                                                  hintText: '텍스트를 입력하세요', // 입력 필드에 힌트 텍스트
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10), // 수평(padding) 값 조정
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context); // AlertDialog 닫기
                                              _data = {
                                                "runner" : userName,
                                                "average_pace" : TimeFormatting.timeWriteFormatting(
                                                  timeInSecond : averagePace,
                                                ),
                                                "total_distance" : distanceMoved,
                                                "start_time" : DateTime.fromMillisecondsSinceEpoch(defaultTime),
                                                "wall" : userInput,
                                              };
                                              _saveLog(_data);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('확인'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );

                              }
                              else{
                                return AlertDialog(
                                    title: const Text("운동을 그만두시게요?"),
                                    contentPadding: const EdgeInsets.only(top: 0),
                                    backgroundColor: const Color.fromARGB(255, 238, 238, 238),
                                    content: SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.8,
                                        height: 120,
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const SizedBox(height : 5),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Text(
                                                    "아직 기록이 남아있습니다.",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: "SCDream",
                                                      color: Color.fromARGB(255, 34, 40, 49), //black
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                  Text(
                                                    "그래도 그만하시겠습니까?",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: "SCDream",
                                                      color: Color.fromARGB(255, 34, 40, 49), //black
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                      child : ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                                                          backgroundColor: Colors.grey, //teal
                                                          elevation: 0,
                                                        ),
                                                        onPressed : (){
                                                          Navigator.of(context).pop();
                                                          _data = {
                                                            "runner" : userName,
                                                            "average_pace" : TimeFormatting.timeWriteFormatting(
                                                              timeInSecond : averagePace,
                                                            ),
                                                            "total_distance" : distanceMoved,
                                                            "start_time" : DateTime.fromMillisecondsSinceEpoch(defaultTime),
                                                            "wall" : "",
                                                          };
                                                          _saveLog(_data);
                                                          Navigator.pop(context);
                                                        },
                                                        child : const Text("종료",
                                                          style: TextStyle(
                                                            fontFamily: "SCDream",
                                                            color: Color.fromARGB(255, 238, 238, 238), //white
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                  const SizedBox(width: 5,),
                                                  SizedBox(
                                                      child : ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                                                          backgroundColor: const Color.fromARGB(255, 0, 173, 181), //teal
                                                          elevation: 0,
                                                        ),
                                                        onPressed : (){
                                                          Navigator.of(context).pop();
                                                        },
                                                        child : const Text("계속",
                                                          style: TextStyle(
                                                            fontFamily: "SCDream",
                                                            color: Color.fromARGB(255, 238, 238, 238), //white
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ]
                                        )
                                    )
                                );
                              }
                            }
                        );
                      },
                      heroTag: 'strop running',
                      backgroundColor: Colors.blueGrey,
                      child: const Text("Exit"),
                    ),
                  ],
                ),
                // 운동 시작, 운동 종료 버튼들
              ],
            )
        ),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    _runningTimer?.cancel();
  }
}
