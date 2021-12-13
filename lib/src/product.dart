import 'package:biolens/shelf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Product extends StatefulWidget {
  const Product({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Map product;

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  ScrollController _scrollController = ScrollController();

  double? _defaultHeaderHeight;
  double? _headerHeight;
  GlobalKey _headerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: Border.all(width: 0, color: CupertinoColors.white),
        middle: Text(
          widget.product['name'].toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: CupertinoColors.darkBackgroundGray,
          ),
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
                          tag: widget.product['id'] ?? "nohero",
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
                            padding: EdgeInsets.all(10),
                            child: Center(
                                child: widget.product['picture'] == null
                                    ? Image(
                                        image:
                                            AssetImage("assets/camera_off.png"),
                                        fit: BoxFit.cover,
                                      )
                                    : CustomPicture(
                                        picture: widget.product['picture'],
                                      )),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: RichText(
                                      text: new TextSpan(
                                        children: <TextSpan>[
                                          new TextSpan(
                                            text:
                                                "${widget.product['name'].toUpperCase()} ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: CupertinoColors
                                                  .darkBackgroundGray,
                                              fontSize: 23,
                                            ),
                                          ),
                                          new TextSpan(
                                            text: widget.product['brand'],
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: CupertinoColors
                                                  .darkBackgroundGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.product['names']['category']
                                          .toLowerCase() +
                                      ' > ' +
                                      widget.product['names']['subCategory']
                                          .toLowerCase(),
                                  style: TextStyle(
                                      color: CupertinoColors.systemGrey,
                                      fontSize: 17),
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
            ),
            Expanded(
              child: NotificationListener(
                onNotification: (notification) {
                  if (_headerKey.currentContext != null) {
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
                      list: widget.product['names']['indications'],
                      title: "INDICATIONS",
                      colorBegin: Color.fromRGBO(125, 196, 93, 1),
                      colorEnd: Color.fromRGBO(100, 214, 178, 1),
                      colorTitle: Color.fromRGBO(75, 117, 55, 0.8),
                      icon: Icons.check,
                    ),
                    GradientList(
                      list: widget.product['precautions'],
                      title: "PRECAUTIONS",
                      colorBegin: Color.fromRGBO(237, 190, 59, 1),
                      colorEnd: Color.fromRGBO(222, 95, 110, 1),
                      colorTitle: Color.fromRGBO(143, 114, 36, 0.8),
                      icon: Icons.warning_rounded,
                    ),
                    GradientList(
                      list: widget.product['ingredients'],
                      title: "COMPOSITION",
                      colorBegin: Color.fromRGBO(134, 219, 224, 1),
                      colorEnd: Color.fromRGBO(121, 143, 219, 1),
                      colorTitle: Color.fromRGBO(73, 120, 122, 0.8),
                      icon: Icons.biotech,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(30, 30, 30, 0),
                      width: double.infinity,
                      child: widget.product['cookbook'] != null &&
                              widget.product['cookbook'].length > 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Utilisation",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: widget.product['cookbook']
                                      .map<Widget>((element) {
                                    return Container(
                                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                      child: Text(
                                        "• " + element,
                                        style: TextStyle(
                                          color: Color.fromRGBO(60, 60, 60, 1),
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              ],
                            )
                          : Container(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
