/*************************************
 * 러닝을 진행하면서 보게 되는 페이지 입니다.  *
 *************************************/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:synchronized/synchronized.dart';
import '../../utilities/firebaseService.dart';
import '../../utilities/storageService.dart';
import 'runResultPage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wakelock/wakelock.dart';
import 'RunningSetting.dart';
import '../analysisScreens/dataFormat.dart';
import '../../models/group.dart';
import 'memberLog.dart';

class RunningPage extends StatefulWidget {
  // 이전 화면에서 넘겨주는 class 변수들
  final LocationData initialLocation; // 첫 위치 초기화용 LocationData
  final Group thisGroup; // 현재 사용자가 속해있는 그룹 정보
  final String userName; // 사용자 이름으로 기록을 업로드할 때 기록의 주인을 식별하기 위해 사용. 꼭 이름일 필요는 없음.
  final String userId;

  const RunningPage({
    super.key,
    required this.initialLocation,
    required this.thisGroup,
    required this.userName,
    required this.userId,
  });

  @override
  State<RunningPage> createState() => _RunningPageState();
}


class _RunningPageState extends State<RunningPage> {
  // group 컬렉션 참조
  final CollectionReference _userCollection =
    FirebaseFirestore.instance.collection("users"); //유저 컬렉션
  final CollectionReference _groupReference =
    FirebaseFirestore.instance.collection("groups");
  //스트림 종료 위해(최적화)
  StreamSubscription? _ttsListen = null; //tts 다큐멘트 스트림 구독
  List<Map<String, dynamic>> _allTtsData = []; //tts 컬렉션 데이터

  Lock lock = Lock();

  // 이번 러닝 기록을 저장할 Collection 의 레퍼런스
  late final CollectionReference _logReference;
  late final String groupId;
  late final LocationData initialLocation;

  Location location = Location();
  Distance distance = const Distance();

  late final int defaultTime; // 러닝을 시작한 시점(timestamp), 이 변수를 기준으로 흐른 시간을 고려
  double distanceMoved = 0; // 이번 러닝에서 달린 누적 거리
  int timesUnit = 0; // 단위거리를 주파한 횟수. 즉, distanceMoved % unit. unit 은 측정 단위로, 추후 변경
  int deltaTime = 0;
  int averagePace = 0; // sec-1km 의미 : 단위거리(1km)를 주파하는데 걸릴 것으로 예상되는 시간(sec)

  List<LatLng> pathMoved = List<LatLng>.empty(growable: true); // 이번 러닝에서 이동한 경로. (위도,경도) 쌍의 리스트
  /*
      snapshots : 순간 기록 들을 저장
      runner : 주자 id
      accumulated_distance : 현 시점까지 이동한 누적거리
      delta_time : 운동을 시작하고 지난 시간 (milliseconds)
      velocity : 현 시점의 순간 속도
      average_pace : 평균 페이스
   */
  List<Map<String, Object>> snapshots = List<Map<String, Object>>.empty(growable: true);
  List<Map<int, Object>> pace = List<Map<int, Object>>.empty(growable: true); // 단위 거리를 지난 시간을 기록하자.

  //// 모드에 따른 Setting ////////////////////////////
  /*
  -1 : 목표 제약 없음
  0 : 목표 거리 있음
  1 : 목표 시간 있음
   */
  late final int code;
  bool goalFullCompleted = false;
  bool goalHalfCompleted = false;
  late final double distanceGoal;
  late final int timeGoal;

