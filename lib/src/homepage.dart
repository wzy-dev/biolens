import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:biolens/shelf.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  bool _cameraIsVisible = false;
  bool? _permissionEnabled;
  bool _cameraReloading = false;
  bool _searchLoading = false;
  Object _cameraKey = Object();
  double _viewportHeight = 0;
  double _viewportWidth = 0;
  double _captureHoleHeight = 0;
  double _captureHoleWidth = 0;
  final PictureController awesomeController = PictureController();
  Directory? cacheDirectory;
  Directory? cacheResizedDirectory;
  bool _isActive = true;

  AppLifecycleState? _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  void _setDirectory() async {
    cacheDirectory = await getTemporaryDirectory();
    cacheResizedDirectory = await Directory('${cacheDirectory!.path}/resized')
        .create(recursive: true);
  }

  @override
  void initState() {
    _setDirectory();
    WidgetsBinding.instance!.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void _toScan() {
    if (cacheDirectory == null) return;

    setState(() {
      _searchLoading = true;
    });

    final String name = DateTime.now().millisecondsSinceEpoch.toString();

    final String filePath = '${cacheDirectory!.path}/$name.jpg';

    awesomeController.takePicture(filePath).then((imageShooted) async {
      final File fileResized = await FlutterImageCompress.compressAndGetFile(
            filePath,
            '${cacheResizedDirectory!.path}/$name.jpg',
            quality: 80,
            minWidth: 400,
            minHeight: 400,
          ) ??
          File(filePath);

      MyVision.recognitionByFile(fileResized).then((value) async {
        setState(() {
          _searchLoading = false;
        });
        if (value == null) return;

        bool isDesactivate = false;

        Future.delayed(
          Duration(milliseconds: 500),
          () => setState(
            () {
              _isActive = false;
              _cameraIsVisible = false;
              _cameraReloading = false;
            },
          ),
        ).then((value) => isDesactivate = true);

        await Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => Product(
              product: value,
            ),
          ),
        );

        Future.delayed(
          Duration(milliseconds: isDesactivate ? 300 : 500),
          () {
            setState(
              () {
                _isActive = true;
              },
            );
          },
        );
      });
    }).timeout(Duration(seconds: 3), onTimeout: () async {
      setState(() {
        _searchLoading = false;
        _cameraIsVisible = false;
        _cameraReloading = true;
        _cameraKey = Object();
      });
    });
  }

  void _onPermissionsResult() async {
    PermissionStatus statusCamera = await Permission.camera.status;
    PermissionStatus statusStorage = await Permission.storage.status;

    if ((statusCamera.isDenied ||
            statusCamera.isPermanentlyDenied ||
            statusStorage.isDenied ||
            statusStorage.isPermanentlyDenied) &&
        _permissionEnabled != false) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.storage,
      ].request();

      statusCamera = statuses[Permission.camera] ?? statusCamera;
      statusStorage = statuses[Permission.storage] ?? statusCamera;

      if (!statusCamera.isDenied &&
          !statusCamera.isPermanentlyDenied &&
          !statusStorage.isDenied &&
          !statusStorage.isPermanentlyDenied) {
        return;
      } else {
        setState(() {
          _permissionEnabled = false;
        });
      }
    } else if ((!statusCamera.isDenied &&
            !statusCamera.isPermanentlyDenied &&
            !statusStorage.isDenied &&
            !statusStorage.isPermanentlyDenied) &&
        _permissionEnabled != true) {
      setState(() {
        _permissionEnabled = true;
      });
    }
  }

  Widget _drawCamera() {
    if (_notification == AppLifecycleState.inactive ||
        _notification == AppLifecycleState.paused) {
      setState(() {
        _cameraIsVisible = false;
      });
      return Container();
    } else {
      _onPermissionsResult();
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: _permissionEnabled == null
            ? Container()
            : _permissionEnabled == true
                ? AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: _cameraIsVisible ? 1 : 0,
                    child: Stack(
                      children: [
                        CameraAwesome(
                          onCameraStarted: () {
                            setState(() {
                              _cameraIsVisible = true;
                              _cameraReloading = false;
                            });
                          },
                          key: ValueKey(_cameraKey),
                          sensor: ValueNotifier(Sensors.BACK),
                          photoSize: ValueNotifier(Size(0, 0)),
                          captureMode: ValueNotifier(CaptureModes.PHOTO),
                        ),
                        Container(
                          color: _cameraReloading
                              ? CupertinoColors.darkBackgroundGray
                              : Color.fromRGBO(0, 0, 0, 0),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/camera_off.svg',
                        width: MediaQuery.of(context).size.width,
                        color: Color.fromRGBO(255, 255, 255, 0.05),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Vous devez donner la permission à biolens d'accéder à votre caméra pour utiliser le scanner !",
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 0.7)),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Appuyez ici pour accéder aux paramétres et donner l'autorisation.",
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.7),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _viewportHeight = MediaQuery.of(context).size.height;
    _viewportWidth = MediaQuery.of(context).size.width;

    _captureHoleHeight = (_viewportHeight - 190) * 0.65;
    _captureHoleWidth = _captureHoleHeight * 0.85 < _viewportWidth * 0.7
        ? _captureHoleHeight * 0.85
        : _viewportWidth * 0.7;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      child: Stack(
        children: [
          Container(
            height: _viewportHeight - 190,
            width: _viewportWidth,
            child: _isActive
                ? CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: _permissionEnabled == true
                        ? null
                        : () => openAppSettings(),
                    child: Stack(
                      children: [
                        Container(
                          child: _drawCamera(),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(),
                        ),
                        AnimatedOpacity(
                          curve: Curves.bounceInOut,
                          opacity: _searchLoading
                              ? 1
                              : _cameraIsVisible
                                  ? 0.4
                                  : 0,
                          duration: Duration(
                              milliseconds: _searchLoading ? 200 : 1000),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Color.fromRGBO(255, 255, 255, 0.8),
                              BlendMode.srcOut,
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.black,
                                    backgroundBlendMode: BlendMode.dstOut,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: AnimatedContainer(
                                    curve: Curves.easeOutQuart,
                                    duration: Duration(milliseconds: 500),
                                    height: _searchLoading == false
                                        ? _captureHoleHeight - 30
                                        : 0,
                                    width: _searchLoading == false
                                        ? _captureHoleWidth - 30
                                        : 0,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.destructiveRed,
                                      borderRadius: BorderRadius.circular(
                                          _searchLoading == false ? 20 : 100),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          curve: Curves.ease,
                          opacity: _cameraIsVisible ? 1 : 0,
                          duration: Duration(milliseconds: 2000),
                          child: Center(
                            child: Container(
                              // height: 280,
                              // width: 230,
                              height: _captureHoleHeight,
                              width: _captureHoleWidth,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: RotatedBox(
                                      quarterTurns: 0,
                                      child: Corner(loading: _searchLoading),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: RotatedBox(
                                      quarterTurns: 1,
                                      child: Corner(loading: _searchLoading),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: RotatedBox(
                                      quarterTurns: 3,
                                      child: Corner(loading: _searchLoading),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: RotatedBox(
                                      quarterTurns: 2,
                                      child: Corner(loading: _searchLoading),
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    duration: Duration(milliseconds: 200),
                                    opacity: _searchLoading ? 1 : 0,
                                    child: Center(
                                      child: LoadingIndicator(
                                        indicatorType: Indicator.ballScale,
                                        colors: [
                                          CupertinoTheme.of(context)
                                              .primaryColor
                                        ],
                                        strokeWidth: 50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          AnimatedOpacity(
            opacity: _cameraIsVisible ? 0 : 1,
            duration: Duration(milliseconds: 1000),
            child: Container(
              height: _viewportHeight - 190,
              width: _viewportWidth,
              color: CupertinoColors.darkBackgroundGray,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: CupertinoButton(
                onPressed: () async {
                  bool isDesactivate = false;

                  Future.delayed(
                    Duration(milliseconds: 500),
                    () => setState(
                      () {
                        _isActive = false;
                        _cameraIsVisible = false;
                        _cameraReloading = false;
                      },
                    ),
                  ).then((value) => isDesactivate = true);

                  await Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => About(),
                    ),
                  );

                  Future.delayed(
                    Duration(milliseconds: isDesactivate ? 300 : 500),
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
                        Duration(milliseconds: 350),
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
}

class Corner extends StatelessWidget {
  const Corner({
    Key? key,
    required bool loading,
  })  : _loading = loading,
        super(key: key);

  final bool _loading;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: _loading ? 0 : 1,
      child: SvgPicture.asset(
        'assets/rounded_angle.svg',
        height: 50,
        width: 50,
        color: CupertinoTheme.of(context).primaryColor,
      ),
    );
  }
}
