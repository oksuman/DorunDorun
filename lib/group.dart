import 'package:cloud_firestore/cloud_firestore.dart';

class Group{
  String _groupID = "";
  List<String> _members = [];
  Group(String gid){
    getGroup(gid);
  }
  getGroup(String gid) async{
    final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups"); //유저 컬렉션
    final DocumentReference groupDocument = groupCollection.doc(gid);
    final DocumentSnapshot groupSnapshot = await groupDocument.get();
    _groupID = groupSnapshot.get("groupId");
    List<dynamic> tempList = groupSnapshot.get("membersId");
    tempList.forEach((element) {
      _members.add(element.toString());
    });
  }
}