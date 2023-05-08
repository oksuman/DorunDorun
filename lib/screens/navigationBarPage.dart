/*******************************
 * 네비게이션 바가 구현된 페이지입니다. *
 *******************************/

import 'package:flutter/material.dart';
import 'homeScreens/startPage.dart';
import 'friendsScreens/friendsPage.dart';
import 'trophiesScreens/trophiesPage.dart';
import 'analysisScreens/analysisPage.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({Key? key}) : super(key: key);

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _selectedIndex = 0; //선택한 페이지 번호

  //네비게이션할 페이지 리스트
  final List<Widget> _widgetOptions = <Widget>[
    const StartPage(),
    const FriendsPage(),
    const TrophiesPage(),
    const AnalysisPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)), //선택 페이지
      bottomNavigationBar: BottomNavigationBar( //네비게이션 바
        currentIndex: _selectedIndex,
        onTap: (int i){ //네비게이션 바에서 페이지 선택
          setState((){
            _selectedIndex = i;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_sharp), label: "친구관리"),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_sharp), label: "업적"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_sharp), label: "기록"),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 238, 238, 238), //white
        selectedLabelStyle:
        const TextStyle(fontFamily: "SCDream", fontSize: 12),
        unselectedLabelStyle:
        const TextStyle(fontFamily: "SCDream", fontSize: 10),
      ),
    );
  }
}