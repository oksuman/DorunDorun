import 'package:flutter/material.dart';

class CustomizePage extends StatefulWidget {
  const CustomizePage({Key? key}) : super(key: key);

  @override
  State<CustomizePage> createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // 앱 상단 바
          elevation: 0,
          iconTheme: IconThemeData(color: Color.fromARGB(255, 238, 238, 238)), //white
          title: const Text(
            "꾸미기",
            style: TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 238, 238, 238), //white
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color.fromARGB(255, 0, 173, 181), //teal
          centerTitle: true,
        ),
        backgroundColor: Color.fromARGB(255, 238, 238, 238),

    );
  }
}