  void setMode(){
    debugPrint("세팅은 할게");
    debugPrint(widget.thisGroup.getGroupMode());
    if(widget.thisGroup.getGroupMode() == "basic"){
      debugPrint("basic 까지는 왔어");
      Map<String, double> goal =  widget.thisGroup.getBasicGoal();
      debugPrint("$goal");
      if(widget.thisGroup.getBasicSetting() == "목표 거리"){
        debugPrint("목표");
        code = 0;
        distanceGoal = goal["목표 거리"]!;
      }
      else if(widget.thisGroup.getBasicSetting() == "목표 시간"){
        code = 1;
        distanceGoal = goal["목표 시간"]!;
      }
      else{
        code = -1;
      }
    }
    else if(widget.thisGroup.getGroupMode() == "coop"){
      code = 0;
      distanceGoal = widget.thisGroup.getCoopGoal(0);
    }
    else if(widget.thisGroup.getGroupMode() == "comp"){
      if(widget.thisGroup.getCompSetting() == "거리"){
        code = 0;
        distanceGoal = widget.thisGroup.getCompGoal()["거리"]!;
      }
    }
    else{
      code = -1;
    }
  }
  /////////////////////////////////////////////////////
  //// 다른 Group Member 들의 달리기 현황을 저장할 Data ////
  late membersLog _membersLog;
  late Set<String> memberSet;
  //// Timer 관련 ////////////////////////////////////////////////////////////////
  Timer? _runningTimer;
  int _runningSeconds = 0; // 러닝이 시작 하고 흐른 시간(seconds)
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
  //////////////////////////////////////////////////////////////////////////////////

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

  void ttsExit({
    required String memberName,
  }) async{ // 그룹의 멤버가 중도 이탈
    await tts.speak("$memberName 님이 러닝을 종료하였습니다.");
  }

  void ttsHalfDistance() async{
    await tts.speak("운동 목표의 절반에 도달 하셨습니다. 조금만 힘내세욥!");
  }
  void ttsComplete() async{
    await tts.speak("목표를 모두 달성하셨습니다. 축하드립니다!!");
  }

  void ttsHalfTime() async{
    await tts.speak("운동 목표 시간의 절반이 경과 되었습니다."
        "운동을 시작한 지점에서 러닝을 종료하고 싶으시다면 지금 돌아가시면 됩니다!");
  }


