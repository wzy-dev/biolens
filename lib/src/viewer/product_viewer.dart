import 'package:biolens/models/shelf_models.dart';
import 'package:biolens/shelf.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductViewer extends StatefulWidget {
  const ProductViewer({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  State<ProductViewer> createState() => _ProductViewerState();
}

class _ProductViewerState extends State<ProductViewer> {
  ScrollController _scrollController = ScrollController();
  bool _transitionIsRunning = true;
  double? _defaultHeaderHeight;
  double? _headerHeight;
  GlobalKey _headerKey = GlobalKey();
  late List<Tag> _listTagsCollection;

  @override
  void initState() {
    FirebaseAnalytics.instance
        .logScreenView(screenClass: "product", screenName: widget.product.name);

    _listTagsCollection = [...Provider.of<List<Tag>>(context, listen: false)];
    _listTagsCollection.sort((a, b) => a.name.compareTo(b.name));

    Future.delayed(
        Duration(milliseconds: 200), () => _transitionIsRunning = false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Color.fromARGB(0, 0, 0, 0),
        systemNavigationBarColor: Color.fromRGBO(241, 246, 249, 1),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.white,
          border: Border.all(width: 0, color: CupertinoColors.white),
          middle: Text(
            widget.product.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: CupertinoColors.darkBackgroundGray,
            ),
          ),
          padding: const EdgeInsetsDirectional.all(0),
          trailing: Container(
            margin: const EdgeInsets.only(right: 8),
            child: CupertinoButton(
                minSize: 0,
                padding: const EdgeInsets.all(0),
                child: Icon(Icons.clear, size: 30),
                onPressed: () =>
                    Navigator.of(context).popUntil(ModalRoute.withName('/'))),
          ),
        ),
        backgroundColor: Color.fromRGBO(241, 246, 249, 1),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    key: _headerKey,
                    height: _headerHeight,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Hero(
                            tag: widget.product.id,
                            transitionOnUserGestures: true,
                            child: Container(
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              height: 150,
                              width: 150,
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: widget.product.picture == null
                                    ? Image(
                                        image:
                                            AssetImage("assets/camera_off.png"),
                                        fit: BoxFit.cover,
                                      )
                                    : Padding(
                                        padding: EdgeInsets.all(5),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              "https://firebasestorage.googleapis.com/v0/b/biolens-ef25c.appspot.com/o/uploads%2F${widget.product.picture!}?alt=media",
                                          fit: BoxFit.cover,
                                          errorWidget: (BuildContext context,
                                                  String string,
                                                  dynamic dynamic) =>
                                              Container(),
                                        ),
                                      ),
                                // : CustomPicture(
                                //     picture: widget.product['picture'],
                                //   ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: RichText(
                                  text: new TextSpan(
                                    children: [
                                      new TextSpan(
                                        text:
                                            "${widget.product.name.toUpperCase()} ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: CupertinoColors
                                              .darkBackgroundGray,
                                          fontSize: 23,
                                        ),
                                      ),
                                      new TextSpan(
                                        text: widget.product.brand,
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: CupertinoColors
                                              .darkBackgroundGray,
                                        ),
                                      ),
                                      new TextSpan(
                                        text: '\n',
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      new TextSpan(
                                        text: widget.product.names.category
                                                .toLowerCase() +
                                            ' > ' +
                                            widget.product.names.subCategory
                                                .toLowerCase(),
                                        style: TextStyle(
                                            color: CupertinoColors.systemGrey,
                                            fontSize: 17),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (_headerKey.currentContext != null &&
                        !_transitionIsRunning) {
                      // On met un callback pour éviter le warning en cas de setState durant le build
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        RenderBox render = _headerKey.currentContext!
                            .findRenderObject() as RenderBox;
                        if (_defaultHeaderHeight == null) {
                          setState(() {
                            _defaultHeaderHeight = render.size.height;
                          });
                        }

                        double height = _defaultHeaderHeight! -
                            _scrollController.position.pixels;
                        if (height < 0) height = 0;
                        if (height > _defaultHeaderHeight!)
                          height = _defaultHeaderHeight!;

                        setState(() {
                          _headerHeight = height;
                        });
                      });
                    }
                    return true;
                  },
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      GradientList(
                        list: widget.product.names.indications,
                        title: "INDICATIONS",
                        colorBegin: Color.fromRGBO(125, 196, 93, 1),
                        colorEnd: Color.fromRGBO(100, 214, 178, 1),
                        colorTitle: Color.fromRGBO(75, 117, 55, 0.8),
                        icon: Icons.check,
                      ),
                      GradientList(
                        list: widget.product.precautions,
                        title: "PRECAUTIONS",
                        colorBegin: Color.fromRGBO(237, 190, 59, 1),
                        colorEnd: Color.fromRGBO(222, 95, 110, 1),
                        colorTitle: Color.fromRGBO(143, 114, 36, 0.8),
                        icon: Icons.warning_rounded,
                      ),
                      GradientList(
                        list: widget.product.ingredients,
                        title: "COMPOSITION",
                        colorBegin: Color.fromRGBO(134, 219, 224, 1),
                        colorEnd: Color.fromRGBO(121, 143, 219, 1),
                        colorTitle: Color.fromRGBO(73, 120, 122, 0.8),
                        icon: Icons.biotech,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(30, 30, 30, 30),
                        width: double.infinity,
                        child: widget.product.cookbook.length > 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Utilisation",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoTheme.of(context)
                                          .primaryColor,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: widget.product.cookbook
                                        .map<Widget>((element) {
                                      return Container(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: Text(
                                          "• " + element,
                                          style: TextStyle(
                                            color:
                                                Color.fromRGBO(60, 60, 60, 1),
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Source :",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: CupertinoColors.systemGrey,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: CupertinoButton(
                                            minSize: 0,
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.all(0),
                                            onPressed:
                                                widget.product.source != null &&
                                                        Uri.parse(widget.product
                                                                .source!)
                                                            .isAbsolute
                                                    ? () => launch(
                                                        widget.product.source!)
                                                    : null,
                                            child: _drawSource(
                                              name: widget.product.name,
                                              brand: widget.product.brand,
                                              source: widget.product.source,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      ),
                      _drawTagsList(),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  RichText _drawSource(
      {required String name, required String brand, String? source}) {
    return RichText(
      text: new TextSpan(
          style: TextStyle(
              color: source != null && Uri.parse(source).isAbsolute
                  ? CupertinoTheme.of(context).primaryColor
                  : CupertinoColors.systemGrey,
              fontSize: 15),
          children: source != null
              ? Uri.parse(source).isAbsolute
                  ? [
                      new TextSpan(
                        text: "Manuel d'utilisation $name ",
                      ),
                      new TextSpan(
                        text: "($brand)",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ]
                  : [
                      new TextSpan(
                        text: source,
                      ),
                    ]
              : [
                  new TextSpan(
                    text: "Manuel d'utilisation $name ",
                  ),
                  new TextSpan(
                    text: "($brand)",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]),
    );
  }

  Widget _drawTagsList() {
    List<Tag>? listTags = _listTagsCollection
        .where((tag) => widget.product.ids.tags.contains(tag.id))
        .toList();

    if (listTags.length == 0) return SizedBox();

    return Padding(
      padding:
          const EdgeInsets.only(top: 20.0, bottom: 60, left: 15, right: 15),
      child: Wrap(
        spacing: 20,
        runSpacing: 15,
        alignment: WrapAlignment.center,
        children: [
          Text(
            "tags :",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(100, 55, 104, 180),
            ),
          ),
          ...listTags.map<Widget>(
            (tag) {
              return CupertinoButton(
                minSize: 0,
                padding: const EdgeInsets.all(0),
                onPressed: () => showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    context: context,
                    builder: (context) => _modalContentBuilder(
                          context,
                          tag.id,
                          tag.name,
                        )),
                child: Text(
                  tag.name.toLowerCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(100, 129, 144, 167),
                  ),
                ),
              );
            },
          ).toList()
        ],
      ),
    );
  }

  Widget _modalContentBuilder(
      BuildContext context, String tagId, String tagName) {
    List<Product> listProducts = [
      ...Provider.of<List<Product>>(context, listen: false)
    ].where((product) => product.ids.tags.contains(tagId)).toList();
    listProducts.sort((a, b) => a.name.compareTo(b.name));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Column(
        children: [
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Text(
                  tagName,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              )),
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
              child: ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (context, index) {
                  return Item(
                      product: listProducts[index],
                      index: index,
                      length: listProducts.length);
                },
                itemCount: listProducts.length,
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                  height: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientList extends StatelessWidget {
  const GradientList({
    Key? key,
    required this.list,
    required this.colorBegin,
    required this.colorEnd,
    required this.colorTitle,
    required this.title,
    required this.icon,
  }) : super(key: key);

  final List? list;
  final Color colorBegin;
  final Color colorEnd;
  final Color colorTitle;
  final String title;
  final IconData icon;

  List<Widget> _drawList() {
    List<Widget> tmpList = [];

    tmpList.add(
      Container(
        padding: EdgeInsets.fromLTRB(5, 3, 8, 3),
        decoration: BoxDecoration(
          color: colorTitle,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: CupertinoColors.white,
            ),
            SizedBox(
              width: 3,
            ),
            Text(
              title,
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );

    list!.forEach((element) {
      tmpList.add(
        Container(
          margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Text(
            "• " + element,
            style: TextStyle(
              color: Color.fromRGBO(60, 60, 60, 1),
              fontSize: 16,
            ),
          ),
        ),
      );
    });
    return tmpList;
  }

  @override
  Widget build(BuildContext context) {
    if (list == null || list!.length == 0) return Container();

    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 12),
      margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorBegin, colorEnd]),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _drawList(),
      ),
    );
  }
}
