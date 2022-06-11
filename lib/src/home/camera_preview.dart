import 'package:flutter/cupertino.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPreview extends StatefulWidget {
  CameraPreview({
    Key? key,
    required this.cameraKey,
    required this.isActive,
    required this.cameraIsVisible,
    required this.permissionEnabled,
    required this.cameraReloading,
    required this.searchLoading,
    required this.setIsActive,
    required this.setCameraIsVisible,
    required this.setPermissionEnabled,
    required this.setCameraReloading,
    required this.setSearchLoading,
  }) : super(key: key);

  final Object cameraKey;
  final bool isActive;
  final bool cameraIsVisible;
  final bool? permissionEnabled;
  final bool cameraReloading;
  final bool searchLoading;
  final void Function(bool) setIsActive;
  final void Function(bool) setCameraIsVisible;
  final void Function(bool?) setPermissionEnabled;
  final void Function(bool) setCameraReloading;
  final void Function(bool) setSearchLoading;

  @override
  _CameraPreviewState createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview>
    with WidgetsBindingObserver {
  double _viewportHeight = 0;
  double _viewportWidth = 0;
  double _captureHoleHeight = 0;
  double _captureHoleWidth = 0;

// On gère les cycles pour mettre la caméra en pause en arrière plan
  AppLifecycleState? _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onPermissionsResult() async {
    PermissionStatus statusCamera = await Permission.camera.status;
    PermissionStatus statusStorage = await Permission.storage.status;

    if ((statusCamera.isDenied ||
            statusCamera.isPermanentlyDenied ||
            statusStorage.isDenied ||
            statusStorage.isPermanentlyDenied) &&
        widget.permissionEnabled != false) {
      // On demande les permissions si on ne les a pas encore
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.storage,
      ].request();

      statusCamera = statuses[Permission.camera] ?? statusCamera;
      statusStorage = statuses[Permission.storage] ?? statusCamera;

      // On vérifie la réponse
      if (!statusCamera.isDenied &&
          !statusCamera.isPermanentlyDenied &&
          !statusStorage.isDenied &&
          !statusStorage.isPermanentlyDenied) {
        return;
      } else {
        widget.setPermissionEnabled(false);
      }
    } else if ((!statusCamera.isDenied &&
            !statusCamera.isPermanentlyDenied &&
            !statusStorage.isDenied &&
            !statusStorage.isPermanentlyDenied) &&
        widget.permissionEnabled != true) {
      // Si les permissions sont initialement acceptées
      widget.setPermissionEnabled(true);
    }
  }

  Widget _drawCamera() {
    if (_notification == AppLifecycleState.inactive ||
        _notification == AppLifecycleState.paused) {
      // Si la caméra passe en arrière plan on la désactive après un délai 0 pour éviter un setState durant un build
      Future.delayed(Duration.zero, () async {
        widget.setCameraIsVisible(false);
      });
      return Container();
    } else {
      // On demande les permissions avant tout
      _onPermissionsResult();
      // Switcher permissions en attente / permissions demandées
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: widget.permissionEnabled == null
            ? Container()
            : widget.permissionEnabled == true
                ? AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: widget.cameraIsVisible ? 1 : 0,
                    child: Stack(
                      children: [
                        // Affichage de la caméra
                        CameraAwesome(
                          onCameraStarted: () {
                            // On informe le widget parent que la caméra est lancée
                            widget.setCameraIsVisible(true);
                            widget.setCameraReloading(false);
                          },
                          key: ValueKey(widget.cameraKey),
                          sensor: ValueNotifier(Sensors.BACK),
                          photoSize: ValueNotifier(Size(0, 0)),
                          captureMode: ValueNotifier(CaptureModes.PHOTO),
                        ),
                        // Fixture pour screenshot
                        // Container(
                        //   width: double.infinity,
                        //   height: double.infinity,
                        //   child: Image(
                        //     image: AssetImage("assets/pxl.jpg"),
                        //     fit: BoxFit.cover,
                        //   ),
                        // ),
                        // Si la caméra est en cours de rechargement on recouvre par une surface grise
                        Container(
                          color: widget.cameraReloading
                              ? CupertinoColors.darkBackgroundGray
                              : Color.fromRGBO(0, 0, 0, 0),
                        ),
                      ],
                    ),
                  )
                // Si les permissions sont refusées
                : Container(
                    color: Color.fromARGB(255, 170, 180, 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SvgPicture.asset(
                          'assets/scanner.svg',
                          width: MediaQuery.of(context).size.width * 0.8,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 20),
                          child: Text(
                            "Autoriser l'accès à votre caméra afin d'utiliser le scanner",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color.fromRGBO(55, 71, 79, 1),
                            ),
                          ),
                        )
                        // Padding(
                        //   padding: const EdgeInsets.all(30),
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     children: [
                        //       Text(
                        //         "Vous devez donner la permission à biolens d'accéder à votre caméra pour utiliser le scanner !",
                        //         style: TextStyle(
                        //             color: Color.fromRGBO(255, 255, 255, 0.7)),
                        //         textAlign: TextAlign.center,
                        //       ),
                        //       SizedBox(
                        //         height: 10,
                        //       ),
                        //       Text(
                        //         "Appuyez ici pour accéder aux paramètres et donner l'autorisation.",
                        //         style: TextStyle(
                        //           color: Color.fromRGBO(255, 255, 255, 0.7),
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //         textAlign: TextAlign.center,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
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
            // Hauteur - 190 pour loger les boutons en bas
            height: _viewportHeight - 190,
            width: _viewportWidth,
            child: widget.isActive
                ? CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: widget.permissionEnabled == true
                        ? null
                        // Si pas les permissions, l'appuie sur la surface renvoie vers les paramètres de l'app
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
                          opacity: widget.searchLoading
                              ? 1
                              : widget.cameraIsVisible
                                  ? 0.4
                                  : 0,
                          duration: Duration(
                              milliseconds: widget.searchLoading ? 200 : 1000),
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
                                    height: widget.searchLoading == false
                                        ? _captureHoleHeight - 30
                                        : 0,
                                    width: widget.searchLoading == false
                                        ? _captureHoleWidth - 30
                                        : 0,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.destructiveRed,
                                      borderRadius: BorderRadius.circular(
                                          widget.searchLoading == false
                                              ? 20
                                              : 100),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          curve: Curves.ease,
                          opacity: widget.cameraIsVisible ? 1 : 0,
                          duration: Duration(milliseconds: 2000),
                          child: Center(
                            child: Container(
                              height: _captureHoleHeight,
                              width: _captureHoleWidth,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: RotatedBox(
                                      quarterTurns: 0,
                                      child:
                                          Corner(loading: widget.searchLoading),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: RotatedBox(
                                      quarterTurns: 1,
                                      child:
                                          Corner(loading: widget.searchLoading),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: RotatedBox(
                                      quarterTurns: 3,
                                      child:
                                          Corner(loading: widget.searchLoading),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: RotatedBox(
                                      quarterTurns: 2,
                                      child:
                                          Corner(loading: widget.searchLoading),
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    duration: Duration(milliseconds: 200),
                                    opacity: widget.searchLoading ? 1 : 0,
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
          widget.permissionEnabled == true
              ? AnimatedOpacity(
                  opacity: widget.cameraIsVisible == false ? 1 : 0,
                  duration: Duration(milliseconds: 1000),
                  child: Container(
                    height: _viewportHeight - 190,
                    width: _viewportWidth,
                    color: CupertinoColors.darkBackgroundGray,
                  ),
                )
              : SizedBox(),
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
