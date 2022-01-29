import 'package:biolens/models/products/products.dart';
import 'package:biolens/models/tags/tags.dart';
import 'package:biolens/shelf.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ListItemsSearchable {
  const ListItemsSearchable({this.products = const [], this.tags = const []});

  final List<Product> products;
  final List<Tag> tags;
}

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  FocusNode _focusSearch = FocusNode();
  bool _itemsAreVisible = false;
  late SearchedList _searchedResults;
  TextEditingController _searchController = TextEditingController();
  late ListItemsSearchable _listItemsSearchable;

  @override
  void initState() {
    super.initState();

    FirebaseAnalytics.instance
        .logScreenView(screenClass: "search", screenName: "search");

    // On affiche le clavier après un léger délais
    Future.delayed(const Duration(milliseconds: 550), () {
      _focusSearch.requestFocus();
    });

    // On affiche les éléments après un délais pour les fades
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _itemsAreVisible = true;
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

    // Fade out des items si on pop
    setState(() {
      _itemsAreVisible = false;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    // On crée la liste des produits avec un listener et on la trie par nom
    List<Product> listProducts = [
      ...Provider.of<List<Product>>(context, listen: true)
    ];
    listProducts.sort((a, b) => a.name.compareTo(b.name));

    // On crée la liste des tags avec un listener et on la trie par nom
    List<Tag> listTags = [...Provider.of<List<Tag>>(context, listen: true)];
    listTags.sort((a, b) => a.name.compareTo(b.name));

    // On associes ces deux listes au sein d'un object ListItemsSearchable
    _listItemsSearchable = ListItemsSearchable(
      products: listProducts,
      tags: listTags,
    );

    // On exécute la recherche en fonction de la query actuelle
    // Au premier build query = "" > Tous les items sont affichés
    _searchedResults = SearchFuzzy.searchByName(
        query: _searchController.text,
        listItemsSearchable: _listItemsSearchable);

    return WillPopScope(
      onWillPop: () async {
        // Si on pop alors que le champs n'est pas vierge on le vide avant tout et on stop le pop
        if (_searchController.text.length > 0) {
          FirebaseAnalytics.instance
              .logSearch(searchTerm: _searchController.text);
          setState(() {
            _searchController.text = "";
            _searchedResults = SearchFuzzy.searchByName(
                query: "", listItemsSearchable: _listItemsSearchable);
          });
        } else {
          _popAction();
        }
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Color.fromARGB(0, 0, 0, 0),
          systemNavigationBarColor: Color.fromRGBO(255, 255, 255, 1),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
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
                                // Quand on tape du text on met à jours les résultats
                                setState(() {
                                  _searchedResults = SearchFuzzy.searchByName(
                                      query: value,
                                      listItemsSearchable:
                                          _listItemsSearchable);
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
                                          // Quand on clique sur la croix du champs de recherche on réinitialise le champs et on effectue une recherche vide pour réafficher tous les produits
                                          _searchController.text = "";
                                          _searchedResults =
                                              SearchFuzzy.searchByName(
                                                  query: _searchController.text,
                                                  listItemsSearchable:
                                                      _listItemsSearchable);
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
                            padding: EdgeInsets.fromLTRB(
                                0, (_itemsAreVisible ? 0 : 20), 0, 0),
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: (_itemsAreVisible ? 1 : 0),
                              child: ProductsList(
                                searchedList: _searchedResults,
                                popAction: _popAction,
                              ),
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
      ),
    );
  }
}
