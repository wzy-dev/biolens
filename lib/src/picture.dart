import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';

class Picture {
  static Future<String> getDownloadUrl({required String filename}) async {
    return await FirebaseStorage.instance
        .ref('uploads/' + filename)
        .getDownloadURL();
  }
}

// class Picture extends StatefulWidget {
//   const Picture(
//       {Key? key, required this.filename, this.size = 100, this.cacheAction})
//       : super(key: key);

//   final String filename;
//   final double size;
//   final Function? cacheAction;

//   @override
//   _PictureState createState() => _PictureState();
// }

// class _PictureState extends State<Picture> {
//   FadeInImage? _picture;

//   @override
//   void initState() {
//     super.initState();
//     print('h');
//     _downloadImage(widget.filename);
//   }

//   void setStateIfMounted(f) {
//     if (mounted) setState(f);
//   }

//   Future<void> _downloadImage(String filename) async {
//     String downloadURL = await FirebaseStorage.instance
//         .ref('uploads/' + filename)
//         .getDownloadURL();

//     print(widget.cacheAction);
//     setStateIfMounted(() {
//       _picture = FadeInImage.memoryNetwork(
//         image: downloadURL,
//         placeholder: kTransparentImage,
//         width: widget.size - 40,
//         height: widget.size - 40,
//         fit: BoxFit.cover,
//       );
//     });
//     if (widget.cacheAction != null) {
//       Widget cache = FadeInImage.memoryNetwork(
//         image: downloadURL,
//         placeholder: kTransparentImage,
//         width: widget.size - 40,
//         height: widget.size - 40,
//         fit: BoxFit.cover,
//       );
//       print(cache);
//       widget.cacheAction!(cache);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(child: _picture != null ? _picture! : Container());
//   }
// }
