import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:path/path.dart';
import 'package:diacritic/diacritic.dart';

class MyVision {
  static Future recognitionByFile(File file) async {
    List<String> _getWordsList(RecognisedText recognisedText) {
      List<String> listText = [];
      recognisedText.blocks.forEach((block) {
        block.lines.forEach((line) {
          line.elements.forEach((textElement) {
            listText.add(textElement.text);
          });
          listText.add(line.text);
        });
      });

      return listText;
    }

    String _prepareWord(String word) {
      return removeDiacritics(word.toLowerCase());
    }

    Object? _compareTo({
      required RecognisedText recognisedText,
      required List<String> dataNames,
      required QuerySnapshot data,
    }) {
      List<Rating> searchList = [];
      _getWordsList(recognisedText).forEach(
        (e) => searchList.add(
          _prepareWord(e).bestMatch(dataNames).bestMatch,
        ),
      );

      searchList.sort((a, b) {
        double aRating = a.rating!;
        double bRating = b.rating!;
        return bRating.compareTo(aRating);
      });

      if (searchList.length > 0 && searchList[0].rating! > 0.5) {
        return data.docs
            .firstWhere((QueryDocumentSnapshot document) =>
                _prepareWord(document['name']) == searchList[0].target!)
            .data();
      }
    }

    Future<File?> _rotate({
      required File image,
      required int angle,
    }) async {
      return FlutterImageCompress.compressAndGetFile(
        image.path,
        image.parent.path + "/" + angle.toString() + basename(image.path),
        rotate: angle,
      );
    }

    Future<QuerySnapshot> _productsEntity =
        FirebaseFirestore.instance.collection('products').get();

    List<String> _listNames = [];
    Object? _result;

    InputImage _inputImage = InputImage.fromFile(file);
    final TextDetector _textDetector = GoogleMlKit.vision.textDetector();
    Future<RecognisedText> _recognisedText0 =
        _textDetector.processImage(_inputImage);

    List<Future> _initialization = [_productsEntity, _recognisedText0];

    return Future.wait(_initialization).then((futures) async {
      final QuerySnapshot _products = futures[0];
      final RecognisedText recognisedText0 = futures[1];

      _products.docs.forEach((DocumentSnapshot document) {
        _listNames.add(_prepareWord(document['name']));
      });

      _result = _compareTo(
        recognisedText: recognisedText0,
        dataNames: _listNames,
        data: _products,
      );

      if (_result == null) {
        //Rotation 270°
        _result = await _rotate(image: file, angle: 270).then((rotateFile) {
          _inputImage = InputImage.fromFile(rotateFile ?? File(file.path));
          return _textDetector
              .processImage(_inputImage)
              .then((recognisedText270) {
            return _compareTo(
              recognisedText: recognisedText270,
              dataNames: _listNames,
              data: _products,
            );
          });
        });
        if (_result != null) return _result;

        //Rotation 90°
        _result = await _rotate(image: file, angle: 90).then((rotateFile) {
          _inputImage = InputImage.fromFile(rotateFile ?? File(file.path));
          return _textDetector
              .processImage(_inputImage)
              .then((recognisedText90) {
            return _compareTo(
              recognisedText: recognisedText90,
              dataNames: _listNames,
              data: _products,
            );
          });
        });
        if (_result != null) return _result;

        //Rotation 180°
        _result = await _rotate(image: file, angle: 180).then((rotateFile) {
          _inputImage = InputImage.fromFile(rotateFile ?? File(file.path));
          return _textDetector
              .processImage(_inputImage)
              .then((recognisedText180) {
            return _compareTo(
              recognisedText: recognisedText180,
              dataNames: _listNames,
              data: _products,
            );
          });
        });
        if (_result != null) return _result;
      }
      return _result;
    });
  }
}