import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class RunResultPage extends StatefulWidget {
  final List<LatLng> runResult;
  const RunResultPage({super.key, required this.runResult});

  @override
  State<RunResultPage> createState() => _RunResultPageState();
}

class _RunResultPageState extends State<RunResultPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(
      //     title: const Text("Do run! Do run!")
      // ),
      // body: ,

    );
  }
}