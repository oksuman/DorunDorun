import 'package:flutter/material.dart';

import '../../utilities/firebaseService.dart';
import '../../utilities/storageService.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _uid = "";
  bool _insideCheck = false;

  _getMyData() async {
    await StorageService().getUserID().then((value) {
      setState(() {
        _uid = value!;
      });
    });
  }

  _setInsideCheck() async{
    await _getMyData();
    _insideCheck = await FirebaseService(uid: _uid)
        .getInsideCheck();
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    _setInsideCheck();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 앱 상단 바
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 238, 238, 238)), //white
        leading: IconButton(
          onPressed: () async{
            try{
              await FirebaseService(uid: _uid)
                  .setInsideCheck(_insideCheck);
              Navigator.pop(context);
            }catch(e){
              debugPrint("errs");
              debugPrint("$e");
              debugPrint("erre");
            }

          },
          icon: const Icon(Icons.arrow_back),
          color: const Color.fromARGB(255, 238, 238, 238),
        ),
        title: const Text(
          "세팅",
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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("러닝머신:",
                style: TextStyle(
                  fontFamily: "SCDream",
                  fontSize: 16,
                  color: Color.fromARGB(255, 57, 62, 70), //grey
                ),
              ),
              Switch(
                  value: _insideCheck,
                  onChanged: (value){
                    setState((){
                      _insideCheck = value;
                    });
                  }
              )
            ],
          ),
        ],
      ),

    );
  }
}
