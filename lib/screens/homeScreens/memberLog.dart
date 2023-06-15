import '../../models/group.dart';
import 'package:flutter/material.dart';

class memberLog{
  String memberName;
  List<Map<String, Object>> snapshots = List<Map<String, Object>>.empty(growable: true);

  memberLog({
    required this.memberName,
  }){
    snapshots.add({
      "runner": memberName,
      "delta_time": 0,
      "accumulated_distance": 0,
      "velocity": 0,
    });
  }

  String getRunnerName(){
    return memberName;
  }

  Map<String, Object> getLastSnapshot(){
    return snapshots.last;
  }

  List<Map<String, Object>> updateSnapshot({
    required String runner,
    required num deltaTime,
    required num distanceMoved,
    required num velocity,
  }){
    snapshots.add({
      "runner": memberName,
      "delta_time": deltaTime,
      "accumulated_distance": distanceMoved,
      "velocity": velocity,
    });
    return snapshots;
  }

  void setSnapshots(List<Map<String, Object>> snapshots){
    snapshots = snapshots;
  }
}

class membersLog{
  List<memberLog> members = List<memberLog>.empty(growable: true);

  membersLog({
    required Set<String> memberSet,
  }){
    for(var memberName in memberSet){
      members.add(
        memberLog(
          memberName: memberName,
        )
      );
    }
  }

  num getLastTime({
    required String runner,
  }){
    for(var member in members){
      if(member.getRunnerName() == runner){
        var snapshot = member.getLastSnapshot();
        return snapshot['delta_time'] as num;
      }
    }
    return 0;
  }

  void addRecentLog({
    required String runner,
    required num deltaTime,
    required num distanceMoved,
    required num velocity,
  }){
    var index=0;
    for(var member in members){
      if(member.getRunnerName() == runner){
        debugPrint("--------update----------");
        debugPrint("runner : $runner");
        debugPrint("delta Time : $deltaTime");
        debugPrint("member : $member");
        members[index].updateSnapshot(
            runner: runner,
            deltaTime: deltaTime,
            distanceMoved: distanceMoved,
            velocity: velocity
        );
        break;
      }
      index++;
    }
  }

  String displayRecentLog(){
    String debugString = '';
    for(var member in members){
      var snapshot = member.getLastSnapshot();
      // debugString += snapshot['runner'].toString();
      // debugString += '-시간 : ';
      // debugString += snapshot['delta_time'].toString();
      // debugString += '-이동거리 : ';
      //
      // debugPrint(" 여기는 display 입니다 ");
      // debugPrint(" 시간 : ${snapshot['delta_time'].toString()}");
      // debugString += snapshot['accumulated_distance'].toString();
      // debugString += '\n';
    }
    return debugString;
  }

  void debugPrintLog(){
    for(var member in members){
      debugPrint(" debug 안입니다.");
      debugPrint("member : ${member.memberName}");
      debugPrint("snapshots : ${member.snapshots}");
    }
  }

  Map<String, Object> getLastSnapshot({
    required String runner,
  }){
    late  Map<String, Object> snapshot;
    for(var member in members){
      if(member.getRunnerName() == runner){
        snapshot = member.getLastSnapshot();
      }
    }
    return snapshot;
  }
}