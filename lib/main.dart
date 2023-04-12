import 'package:dorun_dorun/screens/analysisScreens/detailPage.dart';
import 'package:dorun_dorun/screens/homeScreens/makeRoomPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'utilities/firebase_options.dart';
import 'screens/friendsScreens/findFriendPage.dart';
import 'Screens/navigationBarPage.dart';
import 'Screens/homeScreens/runningPage.dart';
import 'Screens/loginScreens/makeUserPage.dart';
import 'Screens/loginScreens/signInPage.dart';
import 'Screens/loginScreens/signUpPage.dart';
import 'Screens/loginScreens/initialPage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AndroidOptions _getAndroidOptions() => const AndroidOptions( //secure storage 사용 위한 옵션 초기화
    encryptedSharedPreferences: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const InitialPage(), //시작 로그인 화면
          '/toSignInPage': (context) => const SignInPage(), //로그인 페이지 이동
          '/toSignUpPage': (context) => const SignUpPage(), //계정생성 페이지 이동
          '/toMakeUserPage': (context) => const MakeUserPage(), //유저 정보 작성 페이지 이동
          '/toNavigationBarPage': (context) => const NavigationBarPage(), //네비게이션 바 페이지 이동
          '/toMakeRoomPage': (context) => const MakeRoomPage(), //러너 방 생성 페이지 이동
          '/toFindFriendPage': (context) => const FindFriendPage(), //친구 추가 페이지 이동
          '/toDetailPage' : (context) => const DetailPage(),
        });
  }
}