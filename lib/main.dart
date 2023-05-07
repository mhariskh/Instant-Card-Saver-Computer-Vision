import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';

import 'package:cvcardreader/pages/image_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Card Detection',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initialized");
      return '';
    }

    // Formatting Date and Time
    String dateTime = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    // Using date and time to name the file
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String visionDir = '${appDocDir.path}/Photos/Vision Images';
    await Directory(visionDir).create(recursive: true);
    final String imagePath = '$visionDir/image_$dateTime.jpg';

    if (_controller.value.isTakingPicture) {
      print("Processing in progress...");
      return '';
    }

    try {
      XFile pictureFile = await _controller.takePicture();
      await pictureFile.saveTo(imagePath);
    } on CameraException catch (e) {
      print("Camera Exception: $e");
      return '';
    }

    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Detection'),
      ),
      body: _controller.value.isInitialized
          ? Stack(
              children: <Widget>[
                CameraPreview(_controller),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.camera),
                      label: Text("Scan"),
                      onPressed: () async {
                        final path = await _takePicture();
                        if (path.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(path),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                )
              ],
            )
          : Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
