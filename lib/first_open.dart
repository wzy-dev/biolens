import 'package:biolens/shelf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstOpen extends StatefulWidget {
  const FirstOpen({Key? key, this.tutorialReaded, this.loadingFinish = true})
      : super(key: key);

  final Function? tutorialReaded;
  final bool loadingFinish;

  @override
  State<FirstOpen> createState() => _FirstOpenState();
}

class _FirstOpenState extends State<FirstOpen> {
  int _pageNumber = 0;

  @override
  Widget build(BuildContext context) {
    print(widget.loadingFinish);
    return CupertinoPageScaffold(
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
              Expanded(
                child: Stack(
                  children: [
                    ContentTutorialFirst(pageNumber: _pageNumber),
                    ContentTutorialSecond(pageNumber: _pageNumber),
                    ContentTutorialThird(pageNumber: _pageNumber),
                    ContentTutorialFourth(pageNumber: _pageNumber),
                    ContentTutorialFifth(pageNumber: _pageNumber),
                  ],
                ),
              ),
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
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
                                  "Recherchez",
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
                                  "Apprenez",
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
                                  "Découvrez",
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
                                  "Terminez la visite",
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
                                  child: widget.loadingFinish
                                      ? Icon(
                                          CupertinoIcons.check_mark,
                                          size: 20,
                                        )
                                      : Theme(
                                          data: ThemeData(
                                            cupertinoOverrideTheme:
                                                CupertinoThemeData(
                                                    brightness:
                                                        Brightness.dark),
                                          ),
                                          child: CupertinoActivityIndicator(),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        if (_pageNumber == 4) {
                          if (!widget.loadingFinish) return null;
                          print(widget.tutorialReaded);
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool("tutorialReaded", true);

                          if (widget.tutorialReaded != null) {
                            widget.tutorialReaded!();
                          } else {
                            Navigator.of(context).pushReplacement(
                              CupertinoPageRoute(
                                builder: (context) => Homepage(),
                              ),
                            );
                          }
                        } else {
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  child: Image(
                    image: AssetImage("assets/mockuptag.png"),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Découvrez".toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 25,
                          letterSpacing: 4,
                          wordSpacing: 13,
                          color: CupertinoColors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "A la fin de chaque fiche produit se trouve une liste de tags pour retrouver des alternatives à celui que vous êtes en train d'étudiez.",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 18,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  child: Image(
                    image: AssetImage("assets/mockupproduct.png"),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                      SizedBox(height: 10),
                      Text(
                        "Chaque fiche est structurée selon le même modèle pour retrouver facilement une information.",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 18,
                          color: CupertinoColors.white,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        "Toutes les données des fiches produits sont issues des modes d'emploi des fabricants.",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 18,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  child: Image(
                    image: AssetImage("assets/mockupsearch.png"),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                      SizedBox(height: 10),
                      Text(
                        "Utilisez l'onglet recherche pour retrouver un produit en utilisant son nom, sa catégorie ou son indication.",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 18,
                          color: CupertinoColors.white,
                        ),
                      ),
                      SizedBox(height: 7),
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
                                  "pour retrouver tous les matériaux à base d'Oxide de zinc/Eugénol ou directement ",
                            ),
                            new TextSpan(
                              text: "\"Unifast\".",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  child: Image(
                    image: AssetImage("assets/mockupscan.png"),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                      SizedBox(height: 10),
                      Text(
                        "Une analyse facile, rapide et hors ligne à partir de l'étiquette de votre produit.",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 18,
                          color: CupertinoColors.white,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        "Pour un scan efficace, vérifiez bien que le nom du produit est lisible et que le produit est présent dans l'onglet recherche de l'application.",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 18,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContentTutorialFirst extends StatelessWidget {
  const ContentTutorialFirst({
    Key? key,
    required int pageNumber,
  })  : _pageNumber = pageNumber,
        super(key: key);

  final int _pageNumber;

  @override
  Widget build(BuildContext context) {
    return AnimatedContentTutorial(
      currentPage: _pageNumber,
      pageIndex: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Center(
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
          ),
          SizedBox(height: 25),
          SvgPicture.asset(
            'assets/logo.svg',
            width: MediaQuery.of(context).size.width * 0.625,
            color: CupertinoColors.white,
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
  final double _multiplyAnimation = 1.6;

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
  final double _multiplyAnimation = 1.6;
  // On enclenche manuellement le fadeIn pour créer un délais
  bool _fadeIn = false;

  @override
  Widget build(BuildContext context) {
    // Si on sélectionne la page courante et que l'animation n'a pas encore était enclenchée
    if (widget.currentPage == widget.pageIndex && !_fadeIn) {
      // On déclenche le fadeIn après un délais
      Future.delayed(Duration(milliseconds: (500 * _multiplyAnimation).round()),
          () => setState(() => _fadeIn = true));
    } else if (widget.currentPage != widget.pageIndex && _fadeIn) {
      // Le fadeOut lui est immédiat si la page courrante n'est plus active
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
