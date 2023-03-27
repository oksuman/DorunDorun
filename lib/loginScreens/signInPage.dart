/*******************************
 * 로그인 페이지입니다.             *
 *******************************/

import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector( //키보드 숨기기
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar( // 앱 상단 바
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            title: const Text(
              "이메일로 로그인",
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.yellow,
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Form(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    TextFormField( //이메일 텍스트필드
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "이메일",
                          labelStyle: TextStyle(
                            fontSize: 16,
                          )),
                      keyboardType: TextInputType.emailAddress,
                      //validator: ,
                      //onSaved: (){},
                      //onChanged: (){},
                    ),
                    SizedBox(height: 20),
                    TextFormField( //패스워드 텍스트필드
                      obscureText: true,
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "패스워드",
                          labelStyle: TextStyle(
                            fontSize: 16,
                          )),
                      keyboardType: TextInputType.text,
                      //validator: ,
                      //onSaved: (){},
                      //onChanged: (){},
                    ),
                    SizedBox(height: 40),
                    ElevatedButton( //로그인 버튼
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.yellow,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, "/toNavigationBarPage");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "로그인",
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
