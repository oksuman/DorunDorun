/*******************************
* 유저 정보를 입력하는 페이지입니다.   *
*******************************/

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
  final List<String> _ageList = []; //나이 스크롤 리스트
  final List<String> _heightList = []; //키 스크롤 리스트
  final List<String> _weightList = []; //체중 스크롤 리스트
  FixedExtentScrollController _ageController =
    FixedExtentScrollController(initialItem: 20-5); //나이 스크롤 컨트롤러
  FixedExtentScrollController _heightController =
    FixedExtentScrollController(initialItem: 160-100); //키 스크롤 컨트롤러
  FixedExtentScrollController _weightController =
    FixedExtentScrollController(initialItem: 60-30); //체중 스크롤 컨트롤러
  Gender _gender = Gender.MAN; //성별 라디오 버튼 선택지

  String _userName = ''; //유저 닉네임
  String _userGender = '남자'; //유저 성별
  String _userAge = '20 살'; //유저 나이
  String _userHeight = '160 cm'; //유저 키
  String _userWeight = '60 kg'; //유저 몸무게

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

  @override
  void initState() { //스크롤 리스트 초기화
    super.initState();
    for(int a = 5; a<=100; a+=1){
      _ageList.add(a.toString()+" 살");
    }
    for (int h = 100; h <= 250; h += 1) {
      _heightList.add(h.toString()+" cm");
    }
    for (int w = 30; w <= 150; w += 1) {
      _weightList.add(w.toString()+" kg");
    }
  }

  @override
  Widget build(BuildContext context) {
    UserCredential _newUser = ModalRoute.of(context)!.settings.arguments as UserCredential;

    return GestureDetector( //키보드 내리기
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar( //앱 상단 바
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          title: const Text(
            "사용자 정보 입력",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.yellow,
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 20),
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
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "닉네임:",
                          labelStyle: TextStyle(
                            fontSize: 20,
                          ),
                        )),
                    SizedBox(height: 20),
                    Column( //성별 선택 라디오버튼
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("성별:",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 20),
                        RadioListTile(
                            title: Text("남자"),
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
                            title: Text("여자"),
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
                    SizedBox(height: 20),
                    GestureDetector( //나이 선택 창
                      onTap: (){
                        _ageListSpinner(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("나이: "),
                                Text(_userAge,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green
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
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("키: "),
                                Text(_userHeight,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green
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
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("체중: "),
                                Text(_userWeight,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 1, color: Colors.grey,)
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton( //로그인 버튼
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.yellow,
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
                              Navigator.pushNamed(context, "/toNavigationBarPage"); //메인 페이지 이동
                            }catch(e){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                  "이미 존재하는 닉네임입니다.",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                backgroundColor: Colors.grey,
                              ));
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "계정 생성하기",
                              style: TextStyle(
                                color: Colors.black,
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