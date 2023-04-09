/*******************************
 * 계정을 생성할 수 있는 페이지 입니다. *
 *******************************/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _authentication = FirebaseAuth.instance;
  String _userEmail = ''; //유저 이메일 정보
  String _userPassword = ''; //유저 패스워드 정보
  String _passwordCheck = ''; //유저 패스워드 확인 정보

  bool _tryValidation() { //계정 생성 형식 확인
    final isValid = _formKey.currentState!.validate();
    if (isValid) { //형식이 맞으면,
      _formKey.currentState!.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( //키보드 가리기
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar( //앱 상단 바
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            title: const Text(
              "계정 생성",
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.yellow,
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    TextFormField( //이메일 텍스트필드
                      keyboardType: TextInputType.emailAddress,
                      onSaved: ((value) {
                        _userEmail = value!;
                      }),
                      onChanged: (value) {
                        _userEmail = value;
                      },
                      validator: ((value) {
                        if (value!.isEmpty || !value.contains('@')) { //이메일 형식이 맞지 않으면,
                          return "유효하지 않은 이메일 형식입니다.";
                        }
                        return null;
                      }),
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "이메일",
                          labelStyle: TextStyle(
                            fontSize: 16,
                          )
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField( //패스워드 텍스트필드
                      obscureText: true,
                      validator: ((value) {
                        if (value!.isEmpty || value.length < 8) { //패스워드가 8자 미만이라면,
                          return "패스워드는 최소 8글자 이상 입력해야 합니다.";
                        }
                        return null;
                      }),
                      onSaved: ((value) {
                        _userPassword = value!;
                      }),
                      onChanged: (value) {
                        _userPassword = value;
                      },
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "패스워드",
                          labelStyle: TextStyle(
                            fontSize: 16,
                          )),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 20),
                    TextFormField( //패스워드 확인 텍스트필드
                      obscureText: true,
                      validator: ((value) {
                        if (value != _userPassword) { //패스워드와 같지 않으면,
                          return "패스워드가 일치하지 않습니다.";
                        }
                        return null;
                      }),
                      onSaved: ((value) {
                        _passwordCheck = value!;
                      }),
                      onChanged: (value) {
                        _passwordCheck = value;
                      },
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "패스워드 확인",
                          labelStyle: TextStyle(
                            fontSize: 16,
                          )),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 40),
                    ElevatedButton( //계정 생성 버튼
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.yellow,
                        ),
                        onPressed: () async{
                          FocusScope.of(context).unfocus();
                          if(_tryValidation()){ //형식 확인
                            try{
                              final newUser = await _authentication
                                  .createUserWithEmailAndPassword(
                                  email: _userEmail, password: _userPassword); //파이어베이스 계정 확인
                              if(newUser.user != null){ //계정 있으면 이동
                                Navigator.pushNamed(context, "/toMakeUserPage", arguments: newUser); //유저 정보를 입력페이지로 전달
                              }
                            }catch(e){ //에러 메시지
                              debugPrint("errs");
                              debugPrint("$e");
                              debugPrint("erre");
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                  "이미 존재하는 이메일이거나 유효하지 않은 형식입니다.",
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
                              "다 음",
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
          )),
    );
  }
}

