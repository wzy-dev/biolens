import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  CameraDescription cameras = CameraDescription(
    name: '2',
    lensDirection: CameraLensDirection.external,
    sensorOrientation: 0,
  );

  @override
  void initState() {
    super.initState();
    controller =
        CameraController(cameras, ResolutionPreset.max, enableAudio: false);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return CameraPreview(controller);
  }
}
