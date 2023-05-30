import 'package:flutter/material.dart';

/**********************************
 * 그룹의 정보를 가지고 있는 클래스입니다. *
 **********************************/

class Group{
  //그룹 필드
  String _groupState = "";
  String _groupId = "";
  String _adminId = "";
  String _adminName = "";
  List<String> _membersId = [];
  List<String> _membersName = [];

  String _groupMode = ""; //기본모드, 협동모드, 경쟁모드

  String _basicSetting = ""; //기본모드 -> 목표거리, 목표시간, 스피드
  Map<String, double> _basicGoal = {"거리":5.0, "시간":30}; // -> 목표거리, 목표시간

  String _coopSetting = "";

  String _compSetting = "";
  Map<String, double> _compGoal = {"거리":5.0, "페이스":10};

  Map<String, String> _membersAvatar = {};
  Map<String, bool> _membersReady = {};



  //그룹 GetSet
  setGroupId(String gid){
    _groupId = gid;
  }
  setGroupState(String gstate){
    _groupState = gstate;
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
  setMembersAvatar(Map<String, dynamic> memAvatar){
    _membersAvatar.clear();
    _membersAvatar.forEach((key, value) {
      _membersAvatar[key] = value.toString();
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
  setCoopSetting(String copsetting){
    _coopSetting=copsetting;
  }
  setCompSetting(String cmpsetting){
    _compSetting=cmpsetting;
  }
  setCompGoal(Map<String, dynamic> cmpgoal){
    _compGoal.clear();
    cmpgoal.forEach((key, value) {
      _compGoal[key] = double.parse(value.toString());
    });
  }

  int getMembersNum(){
    return _membersId.length;
  }

  String getGroupState(){
    return _groupState;
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
  Map<String, String> getMembersAvatar(){
    return _membersAvatar;
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
  String getCoopSetting(){
    return _coopSetting;
  }
  double getCoopGoal(int opt){
    switch(_coopSetting){
      case "1단계":
        return (opt==0)?10:15;
      case "2단계":
        return (opt==0)?15:12;
      case "3단계":
        return (opt==0)?20:10;
      default:
        return 0;
    }
  }
  String getCompSetting(){
    return _compSetting;
  }
  Map<String, double> getCompGoal(){
    return _compGoal;
  }

}