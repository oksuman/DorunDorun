/*******************************
 * 유저 정보를 입력하는 페이지입니다.   *
 *******************************/

import 'package:dorun_dorun/utilities/storageService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utilities/firebaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender {MAN, WOMAN}

class MakeUserPage extends StatefulWidget {
  const MakeUserPage({Key? key}) : super(key: key);

  @override
  State<MakeUserPage> createState() => _MakeUserPageState();
}

class _MakeUserPageState extends State<MakeUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _authentication = FirebaseAuth.instance;
  final List<String> _ageList = []; //나이 스크롤 리스트
  final List<String> _heightList = []; //키 스크롤 리스트
  final List<String> _weightList = []; //체중 스크롤 리스트
  final FixedExtentScrollController _ageController =
  FixedExtentScrollController(initialItem: 20-5); //나이 스크롤 컨트롤러
  final FixedExtentScrollController _heightController =
  FixedExtentScrollController(initialItem: 160-100); //키 스크롤 컨트롤러
  final FixedExtentScrollController _weightController =
  FixedExtentScrollController(initialItem: 60-30); //체중 스크롤 컨트롤러
  Gender _gender = Gender.MAN; //성별 라디오 버튼 선택지

  String _userName = ''; //유저 닉네임
  String _userGender = '남자'; //유저 성별
  String _userAge = '입력안함'; //유저 나이
  String _userHeight = '입력안함'; //유저 키
  String _userWeight = '입력안함'; //유저 몸무게
  bool _switchCheck = false;
  bool _privacyCheck = false;

  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users"); //파이베이스 유저 컬렉션 가져오기

  bool _tryValidation() { //계정 생성 형식 확인
    final isValid = _formKey.currentState!.validate();
    if (isValid) { //형식이 맞으면,
      _formKey.currentState!.save();
      return true;
    }
    return false;
  }
  _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("개인정보 이용 동의"),
          content: const Text("입력하신 모든 정보는 개인정보 보호법에 의해 보호됩니다. "
              "수집된 신체정보는 서비스 이용에 따른 정밀한 운동 피드백을 위한 목적으로 이용됩니다. "
              "이에 동의하시겠습니까?"),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0
              ),
              child: const Text("취소"),
              onPressed: (){
                setState(() {
                  _switchCheck = false;
                  _privacyCheck = false;
                });
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0
              ),
              child: const Text("동의"),
              onPressed: () {
                setState(() {
                  _switchCheck = true;
                  _privacyCheck = true;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  void _showNameAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("닉네임 중복"),
          content: const Text("이미 존재하는 닉네임 입니다."),
          actions: [
            CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }
  @override
  void initState() { //스크롤 리스트 초기화
    super.initState();
    for(int a = 5; a<=100; a+=1){
      _ageList.add("${a.toString()} 살");
    }
    for (int h = 100; h <= 250; h += 1) {
      _heightList.add("${h.toString()} cm");
    }
    for (int w = 30; w <= 150; w += 1) {
      _weightList.add("${w.toString()} kg");
    }
  }
  @override
  Widget build(BuildContext context) {
    UserCredential _newUser = ModalRoute.of(context)!.settings.arguments as UserCredential; //argument 받아오기

    return GestureDetector( //키보드 내리기
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar( //앱 상단 바
          elevation: 0,
          //iconTheme: IconThemeData(color: Color.fromARGB(255, 238, 238, 238),), //white
          leading: IconButton(
            onPressed: () async{
              try{
                final currentUser = _authentication.currentUser;
                await currentUser?.delete();
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
            "사용자 정보 입력",
            style: TextStyle(
                fontFamily: "SCDream",
                color: Color.fromARGB(255, 238, 238, 238), //white
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 173, 181), //teal
          centerTitle: true,
        ),
        backgroundColor: const Color.fromARGB(255, 238, 238, 238), //white
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextFormField( //닉네임 입력창
                        validator: ((value) {
                          if (value!.isEmpty || value.length < 3) {
                            return "닉네임은 최소 3글자 이상이야 합니다.";
                          }
                          return null;
                        }),
                        onSaved: ((value) {
                          _userName = value!;
                        }),
                        onChanged: (value) {
                          _userName = value;
                        },
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "닉네임:",
                          labelStyle: TextStyle(
                            fontFamily: "SCDream",
                            fontSize: 20,
                            color: Color.fromARGB(255, 57, 62, 70), //grey
                          ),
                        )),
                    const SizedBox(height: 20),
                    Column( //성별 선택 라디오버튼
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("성별:",
                          style: TextStyle(
                            fontFamily: "SCDream",
                            fontSize: 16,
                            color: Color.fromARGB(255, 57, 62, 70), //grey
                          ),
                        ),
                        SizedBox(height: 20),
                        RadioListTile(
                            title: const Text("남자",
                              style: TextStyle(
                                fontFamily: "SCDream",
                                fontSize: 14,
                                color: Color.fromARGB(255, 34, 40, 49), //black
                              ),),
                            value: Gender.MAN,
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                                _userGender = "남자";
                              });
                            }
                        ),
                        RadioListTile(
                            title: const Text("여자",
                              style: TextStyle(
                                fontFamily: "SCDream",
                                fontSize: 14,
                                color: Color.fromARGB(255, 34, 40, 49), //black
                              ),
                            ),
                            value: Gender.WOMAN,
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                                _userGender = "여자";
                              });
                            }
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("신체정보:",
                          style: TextStyle(
                            fontFamily: "SCDream",
                            fontSize: 16,
                            color: Color.fromARGB(255, 57, 62, 70), //grey
                          ),
                        ),
                        Switch(
                            value: _switchCheck,
                            onChanged: (value){
                              if(_privacyCheck){
                                setState((){
                                  _switchCheck = value;
                                });
                              }
                              else{
                                if(!_switchCheck && !_privacyCheck)
                                  _showPrivacyDialog();
                                setState(() {
                                  if(value){
                                    _userAge = '20 살'; //유저 나이
                                    _userHeight = '160 cm'; //유저 키
                                    _userWeight = '60 kg'; //유저 몸무게
                                  }else{
                                    _userAge = "입력안함";
                                    _userWeight = "입력안함";
                                    _userHeight = "입력안함";
                                  }
                                  //_switchCheck = value;
                                });
                              }
                            }
                        )
                      ],
                    ),
                    _switchCheck?Column(
                      children: [
                        const SizedBox(height: 20),
                        GestureDetector( //나이 선택 창
                          onTap: (){
                            _ageListSpinner(context);
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 40,
                                color: const Color.fromARGB(255, 238, 238, 238), //white
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("나이: ",
                                      style: TextStyle(
                                        fontFamily: "SCDream",
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 57, 62, 70), //grey
                                      ),
                                    ),
                                    Text(_userAge,
                                      style: const TextStyle(
                                        fontFamily: "SCDream",
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 173, 181), //teal
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(height: 1, color: Colors.grey,)
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector( //키 선택 창
                          onTap: (){
                            _heightListSpinner(context);
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 40,
                                color: Color.fromARGB(255, 238, 238, 238), //white
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("키: ",
                                      style: TextStyle(
                                        fontFamily: "SCDream",
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 57, 62, 70), //grey
                                      ),),
                                    Text(_userHeight,
                                      style:const TextStyle(
                                        fontFamily: "SCDream",
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 173, 181), //teal
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(height: 1, color: Colors.grey,)
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector( //체중 선택 창
                          onTap: (){
                            _weightListSpinner(context);
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 40,
                                color: Color.fromARGB(255, 238, 238, 238), //white
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("체중: ",
                                      style: TextStyle(
                                        fontFamily: "SCDream",
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 57, 62, 70), //grey
                                      ),),
                                    Text(_userWeight,
                                      style: const TextStyle(
                                        fontFamily: "SCDream",
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 173, 181), //teal
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(height: 1, color: Colors.grey,)
                            ],
                          ),
                        ),
                      ],
                    ):
                    Container(),
                    const SizedBox(height: 40),
                    ElevatedButton( //로그인 버튼
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: Color.fromARGB(255, 0, 173, 181), //teal
                          elevation: 0,
                        ),
                        onPressed: () async{
                          FocusScope.of(context).unfocus();
                          QuerySnapshot querySnapshot
                          = await userCollection.get();
                          List<Map<String, dynamic>> allUserData
                          = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
                          if(_tryValidation()){ //닉네임 형식 확인
                            try{
                              for(int i=0; i<allUserData.length; i++){ //중복 닉네임 확인
                                if(allUserData[i]["fullName"] == _userName){
                                  throw Error();
                                }
                              }
                              await FirebaseService(uid: _newUser.user!.uid) //유저 정보 파이어베이스 업로드
                                  .savingUserData(
                                _newUser.user!.email!,
                                _userName,
                                _userGender,
                                _userAge,
                                _userHeight,
                                _userWeight,
                              );
                              await StorageService().saveUserLoggedInStatus("true"); //스토리지에 로그인 정보 저장
                              await StorageService().saveUserName(_userName); //스토리지에 닉네임 저장
                              await StorageService().saveUserEmail(_newUser.user!.email!); //스토리지에 이메일 저장
                              await StorageService().saveUserID(_newUser.user!.uid); //스토리지에 파이어베이스 id 저장
                              await StorageService().saveUserGroup(""); //스토리지에 joined group 저장
                              Navigator.pushNamedAndRemoveUntil(context, '/toNavigationBarPage', (route) => false); //로그인
                            }catch(e){
                              _showNameAlert();
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Text(
                              "계정 생성하기",
                              style: TextStyle(
                                color: Color.fromARGB(255, 238, 238, 238), //white
                                fontFamily: "SCDream",
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  _ageListSpinner(BuildContext context) { //나이 스크롤 위젯
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              height: 300,
              color: Colors.white,
              child: CupertinoPicker.builder(
                itemExtent: 50,
                scrollController: _ageController,
                childCount: _ageList.length,
                onSelectedItemChanged: (i) {
                  setState(() {
                    _userAge = _ageList[i];
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          _ageList[index]
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
  _heightListSpinner(BuildContext context) { //키 스크롤 위젯
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              height: 300,
              color: Colors.white,
              child: CupertinoPicker.builder(
                itemExtent: 50,
                scrollController: _heightController,
                childCount: _heightList.length,
                onSelectedItemChanged: (i) {
                  setState(() {
                    _userHeight = _heightList[i];
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          _heightList[index]
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
  _weightListSpinner(BuildContext context) { //체중 스크롤 위젯
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              height: 300,
              color: Colors.white,
              child: CupertinoPicker.builder(
                itemExtent: 50,
                scrollController: _weightController,
                childCount: _weightList.length,
                onSelectedItemChanged: (i) {
                  setState(() {
                    _userWeight = _weightList[i];
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          _weightList[index]
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}