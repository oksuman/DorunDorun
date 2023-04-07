import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../../group.dart';
import '../../utilities/firebaseService.dart';
import '../../utilities/storageService.dart';

class MakeRoomPage extends StatefulWidget {
  const MakeRoomPage({Key? key}) : super(key: key);

  @override
  State<MakeRoomPage> createState() => _MakeRoomPageState();
}

class _MakeRoomPageState extends State<MakeRoomPage> {
  int _modeNum = 0;
  int _membersNum = 3;
  String _uid = "";
  String _ugroup = "";
  Group? myGroup;

  Location location = Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  _giveAuthority() async{
    _serviceEnabled = await location.serviceEnabled();
    if(!_serviceEnabled){
      _serviceEnabled = await location.serviceEnabled();
      if(!_serviceEnabled){
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await location.hasPermission();
      if(_permissionGranted != PermissionStatus.granted){
        return;
      }
    }
  }

  _getMyData() async {
    await StorageService().getUserID().then((value) {
      setState(() {
        _uid = value!;
      });
    });
    await StorageService().getUserGroup().then((value) {
      setState(() {
        _ugroup = value!;
      });
    });
  }

  _makeGroup() async{
    await _getMyData();
    if(_ugroup == ""){
       String? groupID = await FirebaseService(uid: _uid).createGroup();
       _ugroup = groupID!;
       StorageService().saveUserGroup(_ugroup);
    }
    myGroup = Group(_ugroup);
  }

  @override
  void initState() {
    super.initState();
    _giveAuthority();
    _makeGroup();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // 앱 상단 바
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text(
          "러닝 방 생성",
          style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: Text("아바타 창"),
            ),
            _playerStatusField(),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _modeNum = 0;
                    });
                  },
                  child: Text("기본모드",
                      style: (_modeNum!=0)
                          ?TextStyle(color:Colors.grey):TextStyle(color:Colors.black)
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _modeNum = 1;
                    });
                  },
                  child: Text("협동모드",
                    style: (_modeNum!=1)
                        ?TextStyle(color:Colors.grey):TextStyle(color:Colors.black)
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _modeNum = 2;
                    });
                  },
                  child: Text("경쟁모드",
                    style: (_modeNum!=2)
                        ?TextStyle(color:Colors.grey):TextStyle(color:Colors.black),
                  ),
                )
              ],
            ),
            SizedBox(height: 20,),
            _modeOptionWidget(),
            ElevatedButton( //달리기 버튼
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.yellow,
                ),
                onPressed: () async{
                  WidgetsFlutterBinding.ensureInitialized();
                  // Wakelock.enable();
                  await location.getLocation().then((res){
                    Navigator.pushNamed(context, "/toRunningPage", arguments: res);
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
  Widget _myStatusContainer(){
    return Container(
      color: Colors.teal,
      width: MediaQuery.of(context).size.width/2,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("Me"),
          Text("host"),
        ],
      ),
    );
  }
  Widget _playerStatusContainer(String playerName){
    return Container(
      color: Colors.green,
      width: MediaQuery.of(context).size.width/2,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(playerName),
          ElevatedButton(onPressed: (){}, child: Text("X"))
        ],
      ),
    );
  }
  Widget _validStatusContainer(){
    return Container(
      color: Colors.grey,
      width: MediaQuery.of(context).size.width/2,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
              onPressed: (){

              },
              child: Text("+")
          )
        ],
      ),
    );
  }
  Widget _playerStatusField(){
    return Column(
      children: [
        Row(
          children: [
            _myStatusContainer(),
            (_membersNum>1)?
            _playerStatusContainer("Player2"):
            _validStatusContainer(),
          ],
        ),
        Row(
          children: [
            (_membersNum>2)?
            _playerStatusContainer("Player3"):
            _validStatusContainer(),
            (_membersNum>3)?
            _playerStatusContainer("Player4"):
            _validStatusContainer(),
          ],
        ),
      ],
    );
  }

  Widget _modeOptionWidget(){
    if(_modeNum == 0){
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
    }else if(_modeNum == 1){
      return Column(
        children: [

        ],
      );
    }else if(_modeNum == 2){
      return Column(
        children: [

        ],
      );
    }else{
      return CircularProgressIndicator();
    }

  }
}
