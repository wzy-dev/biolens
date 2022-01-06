import 'package:biolens/shelf.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  FocusNode _focusSearch = FocusNode();
  List? _listSnapshots;
  bool _visible = false;
  Map _searchResults = {};
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance
        .logScreenView(screenClass: "search", screenName: "search");

    List<Future> query = [
      FirebaseFirestore.instance
          .collection('products')
          .where("enabled", isEqualTo: true)
          .orderBy("name")
          .get(),
      // FirebaseFirestore.instance
      //     .collection('indications')
      //     .where("enabled", isEqualTo: true)
      //     .orderBy("name")
      //     .get(),
      // FirebaseFirestore.instance
      //     .collection('categories')
      //     .where("enabled", isEqualTo: true)
      //     .orderBy("name")
      //     .get(),
      FirebaseFirestore.instance
          .collection('tags')
          .where("enabled", isEqualTo: true)
          .orderBy("name")
          .get(),
    ];

    Future.wait(query).then((listSnapshot) {
      _listSnapshots = listSnapshot;
      setState(() {
        _searchResults =
            SearchFuzzy.searchByName(query: '', listSnapshots: _listSnapshots);
      });
    });

    Future.delayed(const Duration(milliseconds: 550), () {
      _focusSearch.requestFocus();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  void dispose() {
    _focusSearch.dispose();

    super.dispose();
  }

  void _popAction() {
    FirebaseAnalytics.instance.logSearch(searchTerm: _searchController.text);
    setState(() {
      _visible = false;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_searchController.text.length > 0) {
          FirebaseAnalytics.instance
              .logSearch(searchTerm: _searchController.text);
          setState(() {
            _searchController.text = "";
            _searchResults = SearchFuzzy.searchByName(
                query: "", listSnapshots: _listSnapshots);
          });
        } else {
          _popAction();
        }
        return false;
      },
      child: CupertinoPageScaffold(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(35, 20, 35, 0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'search',
                        transitionOnUserGestures: true,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          child: CupertinoTextField(
                            autocorrect: false,
                            enableSuggestions: false,
                            keyboardType: TextInputType.name,
                            focusNode: _focusSearch,
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchResults = SearchFuzzy.searchByName(
                                    query: value,
                                    listSnapshots: _listSnapshots);
                              });
                            },
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              color: CupertinoColors.systemGrey6,
                            ),
                            prefix: Padding(
                              padding: EdgeInsets.fromLTRB(20, 20, 15, 20),
                              child: Icon(
                                CupertinoIcons.search,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            suffix: Padding(
                              padding: EdgeInsets.fromLTRB(15, 20, 20, 20),
                              child: _searchController.text.length > 0
                                  ? CupertinoButton(
                                      padding: const EdgeInsets.all(0),
                                      onPressed: () => setState(() {
                                        _searchController.text = "";
                                        _searchResults =
                                            SearchFuzzy.searchByName(
                                                query: _searchController.text,
                                                listSnapshots: _listSnapshots);
                                      }),
                                      child: Icon(
                                        CupertinoIcons.multiply,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    )
                                  : SizedBox(),
                            ),
                            placeholder: "Rechercher",
                            placeholderStyle: TextStyle(
                              fontSize: 18,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: AnimatedPadding(
                          duration: Duration(milliseconds: 300),
                          padding:
                              EdgeInsets.fromLTRB(0, (_visible ? 0 : 20), 0, 0),
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: (_visible ? 1 : 0),
                            child: ProductsList(
                                results: _searchResults, popAction: _popAction),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  onPressed: () => _popAction(),
                  child: Text("Retourner au scanner"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
