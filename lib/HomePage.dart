import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:wakelock/wakelock.dart';

import 'RunPage.dart';

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
              WidgetsFlutterBinding.ensureInitialized();
              Wakelock.enable();
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