/*******************************
 * 계정을 생성할 수 있는 페이지 입니다. *
 *******************************/

import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    TextFormField( //닉네임 텍스트필드
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "닉네임",
                          labelStyle: TextStyle(
                            fontSize: 16,
                          )),
                      keyboardType: TextInputType.text,
                      //validator: ,
                      //onSaved: (){},
                      //onChanged: (){},
                    ),
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
                    SizedBox(height: 20),
                    TextFormField( //패스워드 확인 텍스트필드
                      obscureText: true,
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "패스워드 확인",
                          labelStyle: TextStyle(
                            fontSize: 16,
                          )),
                      keyboardType: TextInputType.text,
                      //validator: ,
                      //onSaved: (){},
                      //onChanged: (){},
                    ),
                    SizedBox(height: 40),
                    ElevatedButton( //계정 생성 버튼
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.yellow,
                        ),
                        onPressed: () {
                          //Navigator.pushNamed(context, "/");
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
          )),
    );
  }
}
