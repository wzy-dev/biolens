import 'package:biolens/shelf.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({Key? key, required this.results}) : super(key: key);

  final Map results;

  @override
  Widget build(BuildContext context) {
    _itemBuilder(context, index) {
      Map _data = results['data'][index];

      return Item(
          data: _data, index: index, length: results['data']?.length ?? 0);
    }

    return Column(
      children: [
        Container(
            width: double.infinity,
            child: (results['header'] != null &&
                    results['data'] != null &&
                    results['data'].length > 0
                ? Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Text(
                      results['header'],
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
            child: ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemBuilder: (context, index) => _itemBuilder(context, index),
              itemCount: results['data']?.length ?? 0,
              separatorBuilder: (BuildContext context, int index) => SizedBox(
                height: 20,
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
    required this.data,
    required this.index,
    required this.length,
  }) : super(key: key);

  final Map data;
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
    String? filename = widget.data['picture'];
    if (filename != null) _pictureUrl = _getPictureUrl(filename);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => Product(
            product: widget.data,
          ),
        ),
      ),
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
              tag: widget.data['id'],
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
                padding: EdgeInsets.all(5),
                child: Center(
                  child: _pictureUrl != null
                      ? CachedNetworkImage(
                          imageUrl: _pictureUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (BuildContext context, String string,
                                  dynamic dynamic) =>
                              Container(),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(15),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.data['name'].toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.darkBackgroundGray,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        widget.data['brand'],
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: CupertinoColors.darkBackgroundGray,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.data['names']['category'].toLowerCase() +
                        ' > ' +
                        widget.data['names']['subCategory'].toLowerCase(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
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
