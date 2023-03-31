import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  bool _leftClicked = true;
  List<List<String>> _searchedList = [];
  final CollectionReference userCollection =
    FirebaseFirestore.instance.collection("users"); //파이베이스 유저 컬렉션 가져오기
  List<Map<String, dynamic>> _allUserData = [];

  _getAllUsers() async{
    QuerySnapshot querySnapshot
      = await userCollection.get();
    _allUserData
      = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  _updateNameList(String searchName) async {
    List<List<String>> tempList = [];
    for(int i=0; i<_allUserData.length; i++){ //중복 닉네임 확인
      String tempName = _allUserData[i]["fullName"];
      String tempEmail = _allUserData[i]["email"];
      String tempUid = _allUserData[i]["uid"];
      if(_checkSimilarName(tempName, searchName)){
        List<String> tempElement = [tempName, tempEmail, tempUid];
        tempList.add(tempElement);
      }
    }
    _searchedList.clear();
    _searchedList = tempList;
  }
  bool _checkSimilarName(String typed, String origin){
    int minLength = 0;
    bool isSimilar = true;
    if(typed.length>origin.length)
      minLength = origin.length;
    else
      minLength = typed.length;
    if (minLength==0){
      return false;
    }
    for(int i = 0; i<minLength; i++){
      if(typed[i]!=origin[i]){
        isSimilar = false;
      }
    }
    return isSimilar;
  }

  @override
  Widget build(BuildContext context) {
    _getAllUsers();
    return Scaffold(
      appBar: AppBar( // 앱 상단 바
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text(
          "친구 관리",
          style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        _leftClicked = true;
                      });
                    },
                    child: Text("친구 관리"),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        _leftClicked = false;
                      });
                    },
                    child: Text("친구 추가"),
                  )
                ],
              ),
              (_leftClicked)?
                  Column(
                    children: [
                      Container(
                        height: 500,
                        child: ListView.builder(
                          itemCount: 100,
                          itemBuilder: (BuildContext context, int index){
                            return Container(
                              child: Text("friend"+index.toString()),
                            );
                          },
                        ),
                      )
                    ],
                  ):
                  Column(
                    children: [
                      Form(
                        child: TextFormField(
                          onChanged: (value) async {
                            setState(() {
                              _updateNameList(value);
                            });
                          },
                          onSaved: (value) async {
                            setState(() {
                              _updateNameList(value!);
                            });
                          },
                        ),
                      ),
                      _searchedList.isEmpty
                            ? Container()
                            : Container(
                                height: 500,
                                child: ListView.builder(
                                  itemCount: _searchedList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Text(_searchedList[index][0]),
                                            Text(_searchedList[index][1]),
                                          ],
                                        ),
                                        ElevatedButton(
                                            onPressed: (){

                                            },
                                            child: Text("+")
                                        )
                                      ],
                                    );
                                  },
                                ),
                              )

                      ],
                  )
            ],
          ),
        ),
      ),
    );
  }
}
