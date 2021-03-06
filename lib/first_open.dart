import 'package:biolens/models/shelf_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextStyle textStyle = TextStyle(
  fontWeight: FontWeight.w200,
  fontSize: 18,
  color: CupertinoColors.white,
);

class FirstOpen extends StatefulWidget {
  const FirstOpen({
    Key? key,
    this.finishTutorial,
    this.initializationStep = InitializationStep.success,
    this.initializer,
    this.logger,
  }) : super(key: key);

  final void Function()? finishTutorial;
  final void Function()? initializer;
  final void Function()? logger;
  final InitializationStep initializationStep;

  @override
  State<FirstOpen> createState() => _FirstOpenState();
}

class _FirstOpenState extends State<FirstOpen> {
  int _pageNumber = 0;

  @override
  Widget build(BuildContext context) {
    // Pour la barre de navigation
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Color.fromARGB(0, 0, 0, 0),
        systemNavigationBarColor: Color.fromRGBO(65, 123, 209, 1),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: CupertinoPageScaffold(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(65, 123, 209, 1),
                CupertinoTheme.of(context).primaryColor,
                Color.fromRGBO(167, 49, 129, 1)
              ],
              stops: [0, 0.4, 1],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Contenu du haut
                Expanded(
                  child: Stack(
                    children: [
                      ContentTutorialFirst(pageNumber: _pageNumber),
                      _drawCarousselItemWithPicture(
                        pageIndex: 1,
                        child: ContentTutorialSecond(pageNumber: _pageNumber),
                        imageName: "assets/mockupscan.png",
                      ),
                      _drawCarousselItemWithPicture(
                        pageIndex: 2,
                        child: ContentTutorialThird(pageNumber: _pageNumber),
                        imageName: "assets/mockupsearch.png",
                      ),
                      _drawCarousselItemWithPicture(
                        pageIndex: 3,
                        child: ContentTutorialFourth(pageNumber: _pageNumber),
                        imageName: "assets/mockupproduct.png",
                      ),
                      _drawCarousselItemWithPicture(
                        pageIndex: 4,
                        child: ContentTutorialFifth(pageNumber: _pageNumber),
                        imageName: "assets/mockuptag.png",
                      ),
                    ],
                  ),
                ),
                // Bouton du bas
                Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 25),
                    child: CupertinoButton(
                        padding: EdgeInsets.all(8),
                        color: CupertinoTheme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            AnimatedButtonContentTutorial(
                              currentPage: _pageNumber,
                              pageIndex: 0,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Commencer la visite",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_right,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            AnimatedButtonContentTutorial(
                              currentPage: _pageNumber,
                              pageIndex: 1,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Rechercher",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_right,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            AnimatedButtonContentTutorial(
                              currentPage: _pageNumber,
                              pageIndex: 2,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Apprendre",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_right,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            AnimatedButtonContentTutorial(
                              currentPage: _pageNumber,
                              pageIndex: 3,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "D??couvrir",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_right,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            AnimatedButtonContentTutorial(
                              currentPage: _pageNumber,
                              pageIndex: 4,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.initializationStep ==
                                                InitializationStep
                                                    .initializationError ||
                                            widget.initializationStep ==
                                                InitializationStep.loginError
                                        ? "R??essayer de se connecter"
                                        : "Terminer la visite",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  AnimatedSwitcher(
                                    duration: Duration(
                                      milliseconds: 200,
                                    ),
                                    child: widget.initializationStep ==
                                            InitializationStep.success
                                        ? Icon(
                                            CupertinoIcons.check_mark,
                                            size: 20,
                                          )
                                        : widget.initializationStep ==
                                                    InitializationStep
                                                        .initializationError ||
                                                widget.initializationStep ==
                                                    InitializationStep
                                                        .loginError
                                            ? Icon(
                                                CupertinoIcons
                                                    .wifi_exclamationmark,
                                                size: 20,
                                              )
                                            : Theme(
                                                data: ThemeData(
                                                  cupertinoOverrideTheme:
                                                      CupertinoThemeData(
                                                          brightness:
                                                              Brightness.dark),
                                                ),
                                                child:
                                                    CupertinoActivityIndicator(),
                                              ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          // Si on est sur la derni??re page et qu'on appuie
                          if (_pageNumber == 4) {
                            // Si l'initialisation n'est pas termin??e
                            if (widget.initializationStep !=
                                InitializationStep.success) {
                              if (widget.initializationStep ==
                                      InitializationStep.initializationError &&
                                  widget.initializer != null) {
                                // Si l'initialisation de Firebase a ??chou??
                                widget.initializer!();
                              } else if (widget.initializationStep ==
                                      InitializationStep.loginError &&
                                  widget.logger != null) {
                                // Si Firebase a r??ussi mais que le log a ??chou??
                                widget.logger!();
                              }
                              return null;
                            }

                            // On note dans les pr??f??rences que le tutoriel a ??t?? lu
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("tutorialReaded", true);

                            // Si la fonction de fin de tutoriel est transmise (appel depuis le main.dart) on l'??x??cute pour rejoindre le bon CupertinoApp
                            // Sinon (appel depuis l'about), simple pop
                            if (widget.finishTutorial != null) {
                              widget.finishTutorial!();
                            } else {
                              Navigator.of(context).pop();
                            }
                          } else {
                            // Sinon on incr??mente juste d'une page
                            setState(() {
                              _pageNumber++;
                            });
                          }
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Contenu avec l'image utilis?? par toutes les pages hormis la premi??re
  AnimatedOpacity _drawCarousselItemWithPicture(
      {required int pageIndex,
      required Widget child,
      required String imageName}) {
    return AnimatedOpacity(
      opacity: _pageNumber > 0 ? 1 : 0,
      duration: Duration.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 65, horizontal: 25),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 600),
              opacity: _pageNumber >= pageIndex ? 1 : 0,
              child: Container(
                width: double.infinity,
                child: Image(
                  image: AssetImage(imageName),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContentTutorialFifth extends StatelessWidget {
  const ContentTutorialFifth({
    Key? key,
    required int pageNumber,
  })  : _pageNumber = pageNumber,
        super(key: key);

  final int _pageNumber;

  @override
  Widget build(BuildContext context) {
    return AnimatedContentTutorial(
      currentPage: _pageNumber,
      pageIndex: 4,
      child: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "D??couvrez".toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 25,
                        letterSpacing: 4,
                        wordSpacing: 13,
                        color: CupertinoColors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "A la fin de chaque fiche produit se trouve une liste de tags pour retrouver des alternatives ?? celui que vous ??tes en train d'??tudier.",
                      style: textStyle,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "De nouvelles fiches produits et de nouvelles fonctionnalit??s seront ajout??es progressivement, pensez ?? y jeter un ??il r??guli??rement !",
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentTutorialFourth extends StatelessWidget {
  const ContentTutorialFourth({
    Key? key,
    required int pageNumber,
  })  : _pageNumber = pageNumber,
        super(key: key);

  final int _pageNumber;

  @override
  Widget build(BuildContext context) {
    return AnimatedContentTutorial(
      currentPage: _pageNumber,
      pageIndex: 3,
      child: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Apprenez".toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 25,
                        letterSpacing: 4,
                        wordSpacing: 13,
                        color: CupertinoColors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Chaque fiche est structur??e selon le m??me mod??le pour retrouver facilement une information.",
                      style: textStyle,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Toutes les donn??es des fiches produits sont issues des modes d'emploi des fabricants.",
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentTutorialThird extends StatelessWidget {
  const ContentTutorialThird({
    Key? key,
    required int pageNumber,
  })  : _pageNumber = pageNumber,
        super(key: key);

  final int _pageNumber;

  @override
  Widget build(BuildContext context) {
    return AnimatedContentTutorial(
      currentPage: _pageNumber,
      pageIndex: 2,
      child: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recherchez".toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 25,
                        letterSpacing: 4,
                        wordSpacing: 13,
                        color: CupertinoColors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Utilisez l'onglet recherche pour retrouver un produit en utilisant son nom, sa cat??gorie ou son indication.",
                      style: textStyle,
                    ),
                    SizedBox(height: 15),
                    RichText(
                      text: new TextSpan(
                        children: [
                          new TextSpan(
                            text: "Par exemple, tapez ",
                          ),
                          new TextSpan(
                            text: "\"scellement\" ",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          new TextSpan(
                            text:
                                "pour retrouver tous les ciments de scellement, ",
                          ),
                          new TextSpan(
                            text: "\"zoe\" ",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          new TextSpan(
                            text:
                                "pour retrouver tous les mat??riaux ?? base d'Oxide de zinc/Eug??nol ou directement ",
                          ),
                          new TextSpan(
                            text: "\"Unifast\".",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentTutorialSecond extends StatelessWidget {
  const ContentTutorialSecond({
    Key? key,
    required int pageNumber,
  })  : _pageNumber = pageNumber,
        super(key: key);

  final int _pageNumber;

  @override
  Widget build(BuildContext context) {
    return AnimatedContentTutorial(
      currentPage: _pageNumber,
      pageIndex: 1,
      child: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Scannez".toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 25,
                        letterSpacing: 4,
                        wordSpacing: 13,
                        color: CupertinoColors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Une analyse facile, rapide et hors ligne ?? partir de l'??tiquette de votre produit.",
                      style: textStyle,
                    ),
                    SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: new Text(
                              "Pour un scan efficace, v??rifiez que :",
                              style: textStyle),
                        ),
                        SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: new Text("???", style: textStyle),
                            ),
                            Expanded(
                              child: new Text(
                                "le nom du produit est lisible sur votre capture",
                                style: textStyle.copyWith(
                                  fontWeight: FontWeight.w300,
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
                              child: new Text("???", style: textStyle),
                            ),
                            Expanded(
                              child: new Text(
                                "le produit est pr??sent dans l'onglet recherche de biolens",
                                style: textStyle.copyWith(
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      "N'oubliez pas que vous pouvez aussi scanner les codes QR g??n??r??s dans l'onglet partage de l'application !",
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentTutorialFirst extends StatefulWidget {
  const ContentTutorialFirst({
    Key? key,
    required int pageNumber,
  })  : _pageNumber = pageNumber,
        super(key: key);

  final int _pageNumber;

  @override
  State<ContentTutorialFirst> createState() => _ContentTutorialFirstState();
}

class _ContentTutorialFirstState extends State<ContentTutorialFirst> {
  final double _multiplyWidth = 0.65;
  bool _svgIsDrawing = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
        Duration(milliseconds: 300),
        () => setState(() => _svgIsDrawing = true)));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContentTutorial(
      currentPage: widget._pageNumber,
      pageIndex: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * _multiplyWidth + 13 > 500
                ? 513
                : MediaQuery.of(context).size.width * _multiplyWidth + 13,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "Bienvenue sur".toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 25,
                  letterSpacing: 4,
                  wordSpacing: 13,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 25),
          AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: _svgIsDrawing ? 1 : 0,
            child: SvgPicture.asset(
              'assets/logo.svg',
              width: MediaQuery.of(context).size.width * _multiplyWidth > 500
                  ? 500
                  : MediaQuery.of(context).size.width * _multiplyWidth,
              placeholderBuilder: (context) => Container(
                height: MediaQuery.of(context).size.width *
                    _multiplyWidth *
                    (332 / 1024),
              ),
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedContentTutorial extends StatelessWidget {
  const AnimatedContentTutorial({
    Key? key,
    required this.currentPage,
    required this.pageIndex,
    required this.child,
  }) : super(key: key);

  final int currentPage;
  final int pageIndex;
  final Widget child;
  // Pour moduler la vitesse de l'animation
  final double _multiplyAnimation = 1.4;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: (400 * _multiplyAnimation).round()),
      left: currentPage == pageIndex
          ? 0
          : currentPage < pageIndex
              ? MediaQuery.of(context).size.width
              : -MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      top: 0,
      bottom: 0,
      child: child,
    );
  }
}

class AnimatedButtonContentTutorial extends StatefulWidget {
  const AnimatedButtonContentTutorial(
      {Key? key,
      required this.currentPage,
      required this.pageIndex,
      required this.child})
      : super(key: key);

  final int currentPage;
  final int pageIndex;
  final Widget child;

  @override
  State<AnimatedButtonContentTutorial> createState() =>
      _AnimatedButtonContentTutorialState();
}

class _AnimatedButtonContentTutorialState
    extends State<AnimatedButtonContentTutorial> {
  // Pour moduler la vitesse de l'animation
  final double _multiplyAnimation = 1.1;
  // On enclenche manuellement le fadeIn pour cr??er un d??lais
  bool _fadeIn = false;

  @override
  Widget build(BuildContext context) {
    // Si on s??lectionne la page courante et que l'animation n'a pas encore ??tait enclench??e
    if (widget.currentPage == widget.pageIndex && !_fadeIn) {
      // On d??clenche le fadeIn apr??s un d??lais
      Future.delayed(Duration(milliseconds: (500 * _multiplyAnimation).round()),
          () => setState(() => _fadeIn = true));
    } else if (widget.currentPage != widget.pageIndex && _fadeIn) {
      // Le fadeOut lui est imm??diat si la page courrante n'est plus active
      setState(() {
        _fadeIn = false;
      });
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: (500 * _multiplyAnimation).round()),
      left: _fadeIn
          ? 0
          : widget.currentPage <= widget.pageIndex
              ? 30
              : -30,
      right: 0,
      top: 0,
      bottom: 0,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: (400 * _multiplyAnimation).round()),
        opacity: _fadeIn ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}
