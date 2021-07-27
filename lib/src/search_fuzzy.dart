// ignore: import_of_legacy_library_into_null_safe
import 'package:fuzzy/fuzzy.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class SearchFuzzy {
  static searchByName({
    required String query,
    // [products, indications, category]
    required List? listSnapshots,
  }) {
    List<Map> _searchListProduct = [];
    List<Map> _searchListIndication = [];
    List<Map> _searchListCategory = [];

    if (listSnapshots == null) return [];

    // Products
    listSnapshots[0].docs.forEach((DocumentSnapshot document) {
      Map _data = (document.data() as Map);
      _searchListProduct.add({..._data, 'id': document.id});
    });

    // Indications
    listSnapshots[1].docs.forEach((DocumentSnapshot document) {
      Map _data = (document.data() as Map);
      _searchListIndication.add({..._data, 'id': document.id});
    });

    // Category
    listSnapshots[2].docs.forEach((DocumentSnapshot document) {
      Map _data = (document.data() as Map);
      _searchListCategory.add({..._data, 'id': document.id});
    });

    var options = FuzzyOptions(
      keys: [
        WeightedKey(
          name: 'name',
          getter: (e) {
            return (e as Map)['name'];
          },
          weight: 1,
        )
      ],
    );

    final fuseProduct = Fuzzy(_searchListProduct, options: options);
    final fuseIndication = Fuzzy(_searchListIndication, options: options);
    final fuseCategory = Fuzzy(_searchListCategory, options: options);

    final List resultProduct = fuseProduct.search(query);
    final List resultIndication = fuseIndication.search(query);
    final List resultCategory = fuseCategory.search(query);

    Map result = {};

    List data = [];

    Map? bestResult;
    List bestResultsList = [
      resultProduct.length > 0
          ? {'collection': 'products', 'data': resultProduct[0]}
          : null,
      resultIndication.length > 0
          ? {'collection': 'indications', 'data': resultIndication[0]}
          : null,
      resultCategory.length > 0
          ? {'collection': 'categories', 'data': resultCategory[0]}
          : null,
    ];
    bestResultsList.removeWhere((element) => element == null);
    bestResultsList.sort((a, b) {
      if (a == null) return 0;
      if (b == null) return 1;
      return a['data'].score.compareTo(b['data'].score);
    });
    if (bestResultsList.length > 0) bestResult = bestResultsList[0];

    const Map correspondence = {
      'indications': 'indications',
      'categories': 'category'
    };
    print(_searchListCategory);
    if (bestResult == null || bestResult['collection'] == 'products') {
      resultProduct.forEach((element) => data.add(element.item));
    } else {
      var item = bestResult['data'].item as Map;

      data = _searchListProduct
          .where((element) => element['ids']
                  [correspondence[bestResult!['collection']]]
              .contains(item['id']))
          .toList();
      result['header'] = item['name'];
    }

    result['data'] = data;

    return result;
  }
}