  void _getTtsMsg(){ //tts 스트림 열기
    final DocumentReference userDocument = _userCollection.doc(widget.userId);
    final CollectionReference ttsCollection =
      userDocument.collection("tts");
    _ttsListen = ttsCollection.snapshots().listen((event) {
      _allTtsData = event.docs.map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }
  Future<void> speakAndWait(String text) async { //tts 말할때까지 대기
    Completer<void> completer = Completer<void>();
    tts.setCompletionHandler(() {
      completer.complete(); // TTS 작업이 완료될 때 Future를 완료합니다.
    });
    await tts.speak(text); // TTS 작업 시작
    await completer.future; // TTS 작업이 완료될 때까지 Future를 대기합니다.
  }
  _speakTtsMsg() async{ //tts 메시지 지속적으로 수신
    for(int i = 0; i<_allTtsData.length; i++){
      await speakAndWait("${_allTtsData[i]["senderName"]} 님이 메시지를 보냈습니다.   ${_allTtsData[i]["message"]}");
      await FirebaseService(
        uid: widget.userId,
      ).ttsClear(_allTtsData[i]["ttsId"]);
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////

  void updateMembersLog() async {
    QuerySnapshot<Object?> querySnapshot = await _logReference.orderBy('delta_time', descending: true).get();

    if(querySnapshot.docs.isNotEmpty && querySnapshot is QuerySnapshot<Map<String, dynamic>>){
      List<DocumentSnapshot<Map<String, dynamic>>> documents = querySnapshot!.docs;

      Set<String> processedRunners = {};
      for (DocumentSnapshot<Map<String, dynamic>> document in documents) {
        Map<String, dynamic> data = document.data()!;
        // document에 대한 작업 수행
        var runner = data['runner'];
        if(processedRunners.contains(runner)){
          continue;
        }
        if(
          deltaTime > _membersLog.getLastTime(runner: runner)
        ){
          if(data['accumulated_distance'] as num == -1){
            ttsExit(memberName: runner);
            memberSet.remove(runner);
          }
          else{
            _membersLog.addRecentLog(
              runner: runner as String,
              deltaTime: deltaTime as num,
              distanceMoved: data['accumulated_distance'] as num,
              velocity: data['velocity'] as num,
            );
          }
        }
        processedRunners.add(runner);
        var completed = memberSet.difference(processedRunners).isEmpty;
        if(completed){
          break;
        }
      }
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////
  ////                                   EXIT                                       ////
  //////////////////////////////////////////////////////////////////////////////////////
  void exitRunningPage(int deltaTime) async{
    // 러닝 중인 사람들에게 나갔음을 알리기 //
    var exitData = {
      "runner": widget.userName,
      "accumulated_distance": -1,
      "delta_time": deltaTime,
      "velocity": -1,
    };
    _logReference.add(exitData);

    StorageService().saveUserGroup(""); //스토리지 내 그룹 초기화

    if(widget.thisGroup.getMembersNum()>1){ //멤버가 2명 이상일 때,
      if(widget.thisGroup.getAdminId()==widget.userId){ //내가 admin 이면,
        final nAdminId = widget.thisGroup.getMembersId()[1];
        final nAdminName = widget.thisGroup.getMembersName()[1];
        await FirebaseService(
            uid: widget.userId,
            gid: widget.thisGroup.getGroupId())
            .adminExitGroup(widget.userName, nAdminName, nAdminId); //다음(1번) 멤버에게 권한 전달하고 나가기
      }else{ // 내가 admin 아니면,
        await FirebaseService(
            uid: widget.userId,
            gid: widget.thisGroup.getGroupId())
            .exitGroup(widget.userName); //그룹 나가기
      }
    }else{ //멤버 수가 1명
      await FirebaseService(
          uid: widget.userId,
          gid: widget.thisGroup.getGroupId())
          .endGroup(); //그룹 삭제
    }
    if(goalFullCompleted){
      await FirebaseService(
        uid: widget.userId,
      ).incRunCount(); //달린횟수 증가
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => RunResultPage(
            pathMoved: pathMoved,
            snapshots: snapshots,
            startTime: defaultTime,
            passedTime: _runningSeconds,
            distanceMoved: distanceMoved,
            averagePace : averagePace,
            pace : pace,
            goalCompleted : goalFullCompleted,
        )));
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
      interval: 3000,
      distanceFilter: 5,
    );
    setTts(); //tts 설정
    _getTtsMsg(); //tts 스트림 열기
    _startTimer();
    var groupId = widget.thisGroup.getGroupId();
    _logReference = _groupReference.doc(groupId).collection("log");
    initialLocation = widget.initialLocation;
    defaultTime = initialLocation.time!.toInt();
    var initData = {
      "runner": widget.userName,
      "accumulated_distance": 0,
      "delta_time": deltaTime,
      "velocity": 0,
    };
    // 초기 데이터를 업로드하고, 동시에 snapshots 에 저장
    _logReference.add(initData);
    snapshots.add(initData);
    // 시작 위치를 이동 경로에 추가
    pathMoved.add(LatLng(initialLocation.latitude!, initialLocation.longitude!));
    memberSet = widget.thisGroup.getMembersName().toSet();
    memberSet.remove(widget.userName);
    _membersLog = membersLog(
      memberSet: memberSet,
    );
    setMode();
    debugPrint("________________________");
    debugPrint("code : $code");
    Wakelock.enable();
  }

  @override
  Widget build(BuildContext context) {
    updateMembersLog();
    _membersLog.debugPrintLog();
    lock.synchronized(() async{
      await _speakTtsMsg(); //tts speak -> synchronize 시킴
    });
    return Scaffold(
        body: Center(
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
              /*
                움직인 거리, 평균 페이스 표시 화면
             */
              StreamBuilder<LocationData>(
                  initialData: initialLocation,
                  stream: location.onLocationChanged,
                  builder: (context, stream) {
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

                      // 가장 마지막에 기록된 위치 정보
                      final previousLatitude = pathMoved.last.latitude;
                      final previousLongitude = pathMoved.last.longitude;

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
                      if ((currentLatitude != previousLatitude ||
                          currentLongitude != previousLongitude) &&
                          (changedLocation?.accuracy ?? 10) < 10) {
                        final cur = LatLng(currentLatitude, currentLongitude);
                        final distanceDelta = distance.as(LengthUnit.Meter, cur, pathMoved.last);
                        // 움직인 거리 업데이트
                        distanceMoved += distanceDelta;
                        //// 누적 거리가 특정 조건에 달하면 TTS 안내를 실시한다. 현재는 1km 마다 음성 읽기, 추후 변경 가능 ////
                        if (distanceMoved.toInt() ~/ unit1000Int > timesUnit) {
                          timesUnit++;
                          ttsGuide(
                              times: timesUnit, unit: unit1Kilo,
                              pace: TimeFormatting.timeVoiceFormatting(
                                timeInSecond : averagePace,
                              )
                          );
                          pace.add({
                            timesUnit : deltaTime
                          });
                        }
                        if(!goalHalfCompleted){
                          if(code == 1){
                            if(deltaTime >= timeGoal*30){
                              ttsHalfTime();
                            }
                          }
                          else if(code == -1){
                            if(distanceMoved >= distanceGoal*unit1000Int /2){
                              ttsHalfDistance();
                            }
                          }
                          goalHalfCompleted = true;
                        }
                        if(!goalFullCompleted){
                          if(code == 1){
                            if(deltaTime >= timeGoal*60){
                              ttsComplete();
                            }
                          }
                          else if(code == -1){
                            if(distanceMoved >= distanceGoal*unit1000Int){
                              ttsComplete();
                            }
                          }
                          goalFullCompleted = true;
                        }

                        // 지난 시간 업데이트
                        deltaTime = (currentTime.toInt() - defaultTime) ~/ 1000; // 단위 : 초
                        // 평균 페이스 갱신
                        averagePace = ((unit1000Int * deltaTime)/distanceMoved).round();

                        // 기록 저장
                        var newData = {
                          "runner": widget.userName,
                          "accumulated_distance": distanceMoved,
                          "delta_time": deltaTime,
                          "velocity": currentSpeed,
                        };
                        _logReference.add(newData);
                        snapshots.add(newData);
                        // 지나온 경로에 새로운 포인트 추가
                        pathMoved.add(cur);
                        debugPrint("distanceDelta : $distanceDelta");
                        debugPrint("isMock: $_isMocked");
                      }
                      debugPrint("pathMoved: $pathMoved");
                      debugPrint("isMock: $_isMocked");
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "움직인 거리 : ${(distanceMoved/unit1000Int).toStringAsFixed(2)} km",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: "SCDream",
                                  color: Color.fromARGB(255, 34, 40, 49), //black
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "평균 페이스 : ${TimeFormatting.timeWriteFormatting(
                                  timeInSecond : averagePace,
                                )}",
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
                          /*
                          gps 데이터를 stream 으로 받아와 화면을 주기적으로 update
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
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if(memberSet.isEmpty)
                                    const Text("혼자 뛰는 중"),
                                  if(memberSet.isNotEmpty)
                                    Text(_membersLog.displayRecentLog()),
                                ],
                              ),
                            )
                          ),
                        ],
                      ),
                    );
                  }),

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
                      if(code == -1){
                        exitRunningPage(deltaTime * 100 + 100);
                      }
                      else{
                        if(!goalFullCompleted){
                          showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  contentPadding: const EdgeInsets.only(top: 0),
                                  backgroundColor: const Color.fromARGB(255, 238, 238, 238), //white
                                  content: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    height: 130,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(height : 5),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              if(code == 0)
                                                const Text(
                                                  "목표 거리를 달리지 않았습니다",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: "SCDream",
                                                    color: Color.fromARGB(255, 34, 40, 49), //black
                                                    fontSize: 20,
                                                  ),
                                                )
                                              else if(code == 1)
                                                const Text(
                                                  "목표 시간을 달리지 않았습니다",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: "SCDream",
                                                    color: Color.fromARGB(255, 34, 40, 49), //black
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              const Text(
                                                  "그만하시겠습니까?",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                  fontFamily: "SCDream",
                                                  color: Color.fromARGB(255, 34, 40, 49), //black
                                                  fontSize: 20,
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
                                                  exitRunningPage(deltaTime * 100 + 100);
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
                                              child : const Text("이어서 달리기",
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
                          );
                        }
                        else{
                          exitRunningPage(deltaTime * 100 + 100);
                        }
                      }
                    },
                    heroTag: 'stop running',
                    backgroundColor: Colors.blueGrey,
                    child: const Text("Exit"),
                  ),
                ],
              )
            ],
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    _runningTimer?.cancel();
    try{
      _ttsListen!.cancel(); //tts 목록 스트림 구독 끊음(최적화)
    }catch(e){
      print("스트림이 닫히지 않았습니다.");
    }
  }
}
