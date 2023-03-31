/*******************************
 * 러닝을 시작할 수 있는 페이지입니다.  *
 *******************************/

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'runningPage.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

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
          "시작화면",
          style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      drawer: Drawer(

      ),
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
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => RunningPage(initialLocation: res)));
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
