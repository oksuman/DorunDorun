import 'package:flutter/material.dart';

class RunSplashScreen extends StatefulWidget {
  const RunSplashScreen({Key? key}) : super(key: key);

  @override
  State<RunSplashScreen> createState() => _RunSplashScreenState();
}

class _RunSplashScreenState extends State<RunSplashScreen> with SingleTickerProviderStateMixin{

  late final AnimationController _controller;
  int _countdown = 3;
  List<Color> backGroundColor = [
    Color.fromARGB(255, 141, 221, 215),
    Color.fromARGB(255, 107, 201, 198),
    Color.fromARGB(255, 0, 173, 181),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _countdown--;
        });
        if (_countdown > 0) {
          _controller.reset();
          _controller.forward();
        }else{
          Navigator.of(context).pop();
        }

      }
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (_countdown>0)?backGroundColor[_countdown-1]:backGroundColor[0],
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Text(
            '$_countdown',
            key: ValueKey<int>(_countdown),
            style: TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 238, 238, 238),
                fontWeight: FontWeight.bold,
                fontSize: 240.0
            ),
          ),
        ),
      ),
    );
  }
}