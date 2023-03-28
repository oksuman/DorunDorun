import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

import 'RunResultPage.dart';

class RunPage extends StatefulWidget{
  final LocationData initialLocation;

  const RunPage({super.key, required this.initialLocation});

  @override
  State<RunPage> createState() => _RunPageState();
}

class _RunPageState extends State<RunPage>{
  Location location = Location();
  Distance distance = const Distance();

  double distanceMoved = 0;
  List<LatLng> pathMoved = List<LatLng>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    pathMoved.add(LatLng(widget.initialLocation.latitude!, widget.initialLocation.longitude!));
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
            title: const Text("Do run! Do run!")
        ),
        body : Column(
          children: <Widget>[
            StreamBuilder<LocationData>(
                initialData: widget.initialLocation,
                stream: location.onLocationChanged,
                builder: (context, snapshot){

                  debugPrint("데이터 왔수다");
                  final changedLocation = snapshot.data;
                  debugPrint("Accuracy : ${changedLocation?.accuracy}");

                  final previousLatitude = pathMoved.last.latitude;
                  final previousLongitude = pathMoved.last.longitude;

                  final currentLatitude = changedLocation?.latitude ?? previousLatitude;
                  final currentLongitude = changedLocation?.longitude ?? previousLongitude;
                  final currentSpeed = changedLocation?.speed ?? 0;

                  debugPrint("previousLatitude : $previousLatitude");
                  debugPrint("previousLongitude : $previousLongitude");
                  debugPrint("currentLatitude : $currentLatitude");
                  debugPrint("currentLongitude : $currentLongitude");
                  debugPrint("path : $pathMoved");

                  if(currentLatitude != previousLatitude && currentLongitude != previousLongitude){
                    final cur = LatLng(currentLatitude, currentLongitude);
                    final distanceDelta = distance.as(const LengthUnit(1.0), cur, pathMoved.last);
                    if(distanceDelta > 10 && (changedLocation?.accuracy ?? 0) > 20){
                      distanceMoved += distanceDelta;
                      pathMoved.add(cur);
                    }
                    debugPrint("distanceDelta : $distanceDelta");
                  }
                  return Container(
                    child: Center(
                      child: Column(
                        children: [
                          Text("Distance : $distanceMoved"),
                          Text("Speed : $currentSpeed"),
                        ],
                      ),
                    ),
                  );
                }
            ),
            FloatingActionButton(
              child: const Text("Exit"),
              onPressed: (){
                Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => RunResultPage(runResult : pathMoved)));
              },
            ),
          ],
        )
    );
  }
}