import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:image_picker/image_picker.dart';

class TrainModel extends StatefulWidget {
  const TrainModel({Key? key}) : super(key: key);

  @override
  _TrainModelState createState() => _TrainModelState();
}

class _TrainModelState extends State<TrainModel> {
  String? _productName;
  List<String> _test = ["unifast", "protemp", "tempbond", "duraphat", "irm"];

  Future<RecognisedText> _processDetection(File localFile) async {
    final InputImage inputImage = InputImage.fromFile(localFile);
    final TextDetector textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);
    return recognisedText;
  }

  List<String> _getWordsList(RecognisedText recognisedText) {
    List<String> listText = [];
    recognisedText.blocks.forEach((block) {
      block.lines.forEach((line) {
        line.elements.forEach((textElement) {
          listText.add(textElement.text);
        });
      });
    });
    return listText;
  }

  String _prepareWord(String word) {
    return word.toLowerCase();
  }

  void _search(File localFile, int angle) {
    _processDetection(localFile).then((recognisedText) async {
      List<Rating> searchList = [];
      _getWordsList(recognisedText).forEach(
        (e) => searchList.add(
          _prepareWord(e).bestMatch(_test).bestMatch,
        ),
      );
      print("Angle " + angle.toString());
      print(_getWordsList(recognisedText));

      searchList.sort((a, b) {
        double aRating = a.rating!;
        double bRating = b.rating!;
        return bRating.compareTo(aRating);
      });

      if (searchList.length == 0 || searchList[0].rating! < 0.5) {
        if (angle + 90 < 360) {
          final capturedImage = decodeImage(await localFile.readAsBytes());
          final orientedImage = copyRotate(capturedImage!, angle + 90);
          File(localFile.path)
              .writeAsBytes(encodeJpg(orientedImage))
              .then((value) => _search(value, angle + 90));
        } else {
          print('No result');
        }
      } else {
        setState(() {
          _productName = searchList[0].target!;
        });
      }
    });
  }

  void _getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File localFile = File(image.path);
      _search(localFile, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          CupertinoButton(
            child: Text('load an image'),
            onPressed: () => _getImage(),
          ),
          Text(_productName ?? "No product"),
        ],
      ),
    );
  }
}
