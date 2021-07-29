import 'dart:io';

import 'package:camera/camera.dart';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class Camera extends StatefulWidget {
  Camera(this.camera);

  final camera;

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  XFile? imageFile;
  late Future<void> _initializeControllerFuture;

  PictureController awesomeController = PictureController();

  @override
  void initState() {
    super.initState();

    controller = CameraController(widget.camera, ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.yuv420, enableAudio: false);

    _initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return Column(
            children: [
              Expanded(
                // child: CameraPreview(controller),
                child: CameraAwesome(
                  sensor: ValueNotifier(Sensors.BACK),
                  photoSize: ValueNotifier(Size(500, 500)),
                  captureMode: ValueNotifier(CaptureModes.PHOTO),
                ),
              ),
              CupertinoButton(
                child: Text('Shoot'),
                onPressed: () async {
                  final Directory extDir = await getTemporaryDirectory();
                  final testDir = await Directory('${extDir.path}/test')
                      .create(recursive: true);
                  final String filePath =
                      '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                  await awesomeController.takePicture(filePath);
                  // try {
                  //   // Ensure that the camera is initialized.
                  //   await _initializeControllerFuture;

                  // Attempt to take a picture and get the file `image`
                  // where it was saved.
                  final image = File(filePath);
                  final InputImage inputImage = InputImage.fromFile(image);
                  final TextDetector textDetector =
                      GoogleMlKit.vision.textDetector();
                  final RecognisedText recognisedText =
                      await textDetector.processImage(inputImage);

                  print(recognisedText.text);
                  // } catch (e) {
                  //   // If an error occurs, log the error to the console.
                  //   print(e);
                  // }
                },
              ),
            ],
          );
        }
        // Otherwise, display a loading indicator.
        return Container();
      },
    );
  }
}
