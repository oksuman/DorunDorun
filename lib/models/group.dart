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

  String _groupMode = "";
  String _basicSetting = "";
  Map<String, double> _basicGoal = {"거리":5.0, "시간":30};
  Map<String, bool> _membersReady = {};


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
  setMembersReady(Map<String, dynamic> memReady){
    _membersReady.clear();
    memReady.forEach((key, value) {
      if(value.toString()=="true")
        _membersReady[key] = true;
      else
        _membersReady[key] = false;
    });
  }
  setReady(String uid, bool isready){
    _membersReady[uid] = isready;
  }
  setGroupMode(String gmode){
    _groupMode=gmode;
  }
  setBasicSetting(String bsetting){
    _basicSetting=bsetting;
  }
  setBasicGoal(Map<String, dynamic> bgoal){
    _basicGoal.clear();
    bgoal.forEach((key, value) {
      _basicGoal[key] = double.parse(value.toString());
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
  Map<String, bool> getMembersReady(){
    return _membersReady;
  }
  bool getReady(String uid){
    if(_membersReady[uid]!=null){
      return _membersReady[uid]!;
    }else{
      return false;
    }
  }
  String getGroupMode(){
    return _groupMode;
  }
  String getBasicSetting(){
    return _basicSetting;
  }
  Map<String, double> getBasicGoal(){
    return _basicGoal;
  }

}