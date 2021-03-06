import 'dart:io';

import 'package:biolens/models/shelf_models.dart';
import 'package:biolens/shelf.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:url_launcher/url_launcher.dart';

class Homepage extends StatefulWidget {
  Homepage({
    Key? key,
  }) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _canUpdate = false;
  String? _updateLink;
  bool? _modeIsSelected;

  Mode? mode;

  @override
  void initState() {
    // print("build");
    // Intitialisation des listeners
    Provider.of<List<Product>>(context, listen: false);
    Provider.of<List<Tag>>(context, listen: false);
    Provider.of<List<University>>(context, listen: false);
    Provider.of<List<Annotation>>(context, listen: false);

    // On initie le dossier de cache pour le scan
    _setDirectory();

    FirebaseAnalytics.instance
        .logScreenView(screenClass: "scanner", screenName: "scanner");

    final newVersion = NewVersion(
      iOSId: 'com.polymathe.biolens',
      androidId: 'com.polymathe.biolens',
      iOSAppStoreCountry: "FR",
    );
    advancedStatusCheck(newVersion);

    super.initState();
  }

  advancedStatusCheck(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      setState(() {
        _updateLink = status.appStoreLink;
        _canUpdate = status.canUpdate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // On affiche un badge si le mode universitaire n'a jamais ??t?? ouvert
    Provider.of<BriteDatabase>(context, listen: true)
        .query("mode", limit: 1)
        .then(
      (value) {
        bool newValue = _modeIsSelected = value.length > 0;
        if (_modeIsSelected != newValue)
          setState(() => _modeIsSelected = value.length > 0);
      },
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Color.fromARGB(0, 0, 0, 0),
        systemNavigationBarColor: Color.fromRGBO(241, 246, 249, 1),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: CupertinoPageScaffold(
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
            // Bouton "?? propos"
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    CupertinoButton(
                      onPressed: () async {
                        bool cameraIsDesactivate = false;

                        // On d??sactive la cam??ra apr??s la transition
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

                        await Navigator.of(context).pushNamed("/about");

                        // On s'assure que la transition de d??sactivation de cam??ra soit termin??e avant de la r??activer
                        Future.delayed(
                          Duration(
                              milliseconds: cameraIsDesactivate ? 300 : 500),
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
                        size: 29,
                        color: Color.fromRGBO(241, 246, 249, 1),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () async {
                        bool cameraIsDesactivate = false;

                        // On d??sactive la cam??ra apr??s la transition
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

                        await Navigator.of(context)
                            .pushNamed("/select/university");

                        // On s'assure que la transition de d??sactivation de cam??ra soit termin??e avant de la r??activer
                        Future.delayed(
                          Duration(
                              milliseconds: cameraIsDesactivate ? 300 : 500),
                          () {
                            setState(
                              () {
                                _isActive = true;
                              },
                            );
                          },
                        );
                      },
                      padding: const EdgeInsets.all(0),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  Icons.school_outlined,
                                  size: 18,
                                  color: Color.fromRGBO(241, 246, 249, 1),
                                ),
                              ),
                            ),
                          ),
                          _modeIsSelected == false
                              ? Positioned(
                                  right: 7,
                                  bottom: 0,
                                  child: Container(
                                    width: 11,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: CupertinoColors.white),
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 167, 49, 129),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    _canUpdate
                        ? CupertinoButton(
                            onPressed: () async {
                              if (_updateLink == null) return;

                              bool cameraIsDesactivate = false;

                              // On d??sactive la cam??ra apr??s la transition
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

                              await launchUrl(
                                  Uri(scheme: "https", path: _updateLink));

                              // On s'assure que la transition de d??sactivation de cam??ra soit termin??e avant de la r??activer
                              Future.delayed(
                                Duration(
                                    milliseconds:
                                        cameraIsDesactivate ? 300 : 500),
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
                            child: Container(
                              width: 27,
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  CupertinoIcons.arrow_down_circle_fill,
                                  size: 26,
                                  color: Color.fromARGB(255, 167, 49, 129),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
            // Commandes en bas de l'??cran
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
                          "Scanner",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        // Le bouton est d??sactiv?? si le scan est impossible
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
                        bool savedVisibilityOfCamera = _cameraIsVisible;

                        // On d??sactive la cam??ra si on change de page
                        setState(() {
                          _isActive = false;
                          _cameraIsVisible = false;
                          _cameraReloading = false;
                        });
                        await Future.delayed(
                          Duration(milliseconds: 100),
                          () async =>
                              await Navigator.of(context).pushNamed("/search"),
                        );

                        Future.delayed(
                          Duration(milliseconds: 320),
                          () => setState(
                            () {
                              _isActive = true;
                              _cameraIsVisible = savedVisibilityOfCamera;
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
                    boxShadow: [
                      BoxShadow(
                          color:
                              CupertinoColors.darkBackgroundGray.withAlpha(50),
                          offset: Offset(0, -2),
                          spreadRadius: 5,
                          blurRadius: 7)
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Variables pour la camera_preview
  // Pr??voir l'utilisation d'un inheritedWidget ?
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
    // On r??initialise le compteur d'??chec
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('repetitiveFail', 0);
  }

  Future<void> _repetitiveFail() async {
    // On incr??mente le compteur d'??chec d'un
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('repetitiveFail') ?? 0) + 1;
    await prefs.setInt('repetitiveFail', counter);

    // Si  l'utilisateur n'a jamais valid?? la popup et qu'il a encha??n?? 2 ??checs
    // Si l'utilisateur a d??j?? valid?? la popup et qu'il a encha??n?? 4 ??checs
    if (prefs.getBool('repetitiveFailPopupRead') != true &&
            prefs.getInt('repetitiveFail')! >= 2 ||
        prefs.getInt('repetitiveFail')! >= 4) {
      // On r??initialise le compteur d'??chec quand on affiche la popup
      _resetRepetitiveFailCounter();

      // On affiche la dialog
      showGeneralDialog(
        context: context,
        pageBuilder: (context, animation1, animation2) =>
            RepetitiveFailDialog(prefs: prefs),
      );
    }
  }

  void _toScan() {
    FirebaseAnalytics.instance
        .logEvent(name: "to_scan", parameters: {"step": "try"});

    if (cacheDirectory == null) return;

    _setSearchLoading(true);

    // On cr??e le fichier temporaire
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

          // On incr??mente un ??chec au compteur et on affiche la popup au besoin
          _repetitiveFail();

          return;
        }

        // On reset le compteur d'??chec
        _resetRepetitiveFailCounter();

        // On s'assure que la transition est termin??e pour r??activer la cam??ra
        // On ??vite les changements d'??tat pendant les transitions
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

        await Navigator.of(context).pushNamed("/product/${product.id}");

        Future.delayed(Duration(milliseconds: cameraIsDesactivate ? 300 : 500),
            () {
          _setIsActive(true);
        });
      }).timeout(Duration(seconds: 5), onTimeout: () async {
        FirebaseAnalytics.instance
            .logEvent(name: "to_scan", parameters: {"step": "fail"});

        // Si timeout > bug de l'analyse
        // On relance tout apr??s 5000ms
        setState(() {
          _searchLoading = false;
          _cameraIsVisible = false;
          _cameraReloading = true;
          _cameraKey = Object();
        });
      });
    }).timeout(Duration(seconds: 3), onTimeout: () async {
      FirebaseAnalytics.instance
          .logEvent(name: "to_scan", parameters: {"step": "fail"});

      // Si timeout > bug de la cam??ra
      // On relance tout apr??s 3000ms
      setState(() {
        _searchLoading = false;
        _cameraIsVisible = false;
        _cameraReloading = true;
        _cameraKey = Object();
      });
    });
  }

// D??termination des dossiers de cache
  void _setDirectory() async {
    cacheDirectory = await getTemporaryDirectory();
    cacheResizedDirectory = await Directory('${cacheDirectory!.path}/resized')
        .create(recursive: true);
  }
}

class RepetitiveFailDialog extends StatelessWidget {
  const RepetitiveFailDialog({
    Key? key,
    required this.prefs,
  }) : super(key: key);

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(35),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.camera_viewfinder,
                          size: 40, color: Color.fromARGB(255, 167, 49, 129)),
                      Expanded(
                        child: Center(
                          child: new Text(
                            "Vous avez des difficult??s ?",
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
              SvgPicture.asset(
                "assets/lost.svg",
                width: MediaQuery.of(context).size.width,
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: new Text(
                        "Afin d'am??liorer l'analyse, v??rifiez que :",
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
                            "???",
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
                            "???",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Expanded(
                          child: new Text(
                            "le produit est pr??sent dans la base des donn??es de biolens",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      child: new Text(
                        "N'oubliez pas que vous pouvez aussi scanner les codes QR g??n??r??s dans l'onglet partage de l'application !",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
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
    );
  }
}
