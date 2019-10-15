import 'package:flutter/material.dart';
import 'package:mlkit/mlkit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MLflutter());
}

class MLflutter extends StatefulWidget {
  createState() {
    return MLflutterState();
  }
}

class MLflutterState extends State<MLflutter> {
  File _file;
  List<VisionFace> _face = <VisionFace>[];

  VisionFaceDetectorOptions options = VisionFaceDetectorOptions(
    modeType: VisionFaceDetectorMode.Accurate,
    landmarkType: VisionFaceDetectorLandmark.All,
    classificationType: VisionFaceDetectorClassification.All,
    minFaceSize: 0.15,
    isTrackingEnabled: true,
  );

  FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;

  @override
  initState() {
    super.initState();
  }

  Widget build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(primaryColor: Colors.red, accentColor: Colors.tealAccent),
      title: 'Flutter + ML',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter + ML'),
        ),
        body: showBody(_file),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var file = await ImagePicker.pickImage(source: ImageSource.gallery);
            setState(() {
              _file = file;
            });
            var face = await detector.detectFromBinary(
                _file?.readAsBytesSync(), options);
            setState(() {
              if (face.isEmpty) {
                print('No face detected');
              } else {
                _face = face;
              }
            });
          },
          child: new Icon(Icons.tag_faces),
        ),
      ),
    );
  }

  Widget showBody(File file) {
    return Container();
  }
}
