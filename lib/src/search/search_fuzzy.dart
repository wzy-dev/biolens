import 'package:biolens/models/products/products.dart';
import 'package:biolens/models/tags/tags.dart';
import 'package:biolens/shelf.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';

class BestResult<T> {
  const BestResult(
      {required this.collection, required this.item, required this.score});

  final String collection;
  final T item;
  final double score;
}

class BestResultList {
  const BestResultList({this.products, this.tags});

  final BestResult<Product>? products;
  final BestResult<Tag>? tags;
}

class SearchedList {
  SearchedList({required this.listProducts, this.header});

  List<Product> listProducts;
  String? header;
}

class SearchFuzzy {
  static SearchedList searchByName({
    required String query,
    // ({required this.products, required this.tags})
    required ListItemsSearchable? listItemsSearchable,
  }) {
    // Si aucun produit dans la db
    if (listItemsSearchable == null) return SearchedList(listProducts: []);

    // Recherche dans les produits
    final FuzzyOptions optionProduct = FuzzyOptions(
      keys: [
        WeightedKey<Product>(
          name: 'name',
          getter: (dynamic product) {
            return product.name;
          },
          weight: 1,
        )
      ],
    );
    final Fuzzy fuseProduct =
        Fuzzy(listItemsSearchable.products, options: optionProduct);
    final List<Result<dynamic>> resultsProducts = fuseProduct.search(query);

    // Recherche dans les tags
    final FuzzyOptions optionTag = FuzzyOptions(
      keys: [
        WeightedKey<Tag>(
          name: 'name',
          getter: (dynamic tag) {
            return tag.name;
          },
          weight: 1,
        )
      ],
    );
    final Fuzzy fuseTag = Fuzzy(listItemsSearchable.tags, options: optionTag);
    final List<Result<dynamic>> resultsTags = fuseTag.search(query);

    // On unit le meilleur résultat produit et tag
    BestResultList bestResultsList = BestResultList(
      products: resultsProducts.length > 0
          ? BestResult<Product>(
              collection: "products",
              item: resultsProducts[0].item as Product,
              score: resultsProducts[0].score)
          : null,
      tags: resultsTags.length > 0
          ? BestResult<Tag>(
              collection: "tags",
              item: resultsTags[0].item as Tag,
              score: resultsTags[0].score)
          : null,
    );

    late BestResult? bestResult;
    SearchedList response = SearchedList(listProducts: []);

    // On sélectionne le bestResult (tag OU product) parmis le bestResultList (tag ET product)
    if (query == "") {
      // La recherche est nulle > On affiche des produits
      bestResult = bestResultsList.products;
    } else if (bestResultsList.products != null) {
      if (bestResultsList.tags != null) {
        if (bestResultsList.products!.score < bestResultsList.tags!.score) {
          // Le product a un meilleur score que le tag > On affiche des produits
          bestResult = bestResultsList.products;
        } else {
          // Le tag a un meilleur score que le product > On affiche un tag
          bestResult = bestResultsList.tags;
        }
      } else {
        // On a aucun tag > On affiche des produits
        bestResult = bestResultsList.products;
      }
    } else if (bestResultsList.tags != null) {
      // On a aucun produit > On affiche un tag
      bestResult = bestResultsList.tags;
    }

    if (bestResult == null || bestResult.collection == 'products') {
      // Si on a aucun produit OU qu'on effectue une recherche par produit
      // On ajoute tous les résultats à la réponse
      resultsProducts
          .forEach((result) => response.listProducts.add(result.item));
    } else {
      // Si on effectue une recherche par tag
      // On ajoute tous les produits qui contiennent l'id du tag du bestResult
      response.listProducts = listItemsSearchable.products
          .where((product) => product.ids.tags.contains(bestResult!.item.id))
          .toList();

      if (response.listProducts.length == 0) {
        // Si on a aucun produit de ce tag on ajoute tous les résultats à la réponse
        resultsProducts
            .forEach((result) => response.listProducts.add(result.item));
      } else {
        // Si la recherche par tag présente des résultats on rajoute le nom du tag en header
        response.header = bestResult.item.name;
      }
    }

    return response;
  }
}
