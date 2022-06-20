import 'dart:io';

import 'package:biolens/models/shelf_models.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:path/path.dart';
import 'package:diacritic/diacritic.dart';

class VisionSearchList {
  const VisionSearchList({required this.type, required this.rating});

  final String type;
  final Rating rating;
}

class MyVision {
  static List<String> _getWordsList(RecognisedText recognisedText) {
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

  static String _prepareWord(String word) {
    return removeDiacritics(word.toLowerCase());
  }

  static Product? _compareTo({
    required RecognisedText recognisedText,
    required List<Product> listProducts,
  }) {
    List<VisionSearchList> visionSearchList = [];

    // On crée une liste avec tous les name des produit
    List<String> listProductsNames = [];
    listProducts.forEach(
        (product) => listProductsNames.add(_prepareWord(product.name)));

    // On crée une liste avec tous les tagPicture des produits
    List<String?> listTagsPictures = [];
    listProducts.forEach((product) => listTagsPictures.add(
        product.tagPicture != null ? _prepareWord(product.tagPicture!) : null));

    // On découpe les blocks de text avec la fonction _getWordsList
    // Pour chaque mot on recherche sa meilleure association dans la listProductsNames et la listTagsPictures et on stock tout dans une même liste
    _getWordsList(recognisedText).forEach(
      (word) {
        visionSearchList.add(
          VisionSearchList(
              type: "name",
              rating:
                  _prepareWord(word).bestMatch(listProductsNames).bestMatch),
        );
        visionSearchList.add(
          VisionSearchList(
              type: "tagPicture",
              rating: _prepareWord(word).bestMatch(listTagsPictures).bestMatch),
        );
      },
    );

    // On trie la visionSearchList par le score
    visionSearchList.sort((a, b) {
      double aRating = a.rating.rating!;
      double bRating = b.rating.rating!;
      return bRating.compareTo(aRating);
    });

    // Si on a un score > 0.5
    if (visionSearchList.length > 0 &&
        visionSearchList[0].rating.rating! > 0.5) {
      // On crée une bestItemsOfVisionSearchList avec tous les items égaux
      double bestScore = visionSearchList[0].rating.rating!;
      List<VisionSearchList> bestItemsOfVisionSearchList = visionSearchList
          .where((element) => element.rating.rating == bestScore)
          .toList();

      // On sélectionne l'item avec le nom le plus long en cas d'égalité de score
      bestItemsOfVisionSearchList.sort((a, b) {
        String? aName = a.rating.target;
        String? bName = b.rating.target;
        if (aName == null || bName == null) return 0;

        return bName.length.compareTo(aName.length);
      });

      // On déclare le bestSearch qui sera retourné
      VisionSearchList bestSearch = bestItemsOfVisionSearchList[0];

      // On retourne le produit qui a le même nom que le bestSearch
      return listProducts.firstWhere((Product productModel) {
        Map<String, dynamic> product = productModel.toJson();

        // En fonction de bestSearch.type on recherche product["name"] ou product["pictureTag"]
        // On retourne le premier produit qui a un nom identique à la target determiné en passant les deux dans un filtre (suppression des accents et minuscule)
        if (product[bestSearch.type] == null) return false;
        return _prepareWord(product[bestSearch.type]!) ==
            bestSearch.rating.target!;
      });
    }

    return null;
  }

  static Future<File?> _rotate({
    required File image,
    required int angle,
  }) async {
    return FlutterImageCompress.compressAndGetFile(
      image.path,
      image.parent.path + "/" + angle.toString() + basename(image.path),
      rotate: angle,
    );
  }

  static Future<Product?> recognitionByFile(
      BuildContext context, File file) async {
    // On récupère la liste des produits
    List<Product> _productsEntity =
        Provider.of<List<Product>>(context, listen: false);

    Product? _result;

    // On prépare l'image pour l'analyse
    InputImage _inputImage = InputImage.fromFile(file);

    // On commence par vérifier la présence d'un QRCode
    final _qrcodeDetector =
        GoogleMlKit.vision.barcodeScanner([BarcodeFormat.qrCode]);

    final Product? _qrcodeProduct =
        await _qrcodeDetector.processImage(_inputImage).then<Product?>((value) {
      // Si aucun QRCode sur l'image
      if (value.length == 0) return null;

      // On stock le contenu du QRCode
      String? _recognisedQrCodeLink = value[0].value.displayValue;

      // Si le contenu est vide
      if (_recognisedQrCodeLink == null) return null;

      // On retourne un produit nul si le contenu du QRCode n'est pas un short link correct
      RegExp _regExpIsABiolensShortLink =
          RegExp(r"^https:\/\/biolens.page.link\/[a-zA-Z0-9]{4,}$");

      if (!_regExpIsABiolensShortLink.hasMatch(_recognisedQrCodeLink))
        return null;

      // On récupère le long link associé au short link
      return FirebaseDynamicLinks.instance
          .getDynamicLink(Uri.parse(_recognisedQrCodeLink))
          .then((value) {
        Uri? longLink = value?.link;
        if (longLink == null) return null;

        // On retourne un produit nul si le long link n'est pas correct
        RegExp _regExpIsABiolensLongLink =
            RegExp(r"^https:\/\/biolens.app\/link\/product\/[a-zA-Z0-9]+$");

        if (_regExpIsABiolensLongLink.hasMatch(longLink.toString())) {
          // On retourne le produit ayant l'id du dernier segment du long link
          return _productsEntity.firstWhere(
              ((product) => product.id == value?.link.pathSegments.last));
        }
        return null;
      });
    });

    // Si aucun produit n'a été trouvé dans le QRCode on test l'OCR
    if (_qrcodeProduct != null) {
      FirebaseAnalytics.instance
          .logEvent(name: "to_scan", parameters: {"type": "QRCode"});
      return _qrcodeProduct;
    }

    final TextDetector _textDetector = GoogleMlKit.vision.textDetector();
    Future<RecognisedText> _recognisedText =
        _textDetector.processImage(_inputImage);

    return _recognisedText.then<Product?>((recognisedText) async {
      _result = _compareTo(
        recognisedText: recognisedText,
        listProducts: _productsEntity,
      );

      // Si pas de résultats on pivote l'image et on réessaie la reconnaissance
      if (_result == null) {
        //Rotation 270°
        _result = await _rotate(image: file, angle: 270).then((rotateFile) {
          _inputImage = InputImage.fromFile(rotateFile ?? File(file.path));
          return _textDetector
              .processImage(_inputImage)
              .then((recognisedText270) {
            return _compareTo(
              recognisedText: recognisedText270,
              listProducts: _productsEntity,
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
              listProducts: _productsEntity,
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
              listProducts: _productsEntity,
            );
          });
        });
        if (_result != null) return _result;
      }
      return _result;
    });
  }
}
