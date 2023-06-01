/******************************************
 * 방을 생성 및 관리하는 페이지입니다.             *
 ******************************************
 * admin은 멤버를 강퇴할 수 있습니다.            *
 * 멤버들은 친구를 초대할 수 있습니다.             *
 * 뒤로 가기를 해도 방에서 나가지 않습니다.         *
 * 오른쪽 위 버튼을 누르면 방에서 나갑니다.         *
 * admin이 나갈 시 다음 멤버가 admin이 됩니다.    *
 * 러닝 설정을 할 수 있습니다.                   *
 ******************************************/

import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

import '../../models/group.dart';
import '../../utilities/firebaseService.dart';
import '../../utilities/storageService.dart';
import 'runningPage.dart';

class MakeRoomPage extends StatefulWidget {
  const MakeRoomPage({Key? key}) : super(key: key);

  @override
  State<MakeRoomPage> createState() => _MakeRoomPageState();
}

class _MakeRoomPageState extends State<MakeRoomPage> {
///////////////////////////////////////////////////////////////////////////////////////////////////
//                                        Fields                                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////
  bool _isAdmin = false; //admin 여부
  List<bool> _myIdxList = List.filled(4, false); //멤버 리스트 중 내 인덱스 위치(0~3)
  String _uid = ""; //내 아이디
  String _uname = ""; //내 이름
  String _ugroup = ""; //(스토리즈로 받은) 내 그룹 아이디
  String _gid = ""; //인자로 전달받은 그룹 아이디
  String _thisGroupId = ""; //현재 그룹에 저장할 아이디
  Group _thisGroup = new Group(); //그룹 클래스

  //스트림 종료 위해(최적화)
  StreamSubscription? _groupDocListen = null; //그룹 다큐멘트 스트림 구독
  StreamSubscription? _userDocListen = null; //유저 다큐멘트 스트림 구독

  //지속적으로 호출되는 함수 메모리 개선위한 캐시
  AsyncMemoizer _memPush = AsyncMemoizer();
  AsyncMemoizer _memKick = AsyncMemoizer();
  AsyncMemoizer _memGroup = AsyncMemoizer();

  Map<String,dynamic> _groupData = {}; //스트림으로 받은 그룹 다큐멘트 데이터

  final currentUser = FirebaseAuth.instance;
  final CollectionReference _userCollection =
  FirebaseFirestore.instance.collection("users"); //파이베이스 유저 컬렉션 가져오기

  Location location = Location();

///////////////////////////////////////////////////////////////////////////////////////////////////
//                                        Functions                                              //
///////////////////////////////////////////////////////////////////////////////////////////////////

  //스토리지에서 내 데이터 받아오기
  _getMyData() async {
    await StorageService().getUserID().then((value) {
      setState(() {
        _uid = value!;
      });
    });
    await StorageService().getUserName().then((value) {
      setState(() {
        _uname = value!;
      });
    });
    await StorageService().getUserGroup().then((value) {
      setState(() {
        _ugroup = value!;
      });
    });
  }
  //그룹 초기 설정
  _setGroup() async {
    await _getMyData(); //내 데이터 받아오기
    if (_gid == "") { //만약 이전페이지에서 전달 받은 그룹 아이디가 없을 때, (버튼눌러 들어옴)
      if(_ugroup == ""){ //만약 현재 내 그룹이 없으면,
        String? groupID = await FirebaseService(uid: _uid).createGroup(_uname); // 새로 방 파기
        _thisGroupId = groupID!; //새로운 그룹 아이디 -> 현재 그룹 아이디
      }else{ //현재 내 그룹이 있으면(스토리지),
        _thisGroupId = _ugroup; //내 그룹 -> 현재 그룹의 아이디
      }
    }else{ //만약 이전페이지에서 전달 받은 그룹 아이디가 있을 때,(초대받아 들어옴)
      _thisGroupId = _gid;
    }
    StorageService().saveUserGroup(_thisGroupId); //스토리지에 저장
    _updateGroup(); //그룹 상태 업데이트
  }

