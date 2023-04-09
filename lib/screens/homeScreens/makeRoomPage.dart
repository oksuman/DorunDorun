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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../../models/group.dart';
import '../../utilities/firebaseService.dart';
import '../../utilities/storageService.dart';

class MakeRoomPage extends StatefulWidget {
  const MakeRoomPage({Key? key}) : super(key: key);

  @override
  State<MakeRoomPage> createState() => _MakeRoomPageState();
}

class _MakeRoomPageState extends State<MakeRoomPage> {
  int _modeNum = 0; //모드 설정(0: 기본, 1: 협동, 3: 경쟁)
  int _membersNum = 0; //그룹 멤버 수
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

  Map<String,dynamic> _groupData = {}; //스트림으로 받은 그룹 다큐멘트 데이터

  final currentUser = FirebaseAuth.instance;
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection("users"); //파이베이스 유저 컬렉션 가져오기

  //**** location 주석 달어주세요 *****
  Location location = Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  _giveAuthority() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }
  //******************************

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
        _groupData = documentSnapshot.data()! as Map<String,dynamic>; //다큐멘트 데이터
        // 그룹 객체 업데이트
        _thisGroup.setGroupId(_groupData["groupId"]);
        _thisGroup.setAdminId(_groupData["adminId"]);
        _thisGroup.setAdminName(_groupData["adminName"]);
        _thisGroup.setMembersId(_groupData["membersId"]);
        _thisGroup.setMembersName(_groupData["membersName"]);
        _membersNum = _groupData["membersNum"]; //멤버수 받아오기
        _isAdmin = (_thisGroup.getAdminId()==_uid); //내 아이디가 그룹의 admin 아이디와 같으면: isAdmin을 true로
        for(int i = 0; i<_myIdxList.length; i++){
          if(_thisGroup.getMembersId()[i]==_uid){
            _myIdxList[i] = true;
          }
        } //내인덱스리스트 초기화(내가 몇번째?)
      }catch(e){ //그룹아이디 받아오기 전에 오류들 흘려주기

      }finally{
        if(this.mounted){ //위젯 삭제 후 새로고침 오류 방지용
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
        if(this.mounted){ //앱 삭제 후 새로고침 오류 방지
          setState(() { //새로고침

          });
        }
      }
    });
  }

  //위젯 시작 시
  @override
  void initState() {
    super.initState();
    _giveAuthority();
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

  @override
  Widget build(BuildContext context) {
    _gid = ModalRoute.of(context)!.settings.arguments as String; //인자 전 페이지에서 받아오기
    if(_thisGroupId!=""){ //그룹 아이디 받아오면
      _updateGroup(); //빌드마다 그룹 상태 업데이트(누가 들어오거나, 추방됐는지 확인)
    }
    if(_uid!=""){ //유저 아이디 받아오면
      _getIsKicked(); //추방여부 계속 확인
    }
    return Scaffold(
      appBar: AppBar(
        // 앱 상단 바
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text(
          "러닝 방 생성",
          style: TextStyle(
              color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
        centerTitle: true,
        actions: [
          //방 나가기 버튼
          IconButton(
            onPressed: ()async{
              Navigator.of(context).pop(); //방 나가기
              if(_membersNum>1){ //멤버가 2명 이상일 때,
                if(_isAdmin){ //내가 admin이면,
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
              StorageService().saveUserGroup(""); //스토리지 내 그룹 초기화
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container( //아바타 창
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: Text("아바타 창"),
            ),
            _playerStatusField(), //유저 접속 목록(밑에 있음)
            SizedBox(
              height: 20,
            ),
            Row( //기본모드, 협동모드, 경쟁모드 설정 창
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _modeNum = 0;
                    });
                  },
                  child: Text("기본모드",
                      style: (_modeNum != 0)
                          ? TextStyle(color: Colors.grey)
                          : TextStyle(color: Colors.black)),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _modeNum = 1;
                    });
                  },
                  child: Text("협동모드",
                      style: (_modeNum != 1)
                          ? TextStyle(color: Colors.grey)
                          : TextStyle(color: Colors.black)),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _modeNum = 2;
                    });
                  },
                  child: Text(
                    "경쟁모드",
                    style: (_modeNum != 2)
                        ? TextStyle(color: Colors.grey)
                        : TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            _modeOptionWidget(), //러닝 설정 창(밑에 있음)
            ElevatedButton(
                //달리기 버튼
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.yellow,
                ),
                onPressed: () async {
                  WidgetsFlutterBinding.ensureInitialized();
                  // Wakelock.enable();
                  await location.getLocation().then((res) {
                    Navigator.pushNamed(context, "/toRunningPage",
                        arguments: res);
                  });
                },
                child: Text(
                  "달리기 시작",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  //접속 여부 전체 창
  Widget _playerStatusField() {
    //접속 수만큼 플레이어 창으로, 나마지는 빈 창으로 설정
    return (_membersNum>0)?Column( //1명 이상
      children: [
        Row(
          children: [
            _playerStatusContainer(1, _thisGroup.getMembersName()[0], _thisGroup.getMembersId()[0], _myIdxList[0]),
            (_membersNum > 1) //2명 이상
                ? _playerStatusContainer(2, _thisGroup.getMembersName()[1], _thisGroup.getMembersId()[1], _myIdxList[1])
                : _validStatusContainer(),
          ],
        ),
        Row(
          children: [
            (_membersNum > 2) //3명 이상
                ? _playerStatusContainer(3, _thisGroup.getMembersName()[2], _thisGroup.getMembersId()[2], _myIdxList[2])
                : _validStatusContainer(),
            (_membersNum > 3) //4명 이상
                ? _playerStatusContainer(4, _thisGroup.getMembersName()[3], _thisGroup.getMembersId()[3], _myIdxList[3])
                : _validStatusContainer(),
          ],
        ),
      ],
    ):Center(child: CircularProgressIndicator(),); //멤버 수가 0명이면(파이어스토어에서 아직 못받아오면) 모래시계
  }

  //플레이어 창(번호, 이름, 아이디, 나인지)
  Widget _playerStatusContainer(int index, String playerName, String playerId, bool isMe) {
    return (_isAdmin)? //내가 admin이면,
    Container(
      color: (isMe)?Colors.blue:Colors.green, //나면 파랑, 아니면 초록
      width: MediaQuery.of(context).size.width / 2,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(index.toString()+". "+playerName),
          (!isMe)? //내가 아니면,
          ElevatedButton(onPressed: () async{ //추방 버튼
            await FirebaseService(
                fid: playerId,
                gid: _thisGroupId
                )
                .kickPlayer(playerName); //플레이어 추방하기
          }, child: Text("X")):
          Text("host") //내가 맞으면, 호스트
        ],
      ),
    ): //내가 admin이 아니면,
    Container(
      color: (isMe)?Colors.blue:Colors.green, //나면 파랑, 아니면 초록
      width: MediaQuery.of(context).size.width / 2,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(index.toString()+". "+playerName),
          //플레이어가 admin이면 host 아니면 비어두기
          (playerName==_thisGroup.getAdminName())?Text("host"):Text(""),
        ],
      ),
    );
  }

  //접속 안했을 때 창
  Widget _validStatusContainer() {
    return Container(
      color: Colors.grey,
      width: MediaQuery.of(context).size.width / 2,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //초대할 친구 목록 창 버튼
          ElevatedButton(
              onPressed: () {
                showDialog( //초대 창 띄우기
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        contentPadding: EdgeInsets.only(top: 0),
                        content: Container(
                          width: MediaQuery.of(context).size.width*0.8,
                          height: MediaQuery.of(context).size.height*0.6,
                          child: Column(
                            children: [
                              Text("친구 초대"),
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
                                              return Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                          documentSnapshot['fullName']),
                                                      //닉네임
                                                      Text(documentSnapshot['email']),
                                                      //이메일
                                                    ],
                                                  ),
                                                  ElevatedButton( //초대 버튼
                                                    onPressed: () async {
                                                      Navigator.of(context).pop();
                                                      await FirebaseService(
                                                          uid: _uid,
                                                          fid: documentSnapshot['id'],
                                                          gid: _thisGroupId)
                                                          .inviteFriend(_uname); //친구 초대하기
                                                    },
                                                    child: Text("초대"),
                                                  )
                                                ],
                                              );
                                            }else{
                                              return Container();
                                            }
                                          },
                                        ),
                                      );
                                    }
                                    return Center(
                                        child: CircularProgressIndicator()); //아직 파이어베이스 못받아오면 모래시계
                                  }),
                            ],
                          ),
                        ),
                      );
                    });
              },
              child: Text("+"))
        ],
      ),
    );
  }

  //모드 설정 창
  Widget _modeOptionWidget() {
    if (_modeNum == 0) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("목표거리:"),
              Text("5km"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("목표시간:"),
              Text("30:00"),
            ],
          ),
        ],
      );
    } else if (_modeNum == 1) {
      return Column(
        children: [],
      );
    } else if (_modeNum == 2) {
      return Column(
        children: [],
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
