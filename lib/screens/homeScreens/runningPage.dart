/*************************************
 * 러닝을 진행하면서 보게 되는 페이지 입니다.  *
 *************************************/

//여기에 추가하면 유니티, 기록, 음성 부분 들어가면 될 듯

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'runResultPage.dart';

class RunningPage extends StatefulWidget {
  const RunningPage({Key? key}) : super(key: key);

  @override
  State<RunningPage> createState() => _RunningPageState();
}

class _RunningPageState extends State<RunningPage> {
  Location location = Location();

  Distance distance = const Distance();
  Map<String, int> currentPace = {
    'min': 0,
    'sec': 0,
  };
  double distanceMoved = 0;
  int hundredMeterCounter = 0;

  bool isMocked = false;
  List<LatLng> pathMoved = List<LatLng>.empty(growable: true);
  List<Map<String, Object>> records =
  List<Map<String, Object>>.empty(growable: true);


  @override
  Widget build(BuildContext context) {
    final LocationData initialLocation = ModalRoute.of(context)!.settings.arguments as LocationData;
    pathMoved.add(LatLng(
        initialLocation.latitude!, initialLocation.longitude!));
    records.add({
      'index': hundredMeterCounter,
      'time': initialLocation.time!,
      'speed': initialLocation.speed!,
      'distanceMoved': distanceMoved,
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Do run! Do run!")),
      body: StreamBuilder<LocationData>(
          initialData: initialLocation,
          stream: location.onLocationChanged,
          builder: (context, snapshot) {
            debugPrint("데이터 왔수다");
            final changedLocation = snapshot.data;
            debugPrint("Accuracy : ${changedLocation?.accuracy}");

            final previousLatitude = pathMoved.last.latitude;
            final previousLongitude = pathMoved.last.longitude;

            final currentLatitude =
                changedLocation?.latitude ?? previousLatitude;
            final currentLongitude =
                changedLocation?.longitude ?? previousLongitude;
            final currentSpeed = changedLocation?.speed ?? 0;
            final currentTime = changedLocation?.time ?? 0;

            var dt = DateTime.fromMillisecondsSinceEpoch(currentTime.toInt());

            debugPrint("previousLatitude : $previousLatitude");
            debugPrint("previousLongitude : $previousLongitude");
            debugPrint("currentLatitude : $currentLatitude");
            debugPrint("currentLongitude : $currentLongitude");
            debugPrint("path : $pathMoved");

            if (currentLatitude != previousLatitude &&
                currentLongitude != previousLongitude) {
              final cur = LatLng(currentLatitude, currentLongitude);
              final distanceDelta =
              distance.as(const LengthUnit(1.0), cur, pathMoved.last);
              if ((changedLocation?.accuracy ?? 0) > 20) {
                distanceMoved += distanceDelta;
                pathMoved.add(cur);
                // if (distanceMoved >= 100 * (hundredMeterCounter + 1)) {
                //   var previousTime = records[hundredMeterCounter]['time'];
                //
                //   hundredMeterCounter += 1;
                //   records.add({
                //     'index': hundredMeterCounter,
                //     'time': currentTime,
                //     'speed': currentSpeed,
                //     'distanceMoved': distanceMoved,
                //   });
                //   if (previousTime is num) {
                //     var deltaSeconds =
                //     ((currentTime - previousTime) * 1000).toInt();
                //     currentPace['min'] = deltaSeconds * 10 ~/ 60;
                //     currentPace['sec'] = deltaSeconds * 10 % 60;
                //   }
                // }
              }
              debugPrint("distanceDelta : $distanceDelta");
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 80,
                    width: 200,
                    child: Text(
                        "움직인 거리 : ${distanceMoved.toStringAsFixed(2)} meter"),
                  ),
                  Container(
                    height: 80,
                    width: 200,
                    child: Text(
                        "순간 속도 : ${currentSpeed.toStringAsFixed(2)} m/s"),
                  ),
                  Container(
                    height: 80,
                    width: 200,
                    child: Text(
                        "평균 페이스 : 아직띠"),
                  ),
                  Container(
                    height: 80,
                    width: 200,
                    child: Text("시간 : $dt "),
                  ),
                  FloatingActionButton(
                    child: const Text("Exit"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              RunResultPage(runResult: pathMoved)));
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }
}
