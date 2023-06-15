import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorun_dorun/utilities/storageService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utilities/firebaseService.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _authentication = FirebaseAuth.instance;
  String? _userEmail = "";
  String? _userPassword = "";

  _getMyData() async {
    await StorageService().getUserEmail().then((value) {
      //내 아이디
      setState(() {
        _userEmail = value;
      });
    });
    await StorageService().getUserPwd().then((value) {
      //내 아이디
      setState(() {
        _userPassword = value;
      });
    });
  }

  void _permission() async {
    var reqLocStatus = await Permission.location.request();
    var locStatus = await Permission.location.status;

    if (reqLocStatus.isPermanentlyDenied || locStatus.isPermanentlyDenied) {
      print("isPermanentlyDenied");
      openAppSettings(); // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
    } else if (locStatus.isRestricted) {
      print("isRestricted");
      openAppSettings(); // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
    }
  }

  //자동 로그인
  _tryAutoLogin() async{
    Timer(const Duration(seconds: 2),()async{ //2초간 유지
      await _getMyData(); //내 정보 로컬로부터 받아오기
      try{
        if(_authentication.currentUser == null){
          debugPrint("null");
        }
        QuerySnapshot snapshot = await FirebaseService(
            uid: _authentication.currentUser!.uid)
            .getUserData(_userEmail!); //유저 데이터 이메일로 받이오기
        final newUser =
            await _authentication.signInWithEmailAndPassword(
            email: _userEmail!, password: _userPassword!); //파이어베이스 계정 확인
        if(newUser.user != null){
          Navigator.pushNamedAndRemoveUntil(context, '/toNavigationBarPage', (route) => false); //로그인
        }else{
          throw Error();
        }
      }catch(e){ //저장된 아이디 없는 경우
        debugPrint("저장된 아이디 없음");
        Navigator.pushReplacementNamed(context, "/toInitialPage"); //로그인 화면
      }
    }
    );
  }

  @override
  void initState() {
    super.initState();
    _permission();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _tryAutoLogin()); //빌드 후 실행
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 173, 181),
      body: Center(
        //앱 로고 이미지
        child: Image.asset("assets/images/splash_logo.png"),
      ),
    );
  }
}