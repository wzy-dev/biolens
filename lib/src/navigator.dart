import 'package:biolens/shelf.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';

class MyNavigator {
  static onGenerateRoute({
    required BuildContext context,
    required RouteSettings settings,
  }) {
    late Widget childWidget;
    String? _routeName = settings.name?.replaceFirst("/link", "") ?? null;
    print(settings.name);
    switch (_routeName) {
      case "/":
        childWidget = Homepage();
        break;
      case "/search":
        return PageRouteBuilder(
          pageBuilder: (context, animation, anotherAnimation) => Search(),
          fullscreenDialog: true,
          transitionDuration: Duration(milliseconds: 500),
          reverseTransitionDuration: Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
              curve: Curves.linearToEaseOut,
              parent: animation,
            );
            return SlideTransition(
              position: Tween(
                begin: Offset(0, 1),
                end: Offset(0.0, 0.0),
              ).animate(animation),
              child: child,
            );
          },
        );
      case "/about":
        childWidget = About();
        break;
      case "/select/university":
        childWidget = UniversitySelector();
        break;
      case "/tutorial":
        childWidget = FirstOpen();
        break;
      default:
        if (RegExp("^/product").hasMatch(_routeName ?? "") &&
            (_routeName ?? "").split("/").length > 2) {
          List<String> split = (_routeName ?? "").split("/");
          childWidget = ProductViewer(product: split[2]);
        } else {
          childWidget = Homepage();
        }
        break;
    }

    return CupertinoPageRoute(
      builder: (context) => childWidget,
    );
  }
}
