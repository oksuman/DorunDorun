import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import '../homeScreens/runResultPage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wakelock/wakelock.dart';
import '../homeScreens/RunningSetting.dart';
import '../analysisScreens/dataFormat.dart';
import '../../models/group.dart';

class GhostRunPage extends StatefulWidget {
  const GhostRunPage({Key? key}) : super(key: key);

  @override
  State<GhostRunPage> createState() => _GhostRunPageState();
}

class _GhostRunPageState extends State<GhostRunPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
