import 'dart:io';

// import 'package:biolens/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:path/path.dart';
import 'package:diacritic/diacritic.dart';

class DenseProduct {
  const DenseProduct(
      {required this.name, required this.tagPicture, required this.brand});

  final String name;
  final String? tagPicture;
  final String brand;
}

class VisionSearchList {
  const VisionSearchList({required this.type, required this.rating});

  final String type;
  final Rating rating;
}

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
      required List<DenseProduct> dataProducts,
      required QuerySnapshot data,
    }) {
      List<VisionSearchList> searchList = [];

      List<String> dataNames = [];
      List<String?> dataTags = [];

      dataProducts.forEach((product) => dataNames.add(product.name));

      dataProducts.forEach((product) => dataTags.add(product.tagPicture));

      _getWordsList(recognisedText).forEach(
        (e) {
          // List<Rating> _scores = [];
          // dataProducts.forEach((product) {
          //   print("$e / ${_prepareWord(e.replaceAll(product.brand, ''))}");
          //   _scores.add(Rating(
          //       target: product.name,
          //       rating: StringSimilarity.compareTwoStrings(
          //           _prepareWord(e.replaceAll(product.brand, "")),
          //           product.name)));
          // });

          // _scores.sort((a, b) {
          //   double aRating = a.rating!;
          //   double bRating = b.rating!;
          //   return bRating.compareTo(aRating);
          // });

          searchList.add(
            VisionSearchList(
                type: "name",
                rating: _prepareWord(e).bestMatch(dataNames).bestMatch),
          );
          searchList.add(
            VisionSearchList(
                type: "tagPicture",
                rating: _prepareWord(e).bestMatch(dataTags).bestMatch),
          );
        },
      );

      searchList.sort((a, b) {
        double aRating = a.rating.rating!;
        double bRating = b.rating.rating!;
        return bRating.compareTo(aRating);
      });

      if (searchList.length > 0 && searchList[0].rating.rating! > 0.5) {
        double bestScore = searchList[0].rating.rating!;
        List<VisionSearchList> bestList = searchList
            .where((element) => element.rating.rating == bestScore)
            .toList();

        bestList.sort((a, b) {
          String? aName = a.rating.target;
          String? bName = b.rating.target;
          if (aName == null || bName == null) return 0;

          return bName.length.compareTo(aName.length);
        });
        VisionSearchList bestSearch = bestList[0];

        return data.docs.firstWhere((QueryDocumentSnapshot document) {
          Map<String, dynamic> product =
              document.data() as Map<String, dynamic>;
          if (product[bestSearch.type] == null) return false;
          return _prepareWord(product[bestSearch.type]!) ==
              bestSearch.rating.target!;
        }).data();
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

    Future<QuerySnapshot> _productsEntity = FirebaseFirestore.instance
        .collection('products')
        .where("enabled", isEqualTo: true)
        .get();

    List<DenseProduct> _listProducts = [];
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
        Map<String, dynamic> product = document.data() as Map<String, dynamic>;

        _listProducts.add(
          DenseProduct(
            name: _prepareWord(product['name']),
            tagPicture: product['tagPicture'] != null
                ? _prepareWord(product['tagPicture'])
                : null,
            brand: _prepareWord(product['brand']),
          ),
        );
      });

      _result = _compareTo(
        recognisedText: recognisedText0,
        dataProducts: _listProducts,
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
              dataProducts: _listProducts,
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
              dataProducts: _listProducts,
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
              dataProducts: _listProducts,
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
