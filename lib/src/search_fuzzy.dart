// ignore: import_of_legacy_library_into_null_safe
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class BestResultList {
  const BestResultList({this.products, this.tags});

  final Map<String, dynamic>? products;
  final Map<String, dynamic>? tags;
}

class SearchFuzzy {
  static Map searchByName({
    required String query,
    // [products, tags]
    required List? listSnapshots,
  }) {
    List<Map> _searchListProduct = [];
    List<Map> _searchListTag = [];

    if (listSnapshots == null) return {};

    // Products
    listSnapshots[0].docs.forEach((DocumentSnapshot document) {
      Map _data = (document.data() as Map);
      _searchListProduct.add({..._data, 'id': document.id});
    });

    // Tag
    listSnapshots[1].docs.forEach((DocumentSnapshot document) {
      Map _data = (document.data() as Map);
      _searchListTag.add({..._data, 'id': document.id});
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
    final fuseTag = Fuzzy(_searchListTag, options: options);

    final List<Result> resultProduct = fuseProduct.search(query);
    final List<Result> resultTag = fuseTag.search(query);

    Map result = {};

    List data = [];

    Map? bestResult;
    BestResultList bestResultsList = BestResultList(
      products: resultProduct.length > 0
          ? {
              'collection': 'products',
              'data': resultProduct[0],
              'score': resultProduct[0].score
            }
          : null,
      tags: resultTag.length > 0
          ? {
              'collection': 'tags',
              'data': resultTag[0],
              'score': resultTag[0].score
            }
          : null,
    );

    if (query == "") {
      bestResult = bestResultsList.products;
    } else if (bestResultsList.products != null) {
      if (bestResultsList.tags != null) {
        if (bestResultsList.products!["score"] <
            bestResultsList.tags!["score"]) {
          bestResult = bestResultsList.products;
        } else {
          bestResult = bestResultsList.tags;
        }
      } else {
        bestResult = bestResultsList.products;
      }
    } else if (bestResultsList.tags != null) {
      bestResult = bestResultsList.tags;
    }

    const Map correspondence = {
      'indications': 'indications',
      'categories': 'category',
      'tags': 'tags'
    };

    if (bestResult == null || bestResult['collection'] == 'products') {
      resultProduct.forEach((element) => data.add(element.item));
    } else {
      Map item = bestResult['data'].item as Map;

      data = _searchListProduct.where((element) {
        if (element['ids'][correspondence[bestResult!['collection']]] == null)
          return false;
        return element['ids'][correspondence[bestResult['collection']]]
            .contains(item['id']);
      }).toList();

      if (data.length == 0 && bestResult['collection'] == 'tags') {
        resultProduct.forEach((element) => data.add(element.item));
      } else {
        result['header'] = item['name'];
      }
    }

    result['data'] = data;

    return result;
  }
}
