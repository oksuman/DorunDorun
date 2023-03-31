import 'package:flutter/material.dart';
import 'package:location/location.dart';

class MakeRoomPage extends StatefulWidget {
  const MakeRoomPage({Key? key}) : super(key: key);

  @override
  State<MakeRoomPage> createState() => _MakeRoomPageState();
}

class _MakeRoomPageState extends State<MakeRoomPage> {
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

  @override
  void initState() {
    super.initState();
    _giveAuthority();
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
}
