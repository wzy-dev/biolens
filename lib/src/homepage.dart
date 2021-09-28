import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:biolens/shelf.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_indicator/loading_indicator.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  bool _cameraIsVisible = false;
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

      MyVision.recognitionByFile(fileResized).then((value) {
        setState(() {
          _searchLoading = false;
        });
        if (value == null) return;
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => Product(
              product: value,
            ),
          ),
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

  Widget _drawCamera() {
    if (_notification == AppLifecycleState.inactive) {
      setState(() {
        _cameraIsVisible = false;
      });
      return Container();
    } else {
      return AnimatedOpacity(
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
                  duration: Duration(milliseconds: _searchLoading ? 200 : 1000),
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
                                  CupertinoTheme.of(context).primaryColor
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
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: CupertinoButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => About(),
                  ),
                ),
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
                      onPressed: _searchLoading ? null : () => _toScan(),
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, anotherAnimation) =>
                              Search(),
                          fullscreenDialog: true,
                          reverseTransitionDuration:
                              Duration(milliseconds: 350),
                          transitionDuration: Duration(milliseconds: 500),
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