  //그룹 상태 업데이트
  _updateGroup(){
    final CollectionReference groupsCollection =
    FirebaseFirestore.instance.collection("groups"); //그룹 컬렉션
    final DocumentReference groupsDocument = groupsCollection.doc(_thisGroupId); //그룹 다큐멘트
    _groupDocListen = groupsDocument.snapshots().listen((DocumentSnapshot documentSnapshot) { //그룹 다큐멘트 스트림으로 계속 듣기
      try{
        if(documentSnapshot.data()!=null)
          _groupData = documentSnapshot.data()! as Map<String,dynamic>; //다큐멘트 데이터
        // 그룹 객체 업데이트
        _thisGroup.setGroupId(_groupData["groupId"]);
        _thisGroup.setGroupState(_groupData["groupState"]);
        _thisGroup.setAdminId(_groupData["adminId"]);
        _thisGroup.setAdminName(_groupData["adminName"]);
        _thisGroup.setMembersId(_groupData["membersId"]);
        _thisGroup.setMembersName(_groupData["membersName"]);
        _thisGroup.setMembersAvatar(_groupData["membersAvatar"]);
        _thisGroup.setMembersReady(_groupData["membersReady"]);
        _thisGroup.setGroupMode(_groupData["groupMode"]);
        _thisGroup.setBasicSetting(_groupData["basicSetting"]);
        _thisGroup.setBasicGoal(_groupData["basicGoal"]);
        _thisGroup.setCoopSetting(_groupData["coopSetting"]);
        _thisGroup.setCompSetting(_groupData["compSetting"]);
        _thisGroup.setCompGoal(_groupData["compGoal"]);
        _isAdmin = (_thisGroup.getAdminId()==_uid); //내 아이디가 그룹의 admin 아이디와 같으면: isAdmin을 true로

        for(int i = 0; i<_thisGroup.getMembersNum(); i++){
          if(_thisGroup.getMembersId()[i]==_uid){
            _myIdxList[i] = true;
          }
        } //내인덱스리스트 초기화(내가 몇번째?)
      }catch(e){ //그룹아이디 받아오기 전에 오류들 흘려주기
        debugPrint("$e");
      }finally{
        if(mounted){ //위젯 삭제 후 새로고침 오류 방지용
          setState(() { //앱 새로고침

          });
        }
      }
    });
  }
  //추방 여부 확인
  _getIsKicked(){
    final DocumentReference userDocument = _userCollection.doc(_uid); //유저 다큐멘트
    _userDocListen = userDocument.snapshots().listen((DocumentSnapshot documentSnapshot) async{ //유저 다큐멘트 스트림으로 계속 듣기
      try{
        Map<String,dynamic> _userData = documentSnapshot.data()! as Map<String,dynamic>; //유저 데이터
        if(_userData["isKicked"]){ //만약 추방당했으면
          print("방에서 추방당했습니다.");
          Navigator.of(context).pop(); //방에서 나가기
          //유저 상태 초기화
          await FirebaseService(
            uid: _uid,
          )
              .resetUserState();
          StorageService().saveUserGroup("");
        }
      }catch(e){ //유저 아이디 받아오기 전에 나오는 오류 흘려주기

      }finally{
        if(mounted){ //앱 삭제 후 새로고침 오류 방지
          setState(() { //새로고침

          });
        }
      }
    });
  }
  _pushIfStart() async{
    if(_thisGroup.getGroupState()=="running"){
      WidgetsFlutterBinding.ensureInitialized();
      await location.getLocation().then((res) {
        _memPush.runOnce((){ //한번만 실행되게
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context)=>
                  RunningPage(
                    initialLocation : res,
                    thisGroup : _thisGroup,
                    userName: _uname,
                    userId: _uid,
                  )));
        });
      });
    }
  }
///////////////////////////////////////////////////////////////////////////////////////////////////
//                                        Message                                                //
///////////////////////////////////////////////////////////////////////////////////////////////////
  _showKickDialog(String fid, String pname) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("플레이어 추방"),
          content: Text("정말 $pname 님을 강퇴하겠습니까?"),
          actions: [
            CupertinoButton(
              child: const Text("취소"),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            CupertinoButton(
              child: const Text("강퇴"),
              onPressed: () async{
                Navigator.pop(context);
                await FirebaseService(
                    fid: fid,
                    gid: _thisGroupId
                )
                    .kickPlayer(pname); //플레이어 추방하기
              },
            ),
          ],
        );
      },
    );
  }
  void _showReadyAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Text("아직 준비를 안한 인원이 있습니다!"),
          actions: [
            CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }
///////////////////////////////////////////////////////////////////////////////////////////////////
  //위젯 시작 시
  @override
  void initState() {
    super.initState();
    _setGroup(); //그룹 초기 설정
  }
  //위젯 종료 시
  @override
  void dispose() {
    super.dispose();
    try{
      _groupDocListen!.cancel(); //그룹 다큐멘트 스트림 구독 끊기 (최적화)
      _userDocListen!.cancel(); //그룹 다큐멘트 스트림 구독 끊기 (최적화)
    }catch(e){
      print("스트림이 닫히지 않았습니다."); //혹시나 해서
    }
  }
