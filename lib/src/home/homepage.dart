import 'dart:io';

import 'package:biolens/shelf.dart';
import 'package:biolens/src/home/camera_preview.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:biolens/models/products/products.dart';
import 'package:biolens/models/tags/tags.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    // On initie le dossier de cache pour le scan
    _setDirectory();

    FirebaseAnalytics.instance
        .logScreenView(screenClass: "scanner", screenName: "scanner");

    // Intitialisation des listeners
    Provider.of<List<Product>>(context, listen: false);
    Provider.of<List<Tag>>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      child: Stack(
        children: [
          CameraPreview(
            cameraKey: _cameraKey,
            cameraIsVisible: _cameraIsVisible,
            cameraReloading: _cameraReloading,
            isActive: _isActive,
            permissionEnabled: _permissionEnabled,
            searchLoading: _searchLoading,
            setCameraIsVisible: _setCameraIsVisible,
            setCameraReloading: _setCameraReloading,
            setIsActive: _setIsActive,
            setPermissionEnabled: _setPermissionEnabled,
            setSearchLoading: _setSearchLoading,
          ),
          // Bouton "à propos"
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: CupertinoButton(
                onPressed: () async {
                  bool cameraIsDesactivate = false;

                  // On désactive la caméra après la transition
                  Future.delayed(
                    Duration(milliseconds: 500),
                    () => setState(
                      () {
                        _isActive = false;
                        _cameraIsVisible = false;
                        _cameraReloading = false;
                      },
                    ),
                  ).then((value) => cameraIsDesactivate = true);

                  await Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => About(),
                    ),
                  );

                  // On s'assure que la transition de désactivation de caméra soit terminée avant de la réactiver
                  Future.delayed(
                    Duration(milliseconds: cameraIsDesactivate ? 300 : 500),
                    () {
                      setState(
                        () {
                          _isActive = true;
                        },
                      );
                    },
                  );
                },
                padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                child: Icon(
                  CupertinoIcons.info_circle,
                  size: 26,
                  color: Color.fromRGBO(241, 246, 249, 1),
                ),
              ),
            ),
          ),
          // Commandes en bas de l'écran
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 210,
              padding: EdgeInsets.all(35),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 60,
                    child: CupertinoButton(
                      disabledColor: CupertinoColors.inactiveGray,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: Text(
                        'Scanner',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      // Le bouton est désactivé si le scan est impossible
                      onPressed: _searchLoading || _permissionEnabled != true
                          ? null
                          : () => _toScan(),
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      // On désactive la caméra si on change de page
                      setState(() {
                        _isActive = false;
                        _cameraIsVisible = false;
                        _cameraReloading = false;
                      });
                      await Future.delayed(
                        Duration(milliseconds: 100),
                        () async => await Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, anotherAnimation) =>
                                    Search(),
                            fullscreenDialog: true,
                            transitionDuration: Duration(milliseconds: 500),
                            reverseTransitionDuration:
                                Duration(milliseconds: 350),
                            transitionsBuilder:
                                (context, animation, anotherAnimation, child) {
                              animation = CurvedAnimation(
                                curve: Curves.linearToEaseOut,
                                parent: animation,
                              );
                              return SlideTransition(
                                position: Tween(
                                  begin: Offset(0, 1),
                                  end: Offset(0.0, 0.0),
                                ).animate(animation),
                                child: child,
                              );
                            },
                          ),
                        ),
                      );

                      Future.delayed(
                        Duration(milliseconds: 320),
                        () => setState(
                          () {
                            _isActive = true;
                            _cameraIsVisible = true;
                            _cameraReloading = true;
                          },
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'search',
                      transitionOnUserGestures: true,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: CupertinoColors.systemGrey5,
                        ),
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child: Icon(
                                CupertinoIcons.search,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            Text(
                              "Rechercher",
                              style: TextStyle(
                                fontSize: 18,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Color.fromRGBO(241, 246, 249, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Variables pour la camera_preview
  // Prévoir l'utilisation d'un inheritedWidget ?
  final PictureController _awesomeController = PictureController();
  Object _cameraKey = Object();
  bool _isActive = true;
  bool _cameraIsVisible = false;
  bool? _permissionEnabled;
  bool _cameraReloading = false;
  bool _searchLoading = false;

  Directory? cacheDirectory;
  Directory? cacheResizedDirectory;

  void _setIsActive(bool newValue) {
    setState(() {
      _isActive = newValue;
    });
  }

  void _setCameraIsVisible(bool newValue) {
    setState(() {
      _cameraIsVisible = newValue;
    });
  }

  void _setPermissionEnabled(bool? newValue) {
    setState(() {
      _permissionEnabled = newValue;
    });
  }

  void _setCameraReloading(bool newValue) {
    setState(() {
      _cameraReloading = newValue;
    });
  }

  void _setSearchLoading(bool newValue) {
    setState(() {
      _searchLoading = newValue;
    });
  }

  Future<void> _resetRepetitiveFailCounter() async {
    // On réinitialise le compteur d'échec
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('repetitiveFail', 0);
  }

  Future<void> _repetitiveFail() async {
    // On incrémente le compteur d'échec d'un
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('repetitiveFail') ?? 0) + 1;
    await prefs.setInt('repetitiveFail', counter);

    // Si  l'utilisateur n'a jamais validé la popup et qu'il a enchaîné 2 échecs
    // Si l'utilisateur a déjà validé la popup et qu'il a enchaîné 4 échecs
    if (prefs.getBool('repetitiveFailPopupRead') != true &&
            prefs.getInt('repetitiveFail')! >= 2 ||
        prefs.getInt('repetitiveFail')! >= 4) {
      // On réinitialise le compteur d'échec quand on affiche la popup
      _resetRepetitiveFailCounter();

      // On affiche la dialog
      showGeneralDialog(
        context: context,
        pageBuilder: (context, animation1, animation2) => Dialog(
          insetPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(50, 167, 49, 129),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.camera_viewfinder,
                              size: 40,
                              color: Color.fromARGB(255, 167, 49, 129)),
                          Expanded(
                            child: Center(
                              child: new Text(
                                "Vous avez des difficultés ?",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 100, 27, 60),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: new Text(
                            "Afin d'améliorer l'analyse, vérifiez que :",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: new Text(
                                "•",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Expanded(
                              child: new Text(
                                "le nom du produit est lisible sur le scan",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: new Text(
                                "•",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Expanded(
                              child: new Text(
                                "le produit est présent dans la base des données de biolens",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "J'ai compris !",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      onPressed: () {
                        // On note que l'utilisateur a lu la popup et on pop
                        prefs.setBool('repetitiveFailPopupRead', true);
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _toScan() {
    FirebaseAnalytics.instance
        .logEvent(name: "to_scan", parameters: {"step": "loading"});

    if (cacheDirectory == null) return;

    _setSearchLoading(true);

    // On crée le fichier temporaire
    final String name = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '${cacheDirectory!.path}/$name.jpg';

    // On prend la photo et on la compresse
    _awesomeController.takePicture(filePath).then((imageShooted) async {
      final File fileResized = await FlutterImageCompress.compressAndGetFile(
            filePath,
            '${cacheResizedDirectory!.path}/$name.jpg',
            quality: 80,
            minWidth: 400,
            minHeight: 400,
          ) ??
          File(filePath);

      // On lance l'OCR
      MyVision.recognitionByFile(context, fileResized)
          .then((Product? product) async {
        _setSearchLoading(false);
        if (product == null) {
          FirebaseAnalytics.instance
              .logEvent(name: "to_scan", parameters: {"step": "fail"});

          // On incrémente un échec au compteur et on affiche la popup au besoin
          _repetitiveFail();

          return;
        }

        // On reset le compteur d'échec
        _resetRepetitiveFailCounter();

        // On s'assure que la transition est terminée pour réactiver la caméra
        // On évite les changements d'état pendant les transitions
        bool cameraIsDesactivate = false;

        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            _isActive = false;
            _cameraIsVisible = false;
            _cameraReloading = false;
          });
        }).then((value) => cameraIsDesactivate = true);

        FirebaseAnalytics.instance.logEvent(
            name: "to_scan",
            parameters: {"step": "success", "name": product.name});

        await Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => ProductViewer(
              product: product,
            ),
          ),
        );

        Future.delayed(Duration(milliseconds: cameraIsDesactivate ? 300 : 500),
            () {
          _setIsActive(true);
        });
      });
    }).timeout(Duration(seconds: 3), onTimeout: () async {
      FirebaseAnalytics.instance
          .logEvent(name: "to_scan", parameters: {"step": "fail"});

      // Si timeout > bug de la caméra
      // On relance tout après 3000ms
      setState(() {
        _searchLoading = false;
        _cameraIsVisible = false;
        _cameraReloading = true;
        _cameraKey = Object();
      });
    });
  }

// Détermination des dossiers de cache
  void _setDirectory() async {
    cacheDirectory = await getTemporaryDirectory();
    cacheResizedDirectory = await Directory('${cacheDirectory!.path}/resized')
        .create(recursive: true);
  }
}
