import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class CustomPicture extends StatefulWidget {
  const CustomPicture({
    Key? key,
    required this.picture,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  final String picture;
  final Duration duration;

  @override
  _CustomPictureState createState() => _CustomPictureState();
}

class _CustomPictureState extends State<CustomPicture> {
  String? _pictureUrl;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void _getPictureUrl(filename) {
    String url =
        "https://firebasestorage.googleapis.com/v0/b/biolens-ef25c.appspot.com/o/uploads%2F$filename?alt=media";

    setStateIfMounted(() {
      _pictureUrl = url;
    });
  }

  @override
  void initState() {
    String? filename = widget.picture;
    _getPictureUrl(filename);

    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    String? filename = widget.picture;
    _getPictureUrl(filename);

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: _pictureUrl != null
            ? CachedNetworkImage(
                imageUrl: _pictureUrl!,
                fadeInDuration: widget.duration,
                fit: BoxFit.cover,
                errorWidget:
                    (BuildContext context, String string, dynamic dynamic) =>
                        Container(),
              )
            : Container(),
      ),
    );
  }
}
