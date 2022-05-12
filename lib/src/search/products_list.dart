import 'package:biolens/models/shelf_models.dart';
import 'package:biolens/shelf.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class ProductsList extends StatefulWidget {
  const ProductsList(
      {Key? key, required this.searchedList, required this.popAction})
      : super(key: key);

  final SearchedList searchedList;
  final Function popAction;

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  bool _duringPop = false;
  bool _isUniversityMode = false;

  @override
  void initState() {
    Mode? mode = MyProvider.getCurrentMode(context, listen: false);
    if (mode != null) _isUniversityMode = mode.mode == Modes.university;
    super.initState();
  }

  Item _itemBuilder(BuildContext context, int index) {
    Product product = widget.searchedList.listProducts[index];

    return Item(
        product: product,
        index: index,
        length: widget.searchedList.listProducts.length);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            width: double.infinity,
            child: (widget.searchedList.header != null &&
                    widget.searchedList.listProducts.length > 0
                ? Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Text(
                      widget.searchedList.header!,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  )
                : null)),
        Expanded(
          child: ShaderMask(
            shaderCallback: (Rect rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CupertinoColors.white,
                  Color.fromRGBO(0, 0, 0, 0),
                  Color.fromRGBO(0, 0, 0, 0),
                  CupertinoColors.white
                ],
                stops: [0.0, 0.02, 0.98, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstOut,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.metrics.extentAfter -
                            notification.metrics.maxScrollExtent >
                        150 &&
                    !_duringPop) {
                  _duringPop = true;
                  widget.popAction();
                }
                return false;
              },
              child: ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      _itemBuilder(context, index),
                      (index == widget.searchedList.listProducts.length - 1 &&
                              _isUniversityMode)
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Limité aux produits de votre université",
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  );
                },
                itemCount: widget.searchedList.listProducts.length,
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                  height: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Item extends StatefulWidget {
  const Item({
    Key? key,
    required this.product,
    required this.index,
    required this.length,
  }) : super(key: key);

  final Product product;
  final int index;
  final int length;

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  String? _pictureUrl;

  String _getPictureUrl(filename) {
    return "https://firebasestorage.googleapis.com/v0/b/biolens-ef25c.appspot.com/o/uploads%2F$filename?alt=media";
  }

  @override
  Widget build(BuildContext context) {
    String? filename = widget.product.picture;

    _pictureUrl = filename != null ? _getPictureUrl(filename) : null;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () =>
          Navigator.of(context).pushNamed("/product/${widget.product.id}"),
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.fromLTRB(
          0,
          (widget.index == 0 ? 10 : 0),
          0,
          (widget.index == widget.length - 1 ? 10 : 0),
        ),
        decoration: BoxDecoration(
          color: Color.fromRGBO(241, 246, 249, 1),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        height: 100,
        child: Row(
          children: [
            Hero(
              tag: widget.product.id,
              transitionOnUserGestures: true,
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(7),
                  ),
                ),
                height: 80,
                width: 80,
                child: Center(
                  child: _pictureUrl != null
                      ? Padding(
                          padding: EdgeInsets.all(5),
                          child: CachedNetworkImage(
                            imageUrl: _pictureUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (BuildContext context, String string,
                                    dynamic dynamic) =>
                                Container(),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.all(15),
                          child: Image(
                            image: AssetImage("assets/camera_off.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: new TextSpan(
                      children: <TextSpan>[
                        new TextSpan(
                          text: "${widget.product.name.toUpperCase()} ",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.darkBackgroundGray,
                            fontSize: 16,
                          ),
                        ),
                        new TextSpan(
                          text: widget.product.brand,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: CupertinoColors.darkBackgroundGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.product.names.category.toLowerCase() +
                        ' > ' +
                        widget.product.names.subCategory.toLowerCase(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                        color: CupertinoColors.systemGrey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
