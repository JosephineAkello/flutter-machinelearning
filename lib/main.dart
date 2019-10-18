import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mlkit/mlkit.dart';
import 'dart:async';

void main() => runApp(new  MLflutter());

class  MLflutter extends StatefulWidget {
  @override
   MLflutterState createState() => new MLflutterState();
}

class  MLflutterState extends State< MLflutter> {
  File _file;

  List<VisionFace> _face = <VisionFace>[];

  VisionFaceDetectorOptions options = new VisionFaceDetectorOptions(
      modeType: VisionFaceDetectorMode.Accurate,
      landmarkType: VisionFaceDetectorLandmark.All,
      classificationType: VisionFaceDetectorClassification.All,
      minFaceSize: 0.15,
      isTrackingEnabled: true);

  FirebaseVisionFaceDetector detector = FirebaseVisionFaceDetector.instance;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        accentColor: Colors.pink[50],),
      home:  Scaffold(
        appBar: AppBar(
          title: Text('Flutter Face Detection'),
        ),
        body: showBody(_file),
        floatingActionButton: new FloatingActionButton(
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
          child: new Icon(Icons.file_upload),
        ),
      ),
    );
  }

  Widget showBody(File file) {
    return new Container(
      child: new Stack(
        children: <Widget>[
          _buildImage(),
          _showDetails(_face),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return new SizedBox(
      height: 500.0,
      child: new Center(
        child: _file == null
            ? new Text('Choose an image from the FAB Button')
            : new FutureBuilder<Size>(
                future: _getImageSize(Image.file(_file, fit: BoxFit.fitWidth)),
                builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        foregroundDecoration:
                            TextDetectDecoration(_face, snapshot.data),
                        child: Image.file(_file, fit: BoxFit.fitWidth));
                  } else {
                    return new Text('Loading please wait...');
                  }
                },
              ),
      ),
    );
  }
}

class TextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionFace> _texts;
  TextDetectDecoration(List<VisionFace> texts, Size originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return new _TextDetectPainter(_texts, _originalImageSize);
  }
}

Future _getImageSize(Image image) {
  Completer<Size> completer = new Completer<Size>();
  image.image.resolve(new ImageConfiguration())
  .addListener(ImageStreamListener(
      (ImageInfo info, bool _) => completer.complete(
          Size(info.image.width.toDouble(), info.image.height.toDouble()))));
  return completer.future;
}

Widget _showDetails(List<VisionFace> faceList) {
  if (faceList == null || faceList.length == 0) {
    return new Text('', textAlign: TextAlign.center);
  }
  return new Container(
    color: Colors.white12,
    child: new ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: faceList.length,
      itemBuilder: (context, i) {
        checkData(faceList);
        return _buildRow(
            faceList[0].hasLeftEyeOpenProbability,
            faceList[0].headEulerAngleY,//indicates rotation of face towards vertical axis of the image
            faceList[0].headEulerAngleZ,
            faceList[0].leftEyeOpenProbability,
            faceList[0].rightEyeOpenProbability,
            faceList[0].smilingProbability,
            faceList[0].trackingID);
      },
    ),
  );
}

//Checks and prints various variables from firebase
void checkData(List<VisionFace> faceList) {
  final double uncomputedProb = -1.0;
  final int uncompProb = -1;

  for (int i = 0; i < faceList.length; i++) {
    Rect bounds = faceList[i].rect;
    print('Rectangle : $bounds');

    VisionFaceLandmark landmark =
        faceList[i].getLandmark(FaceLandmarkType.LeftEar);

    if (landmark != null) {
      VisionPoint leftEarPos = landmark.position;
      print('Left Ear Pos : $leftEarPos');
    }

    if (faceList[i].smilingProbability != uncomputedProb) {
      double smileProb = faceList[i].smilingProbability;
      print('Smile Prob : $smileProb');
    }

    if (faceList[i].rightEyeOpenProbability != uncomputedProb) {
      double rightEyeOpenProb = faceList[i].rightEyeOpenProbability;
      print('RightEye Open Prob : $rightEyeOpenProb');
    }

    if (faceList[i].trackingID != uncompProb) {
      int tID = faceList[i].trackingID;
      print('Tracking ID : $tID');
    }
  }
}

Widget _buildRow(
    bool leftEyeProb,
    double headEulerY,
    double headEulerZ,
    double leftEyeOpenProbability,
    double rightEyeOpenProbability,
    double smileProb,
    int tID) {
  return ListTile(
    title: new Text(
      "\nLeftEyeProb: $leftEyeProb \nHeadEulerY : $headEulerY \nHeadEulerZ : $headEulerZ \nLeftEyeOpenProbability : $leftEyeOpenProbability \nRightEyeOpenProbability : $rightEyeOpenProbability \nSmileProb : $smileProb \nFaceTrackingEnabled : $tID",
    ),
    dense: true,
  );
}

class _TextDetectPainter extends BoxPainter {
  final List<VisionFace> _faceLabels;
  final Size _originalImageSize;
  _TextDetectPainter(faceLabels, originalImageSize)
      : _faceLabels = faceLabels,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = new Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var faceLabel in _faceLabels) {
      final _rect = Rect.fromLTRB(
          offset.dx + faceLabel.rect.left / _widthRatio,
          offset.dy + faceLabel.rect.top / _heightRatio,
          offset.dx + faceLabel.rect.right / _widthRatio,
          offset.dy + faceLabel.rect.bottom / _heightRatio);

      canvas.drawRect(_rect, paint);
    }
  }
}
