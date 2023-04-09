/**********************************
 * 그룹의 정보를 가지고 있는 클래스입니다. *
 **********************************/

class Group{
  //그룹 필드
  String _groupId = "";
  String _adminId = "";
  String _adminName = "";
  List<String> _membersId = [];
  List<String> _membersName = [];

  //그룹 GetSet
  setGroupId(String gid){
    _groupId = gid;
  }

  setAdminId(String aid){
    _adminId = aid;
  }

  setAdminName(String aname){
    _adminName = aname;
  }
  setMembersId(List<dynamic> midList){
    _membersId.clear();
    midList.forEach((element) {
      _membersId.add(element.toString());
    });
  }
  setMembersName(List<dynamic> mnameList){
    _membersName.clear();
    mnameList.forEach((element) {
      _membersName.add(element.toString());
    });
  }

  int getMembersNum(){
    return _membersId.length;
  }

  String getGroupId(){
    return _groupId;
  }
  String getAdminId(){
    return _adminId;
  }
  String getAdminName(){
    return _adminName;
  }
  List<String> getMembersId(){
    return _membersId;
  }
  List<String> getMembersName(){
    return _membersName;
  }
}