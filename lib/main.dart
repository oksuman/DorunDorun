import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utilities/firebase_options.dart';


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
          '/toRunningPage': (context) => const RunningPage(), //러닝 페이지 이동
        });
  }
}