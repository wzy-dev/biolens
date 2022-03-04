import 'package:biolens/models/shelf_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqlbrite/sqlbrite.dart';

class UniversitySelector extends StatefulWidget {
  const UniversitySelector({Key? key}) : super(key: key);

  @override
  State<UniversitySelector> createState() => _UniversitySelectorState();
}

enum Universities { nantes, bordeaux }

class _UniversitySelectorState extends State<UniversitySelector> {
  @override
  void initState() {
    if (MyProvider.getCurrentMode(context, listen: false) == null) {
      Provider.of<BriteDatabase>(context, listen: false).insert("mode", {
        "mode": "all",
        "university": null,
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<University> _universities = Provider.of<List<University>>(context);

    Mode? _mode = MyProvider.getCurrentMode(context);

    if (_mode == null) _mode = Mode(mode: Modes.all);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Color.fromARGB(0, 0, 0, 0),
        systemNavigationBarColor: Color.fromRGBO(255, 255, 255, 1),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.white,
          border: Border.all(width: 0, color: CupertinoColors.white),
          middle: Text(
            "Mode universitaire",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: CupertinoColors.darkBackgroundGray,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        Text(
                          "Le mode universitaire vous permet de filtrer uniquement le plateau technique disponible dans votre centre de soins.",
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        Text(
                          "Des informations spécifiques à votre université seront ajoutées sous chaque produit.",
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Activer le mode universitaire",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.darkBackgroundGray,
                              ),
                            ),
                            Switch(
                                activeColor:
                                    CupertinoTheme.of(context).primaryColor,
                                value: _mode.mode == Modes.university,
                                onChanged: (value) {
                                  Provider.of<BriteDatabase>(context,
                                          listen: false)
                                      .update("mode", {
                                    "mode": !value ? "all" : "university",
                                    "university":
                                        !value ? null : _universities.first.id,
                                  });
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: _universities
                            .map<Widget>(
                              (University university) => RadioListTile<String>(
                                activeColor:
                                    CupertinoTheme.of(context).primaryColor,
                                title: Text(university.name),
                                value: university.id,
                                groupValue: _mode!.university,
                                onChanged: _mode.mode == Modes.university
                                    ? (String? value) {
                                        Provider.of<BriteDatabase>(context,
                                                listen: false)
                                            .update("mode", {
                                          "mode": "university",
                                          "university": university.id
                                        });
                                      }
                                    : null,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
