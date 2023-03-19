import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Do run Do run',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}


class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
 }

 class _HomePageState extends State<HomePage>{
  Location location = Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  @override
  void initState() {
    super.initState();
    _giveAuthority();
  }

  @override
   Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Do run! Do run!"),
      ),
      body: Center(
          child :
          FloatingActionButton(
            child: const Text("Start"),
            onPressed: () async{
              await location.getLocation().then((res){
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => RunPage(initialLocation: res)));
              });
            },
          )
      ),
    );
  }

  _giveAuthority() async{
    _serviceEnabled = await location.serviceEnabled();
    if(!_serviceEnabled){
      _serviceEnabled = await location.serviceEnabled();
      if(!_serviceEnabled){
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await location.hasPermission();
      if(_permissionGranted != PermissionStatus.granted){
        return;
      }
    }
  }
 }


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
      body : StreamBuilder<LocationData>(
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
          return Center(
           child: Text("Distance : $distanceMoved"),
          );
        }
      )
    );
  }
}