///////////////////////////////////////////////////////////////////////////////////////////////////
//                                        SCAFFOLD                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    _gid = ModalRoute.of(context)!.settings.arguments as String; //인자 전 페이지에서 받아오기

    if(_thisGroupId!=""){ //그룹 아이디 받아오면
      _memGroup.runOnce(()=> _updateGroup());
      _pushIfStart();
    }
    if(_uid!=""){ //유저 아이디 받아오면
      _memKick.runOnce(()=> _getIsKicked());
    }
    return Scaffold(
      appBar: AppBar(
        // 앱 상단 바
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 238, 238, 238)),//white
        title: const Text(
          "러닝 방 생성",
          style: TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 238, 238, 238), //white
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 173, 181), //teal
        centerTitle: true,
        actions: [
          //방 나가기 버튼
          IconButton(
            onPressed: ()async{
              StorageService().saveUserGroup(""); //스토리지 내 그룹 초기화
              Navigator.of(context).pop(); //방 나가기
              if(_thisGroup.getMembersNum()>1){ //멤버가 2명 이상일 때,
                if(_isAdmin){ //내가 admin 이면,
                  final nAdminId = _thisGroup.getMembersId()[1];
                  final nAdminName = _thisGroup.getMembersName()[1];
                  await FirebaseService(
                      uid: _uid,
                      gid: _thisGroupId)
                      .adminExitGroup(_uname, nAdminName, nAdminId); //다음(1번) 멤버에게 권한 전달하고 나가기
                }else{ // 내가 admin 아니면,
                  await FirebaseService(
                      uid: _uid,
                      gid: _thisGroupId)
                      .exitGroup(_uname); //그룹 나가기
                }
              }else{ //멤버 수가 1명
                await FirebaseService(
                    uid: _uid,
                    gid: _thisGroupId)
                    .endGroup(); //그룹 삭제
              }
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 238, 238, 238), //white
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container( //아바타 창
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: const Text("아바타 창"),
              ),
              Container(width: MediaQuery.of(context).size.width, height: 5, color: Colors.grey,),
              _playerStatusField(), //유저 접속 목록(밑에 있음)
              Container(width: MediaQuery.of(context).size.width, height: 5, color: Colors.grey,),
              Row( //기본모드, 협동모드, 경쟁모드 설정 창
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () async{
                      if(_isAdmin){
                        setState(() {
                          _thisGroup.setGroupMode("basic");
                        });
                        await FirebaseService(
                          gid: _thisGroupId,
                        ).setBasicMode(_thisGroup.getBasicSetting(), _thisGroup.getBasicGoal());
                      }

                    },
                    child: Container(
                      color: Colors.transparent,
                      width: 120,
                      height: 40,
                      child: Center(
                        child: Text("기본모드",
                            style: (_thisGroup.getGroupMode() != "basic")
                                ? const TextStyle(
                              fontFamily: "SCDream",
                              fontSize: 14,
                              color: Colors.grey,
                            ) : const TextStyle(
                                fontFamily: "SCDream",
                                fontSize: 16,
                                color: Color.fromARGB(255, 0, 173, 181),
                                fontWeight: FontWeight.bold
                            )
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      if(_isAdmin){
                        setState(() {
                          _thisGroup.setGroupMode("coop");
                        });
                        await FirebaseService(
                          gid: _thisGroupId,
                        ).setCoopMode(_thisGroup.getCoopSetting());
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: 120,
                      height: 40,
                      child: Center(
                        child: Text("협동모드",
                            style: (_thisGroup.getGroupMode() != "coop")
                                ? const TextStyle(
                              fontFamily: "SCDream",
                              fontSize: 14,
                              color: Colors.grey,
                            ) : const TextStyle(
                                fontFamily: "SCDream",
                                fontSize: 16,
                                color: Color.fromARGB(255, 0, 173, 181),
                                fontWeight: FontWeight.bold
                            )
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      if(_isAdmin){
                        setState(() {
                          _thisGroup.setGroupMode("comp");
                        });
                        await FirebaseService(
                          gid: _thisGroupId,
                        ).setCompMode(_thisGroup.getCompSetting(), _thisGroup.getCompGoal());
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: 120,
                      height: 40,
                      child: Center(
                        child: Text(
                          "경쟁모드",
                          style: (_thisGroup.getGroupMode() != "comp")
                              ? const TextStyle(
                            fontFamily: "SCDream",
                            fontSize: 14,
                            color: Colors.grey,
                          ) : const TextStyle(
                              fontFamily: "SCDream",
                              fontSize: 16,
                              color: Color.fromARGB(255, 0, 173, 181),
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Container(width: MediaQuery.of(context).size.width, height: 1, color: Colors.grey,),
              _modeOptionWidget(), //러닝 설정 창(밑에 있음)
              Container(
                width: MediaQuery.of(context).size.width,
                height: 80,
                child: Center(
                  child: ElevatedButton(
                    //달리기 버튼
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: (_isAdmin)
                          ?const Color.fromARGB(255, 0, 173, 181) //teal
                          :(_thisGroup.getReady(_uid))
                          ?Colors.lightBlueAccent
                          :const Color.fromARGB(255, 0, 173, 181), //teal
                        elevation: 0,
                      ),
                      onPressed: () async {
                        int readyCount = _thisGroup.getMembersReady().values.where((value) => value == true).length;
                        if(_isAdmin){
                          if(readyCount==_thisGroup.getMembersNum()){
                            await FirebaseService(
                                gid: _thisGroupId)
                                .setGroupState(true);
                          }else{
                            _showReadyAlert();
                          }
                        }else{
                          setState(() {
                            _thisGroup.setReady(_uid,!_thisGroup.getReady(_uid));
                          });
                          await FirebaseService(
                              uid: _uid,
                              gid: _thisGroupId)
                              .setReady(_thisGroup.getReady(_uid));
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 50,
                        child: Center(
                          child: Text(
                            (_isAdmin)
                                ?"달리기 시작"
                                :(_thisGroup.getReady(_uid))?"준비 완료":"준비 하기",
                            style: const TextStyle(
                                fontFamily: "SCDream",
                                color: const Color.fromARGB(255, 238, 238, 238), //white
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      )),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
///////////////////////////////////////////////////////////////////////////////////////////////////
//                                        WIDGETS                                                //
///////////////////////////////////////////////////////////////////////////////////////////////////
  //접속 여부 전체 창
  Widget _playerStatusField() {
    //접속 수만큼 플레이어 창으로, 나마지는 빈 창으로 설정
    return (_thisGroup.getMembersNum()>0)?Column( //1명 이상
      children: [
        Row(
          children: [
            _playerStatusContainer(1, _thisGroup.getMembersName()[0], _thisGroup.getMembersId()[0], _myIdxList[0]),
            (_thisGroup.getMembersNum() > 1) //2명 이상
                ? _playerStatusContainer(2, _thisGroup.getMembersName()[1], _thisGroup.getMembersId()[1], _myIdxList[1])
                : _validStatusContainer(),
          ],
        ),
        Row(
          children: [
            (_thisGroup.getMembersNum() > 2) //3명 이상
                ? _playerStatusContainer(3, _thisGroup.getMembersName()[2], _thisGroup.getMembersId()[2], _myIdxList[2])
                : _validStatusContainer(),
            (_thisGroup.getMembersNum() > 3) //4명 이상
                ? _playerStatusContainer(4, _thisGroup.getMembersName()[3], _thisGroup.getMembersId()[3], _myIdxList[3])
                : _validStatusContainer(),
          ],
        ),
      ],
    ):Container(
        color: Colors.grey, //나면 파랑, 아니면 초록
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: const Center(child: CircularProgressIndicator(),)); //멤버 수가 0명이면(파이어스토어에서 아직 못받아오면) 모래시계
  }
  //플레이어 창(번호, 이름, 아이디, 나인지)
  Widget _playerStatusContainer(int index, String playerName, String playerId, bool isMe) {
    return (_isAdmin)? //내가 admin이면,
    Container(
      padding: const EdgeInsets.all(5),
      color: (isMe)?Colors.lightBlueAccent:Colors.grey, //나면 파랑, 아니면 초록
      width: MediaQuery.of(context).size.width / 2,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              width: 30,
              color: const Color.fromARGB(255, 0, 173, 181), //teal
              child: Center(
                  child: Text(index.toString(),
                    style: const TextStyle(
                      fontFamily: "SCDream",
                      color: Color.fromARGB(255, 238, 238, 238), //white
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  )
              )
          ),
          Container(
              width: MediaQuery.of(context).size.width / 2 - 80,
              color: (_thisGroup.getReady(playerId))
                  ?const Color.fromARGB(255, 0, 173, 181)//teal
                  :const Color.fromARGB(255, 238, 238, 238),//white
              child: Center(
                  child: Text(playerName,
                    style: const TextStyle(
                      fontFamily: "SCDream",
                      color: Color.fromARGB(255, 34, 40, 49), //black
                      fontSize: 12,
                    ),
                  )
              )
          ),
          Container(
            height: 50,
            width: 40,
            color: (_thisGroup.getReady(playerId))
                ?const Color.fromARGB(255, 0, 173, 181)//teal
                :const Color.fromARGB(255, 238, 238, 238),//white
            child: (!isMe)? //내가 아니면,
            IconButton(
                icon: const Icon(Icons.close_sharp),
                onPressed: () async{ //추방 버튼
                  _showKickDialog(playerId, playerName);
                }):
            Icon(Icons.star_sharp,
              color: (_thisGroup.getReady(playerId)
                  ?const Color.fromARGB(255, 238, 238, 238) //white
                  :const Color.fromARGB(255, 0, 173, 181) //teal
              ))
          ) //내가 맞으면, 호스트
        ],
      ),
    ): //내가 admin이 아니면,
    Container(
      padding: const EdgeInsets.all(5),
      color: (isMe)?Colors.lightBlueAccent:Colors.grey, //나면 파랑, 아니면 초록
      width: MediaQuery.of(context).size.width / 2,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              width: 30,
              color: const Color.fromARGB(255, 0, 173, 181), //teal
              child: Center(
                  child: Text(index.toString(),
                    style: const TextStyle(
                      fontFamily: "SCDream",
                      color: Color.fromARGB(255, 238, 238, 238), //white
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  )
              )
          ),
          Container(
              width: MediaQuery.of(context).size.width / 2 - 80,
              color: (_thisGroup.getReady(playerId))
                  ?const Color.fromARGB(255, 0, 173, 181)//teal
                  :const Color.fromARGB(255, 238, 238, 238),//white
              child: Center(
                  child: Text(playerName,
                    style: const TextStyle(
                      fontFamily: "SCDream",
                      color: Color.fromARGB(255, 34, 40, 49), //black
                      fontSize: 12,
                    ),
                  )
              )
          ),
          //플레이어가 ready이면
          Container(
              height: 50,
              width: 40,
              color: (_thisGroup.getReady(playerId))
                  ?const Color.fromARGB(255, 0, 173, 181)//teal
                  :const Color.fromARGB(255, 238, 238, 238),//white
              child: Center(
                  child: (playerName==_thisGroup.getAdminName())
                      ? Icon(Icons.star_sharp,
                      color: (_thisGroup.getReady(playerId)
                          ?const Color.fromARGB(255, 238, 238, 238) //white
                          :const Color.fromARGB(255, 0, 173, 181)) //teal
                  ) : const Text(""),
              )),
        ],
      ),
    );
  }
  //접속 안했을 때 창
  Widget _validStatusContainer() {
    return Container(
      padding: const EdgeInsets.all(5),
      color: Colors.grey,
      width: MediaQuery.of(context).size.width / 2,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //초대할 친구 목록 창 버튼
          Container(
            width: 30,
            color: const Color.fromARGB(255, 57, 62, 70), //grey
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2 - 80,
            color: const Color.fromARGB(255, 238, 238, 238), //white
          ),
          Container(
            height: 50,
            width: 40,
            color: const Color.fromARGB(255, 238, 238, 238), //white
            child: IconButton(
              icon: const Icon(Icons.add_sharp),
              onPressed: () {
                showDialog( //초대 창 띄우기
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.only(top: 0),
                        backgroundColor: const Color.fromARGB(255, 238, 238, 238), //white
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width*0.8,
                          height: MediaQuery.of(context).size.height*0.6,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: const Text("친구 초대",
                                  style: TextStyle(
                                      fontFamily: "SCDream",
                                      color: Color.fromARGB(255, 34, 40, 49), //black
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              StreamBuilder(
                                  stream: _userCollection
                                      .doc(currentUser.currentUser!.uid)
                                      .collection("friends")
                                      .where('accepted', isEqualTo: true)
                                      .snapshots(), //친구들만 불러오기
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                                    if (streamSnapshot.hasData) {
                                      return Expanded(
                                        child: ListView.builder(
                                          //친구목록 보이기
                                          itemCount: streamSnapshot.data!.docs.length,
                                          itemBuilder:
                                              (BuildContext context, int index) {
                                            final DocumentSnapshot documentSnapshot =
                                            streamSnapshot.data!.docs[index]; //친구목록 다큐멘트
                                            if(!_thisGroup.getMembersId().contains(documentSnapshot['id'])){ //친구 중 이미 그룹멤버가 아닌 사람들만,
                                              return Card(
                                                child: Container(
                                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                                  height: 60,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            documentSnapshot['fullName'],
                                                            style: const TextStyle(
                                                              fontFamily: "SCDream",
                                                              color: Color.fromARGB(255, 34, 40, 49), //black
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          //닉네임
                                                          Text(documentSnapshot['email'],
                                                            style: const TextStyle(
                                                              fontFamily: "SCDream",
                                                              color: Color.fromARGB(255, 34, 40, 49), //black
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          //이메일
                                                        ],
                                                      ),
                                                      ElevatedButton( //초대 버튼
                                                        style: ElevatedButton.styleFrom(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5),
                                                          ),
                                                          backgroundColor: const Color.fromARGB(255, 0, 173, 181), //teal
                                                          elevation: 0,
                                                        ),
                                                        onPressed: () async {
                                                          Navigator.of(context).pop();
                                                          await FirebaseService(
                                                              uid: _uid,
                                                              fid: documentSnapshot['id'],
                                                              gid: _thisGroupId)
                                                              .inviteFriend(_uname); //친구 초대하기
                                                        },
                                                        child: const Text("초대",
                                                          style: TextStyle(
                                                            fontFamily: "SCDream",
                                                            color: Color.fromARGB(255, 238, 238, 238), //white
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }else{
                                              return Container();
                                            }
                                          },
                                        ),
                                      );
                                    }
                                    return const Center(
                                        child: CircularProgressIndicator()); //아직 파이어베이스 못받아오면 모래시계
                                  }),
                            ],
                          ),
                        ),
                      );
                    });
              },
            ),
          )
        ],
      ),
    );
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  //모드 설정 창
  Widget _modeOptionWidget() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height-511, //321+56+24=431 +80
        child: (_thisGroup.getGroupMode() == "basic")?
        _basicModeWidget():(_thisGroup.getGroupMode() == "coop")?
        _coopModeWidget():(_thisGroup.getGroupMode() == "comp")?
        _compModeWidget():const Center(child: const CircularProgressIndicator())
    );
  }
  Widget _basicModeWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top:20),
          child: Text("목표를 설정하고 자신의 러닝을 기록하는 기본적인 모드입니다.",
            style: TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 34, 40, 49), //black
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 10,),
        TextButton(
            onPressed: (){
              if (_isAdmin) {
                showCupertinoModalPopup(context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      //title: const Text(""),
                      actions: [
                        CupertinoActionSheetAction(
                          child: const Text("목표 거리"),
                          onPressed: () async{
                            _thisGroup.setBasicSetting("목표 거리");
                            Navigator.pop(context);
                            await FirebaseService(
                              gid: _thisGroupId,
                            ).setBasicMode(_thisGroup.getBasicSetting(),_thisGroup.getBasicGoal());
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: const Text("목표 시간"),
                          onPressed: () async{
                            _thisGroup.setBasicSetting("목표 시간");
                            Navigator.pop(context);
                            await FirebaseService(
                              gid: _thisGroupId,
                            ).setBasicMode(_thisGroup.getBasicSetting(),_thisGroup.getBasicGoal());
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: const Text("스피드 측정"),
                          onPressed: () async{
                            _thisGroup.setBasicSetting("스피드 측정");
                            Navigator.pop(context);
                            await FirebaseService(
                              gid: _thisGroupId,
                            ).setBasicMode(_thisGroup.getBasicSetting(),_thisGroup.getBasicGoal());
                          },
                        ),
                      ],
                    ));
              }
              },
            child: Text(_thisGroup.getBasicSetting(),
              style: const TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 57, 62, 70), //grey
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom:20),
          child: TextButton(
            onPressed: (){
              if(_thisGroup.getBasicSetting()!="스피드 측정" && _isAdmin){
                showDialog(
                  // 메시지 창 띄움
                    context: context,
                    builder: (context) {
                      double tempVal = 0;
                      return AlertDialog(
                        //메시지 창
                          contentPadding: const EdgeInsets.all(10),
                          backgroundColor:
                          const Color.fromARGB(255, 238, 238, 238), //white
                          content: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 160,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                Container(
                                  child: Text(_thisGroup.getBasicSetting(),
                                    style: const TextStyle(
                                        fontFamily: "SCDream",
                                        color: Color.fromARGB(255, 34, 40, 49), //black
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.8-80,
                                      child: Form(
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            counterText: ""
                                          ),
                                          maxLength: 4,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          textAlign: TextAlign.end,
                                          onTap: () {
                                            setState(() {
                                            });
                                          },
                                          onChanged: (value) async {
                                            //텍스트 필드 값 바뀔 시
                                            setState(() {
                                              if(value==null){
                                                tempVal = 0;
                                              }else{
                                                tempVal = double.parse(value);
                                              }
                                            });
                                          },
                                          onSaved: (value) async {
                                            setState(() {
                                              if(value==null){
                                                tempVal = 0;
                                              }else{
                                                tempVal = double.parse(value);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Text((_thisGroup.getBasicSetting()=="목표 거리")?"KM":"분",
                                      style: const TextStyle(
                                          fontFamily: "SCDream",
                                          color: Color.fromARGB(255, 34, 40, 49), //black
                                          fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                          ),
                                          backgroundColor: Colors.grey,
                                          elevation: 0,
                                        ),
                                        child: const Text("취소",
                                          style: TextStyle(
                                            fontFamily: "SCDream",
                                            color: Color.fromARGB(255, 238, 238, 238), //white
                                            fontSize: 16,
                                          ),
                                        ),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                        }
                                    ),
                                    const SizedBox(width: 5,),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          backgroundColor: const Color.fromARGB(
                                              255, 0, 173, 181), //teal
                                          elevation: 0,
                                        ),
                                        child: const Text("설정",
                                          style: TextStyle(
                                            fontFamily: "SCDream",
                                            color: Color.fromARGB(255, 238, 238, 238), //white
                                            fontSize: 16,
                                          ),
                                        ),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          if(tempVal!=0){
                                            _thisGroup.getBasicGoal()[_thisGroup.getBasicSetting()] = tempVal;
                                            await FirebaseService(
                                              gid: _thisGroupId,
                                            ).setBasicMode(_thisGroup.getBasicSetting(),_thisGroup.getBasicGoal());
                                          }
                                        }
                                    )

                                  ],
                                )
                              ]
                              )
                          ));
                    });
              }
            },
            child: Text((_thisGroup.getBasicSetting()=="목표 거리")
                ?_thisGroup.getBasicGoal()[_thisGroup.getBasicSetting()]!.toStringAsFixed(2)+" KM"
                :(_thisGroup.getBasicSetting()=="목표 시간")
                ?_thisGroup.getBasicGoal()[_thisGroup.getBasicSetting()]!.toStringAsFixed(0)+" 분"
                :"랩타임",
              style: const TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 57, 62, 70), //grey
                fontWeight: FontWeight.w900,
                fontSize: 60,
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _coopModeWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top:20),
          child: Text("친구들과 함께 협동하여 공동목표를 달성하는 모드입니다.",
            style: TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 34, 40, 49), //black
              fontSize: 14,
            ),
          ),
        ),
        TextButton(
          onPressed: (){
            if (_isAdmin) {
              showCupertinoModalPopup(context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    //title: const Text(""),
                    actions: [
                      CupertinoActionSheetAction(
                        child: const Text("1단계"),
                        onPressed: () async{
                          _thisGroup.setCoopSetting("1단계");
                          Navigator.pop(context);
                          await FirebaseService(
                            gid: _thisGroupId,
                          ).setCoopMode(_thisGroup.getCoopSetting());
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: const Text("2단계"),
                        onPressed: () async{
                          _thisGroup.setCoopSetting("2단계");
                          Navigator.pop(context);
                          await FirebaseService(
                            gid: _thisGroupId,
                          ).setCoopMode(_thisGroup.getCoopSetting());
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: const Text("3단계"),
                        onPressed: () async{
                          _thisGroup.setCoopSetting("3단계");
                          Navigator.pop(context);
                          await FirebaseService(
                            gid: _thisGroupId,
                          ).setCoopMode(_thisGroup.getCoopSetting());
                        },
                      ),
                    ],
                  ));
            }
          },
          child: Text(_thisGroup.getCoopSetting(),
            style: const TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 57, 62, 70), //grey
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
        Container(
          width: 180,
          height: 120,
          color: Colors.grey,
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("총합 ${_thisGroup.getCoopGoal(0)} KM",
              style: const TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 57, 62, 70), //grey
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text("최저 ${_thisGroup.getCoopGoal(1)} pace",
              style: const TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 57, 62, 70), //grey
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        )
      ],
    );
  }
  Widget _compModeWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top:20),
          child: Text("친구들과 경쟁하여 서로 순위를 비교할 수 있는 모드입니다.",
            style: TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 34, 40, 49), //black
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 10,),
        TextButton(
          onPressed: (){
            if (_isAdmin) {
              showCupertinoModalPopup(context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    //title: const Text(""),
                    actions: [
                      CupertinoActionSheetAction(
                        child: const Text("최저 페이스"),
                        onPressed: () async{
                          _thisGroup.setCompSetting("최저 페이스");
                          Navigator.pop(context);
                          await FirebaseService(
                            gid: _thisGroupId,
                          ).setCompMode(_thisGroup.getCompSetting(),_thisGroup.getCompGoal());
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: const Text("목표 거리"),
                        onPressed: () async{
                          _thisGroup.setCompSetting("목표 거리");
                          Navigator.pop(context);
                          await FirebaseService(
                            gid: _thisGroupId,
                          ).setCompMode(_thisGroup.getCompSetting(),_thisGroup.getCompGoal());
                        },
                      ),
                    ],
                  ));
            }
          },
          child: Text(_thisGroup.getCompSetting(),
            style: const TextStyle(
              fontFamily: "SCDream",
              color: Color.fromARGB(255, 57, 62, 70), //grey
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom:20),
          child: TextButton(
            onPressed: (){
              if(_isAdmin){
                showDialog(
                  // 메시지 창 띄움
                    context: context,
                    builder: (context) {
                      double tempVal = 0;
                      return AlertDialog(
                        //메시지 창
                          contentPadding: const EdgeInsets.all(10),
                          backgroundColor:
                          const Color.fromARGB(255, 238, 238, 238), //white
                          content: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 160,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Text(_thisGroup.getCompSetting(),
                                        style: const TextStyle(
                                            fontFamily: "SCDream",
                                            color: Color.fromARGB(255, 34, 40, 49), //black
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.8-80,
                                          child: Form(
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                  counterText: ""
                                              ),
                                              maxLength: 4,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                              ],
                                              textAlign: TextAlign.end,
                                              onTap: () {
                                                setState(() {
                                                });
                                              },
                                              onChanged: (value) async {
                                                //텍스트 필드 값 바뀔 시
                                                setState(() {
                                                  if(value==null){
                                                    tempVal = 0;
                                                  }else{
                                                    tempVal = double.parse(value);
                                                  }
                                                });
                                              },
                                              onSaved: (value) async {
                                                setState(() {
                                                  if(value==null){
                                                    tempVal = 0;
                                                  }else{
                                                    tempVal = double.parse(value);
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        Text((_thisGroup.getCompSetting()=="목표 거리")?"KM":"분",
                                          style: const TextStyle(
                                            fontFamily: "SCDream",
                                            color: Color.fromARGB(255, 34, 40, 49), //black
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(5),
                                              ),
                                              backgroundColor: Colors.grey,
                                              elevation: 0,
                                            ),
                                            child: const Text("취소",
                                              style: TextStyle(
                                                fontFamily: "SCDream",
                                                color: Color.fromARGB(255, 238, 238, 238), //white
                                                fontSize: 16,
                                              ),
                                            ),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                            }
                                        ),
                                        const SizedBox(width: 5,),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(5),
                                              ),
                                              backgroundColor: const Color.fromARGB(
                                                  255, 0, 173, 181), //teal
                                              elevation: 0,
                                            ),
                                            child: const Text("설정",
                                              style: TextStyle(
                                                fontFamily: "SCDream",
                                                color: Color.fromARGB(255, 238, 238, 238), //white
                                                fontSize: 16,
                                              ),
                                            ),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              if(tempVal!=0){
                                                _thisGroup.getCompGoal()[_thisGroup.getCompSetting()] = tempVal;
                                                await FirebaseService(
                                                  gid: _thisGroupId,
                                                ).setCompMode(_thisGroup.getCompSetting(),_thisGroup.getCompGoal());
                                              }
                                            }
                                        )

                                      ],
                                    )
                                  ]
                              )
                          ));
                    });
              }
            },
            child: Text((_thisGroup.getCompSetting()=="목표 거리")
                ?_thisGroup.getCompGoal()[_thisGroup.getCompSetting()]!.toStringAsFixed(2)+" KM"
                :_thisGroup.getCompGoal()[_thisGroup.getCompSetting()]!.toStringAsFixed(0)+" pace"
                ,
              style: const TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 57, 62, 70), //grey
                fontWeight: FontWeight.w900,
                fontSize: 60,
              ),
            ),
          ),
        ),
      ],
    );
  }
}