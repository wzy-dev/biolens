import 'package:flutter/cupertino.dart';
import 'package:biolens/shelf.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Homepage extends StatelessWidget {
  const Homepage({Key? key, this.snapshot, this.camera}) : super(key: key);

  final AsyncSnapshot<QuerySnapshot<Object?>>? snapshot;

  final camera;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Container(
            child: TrainModel(),
            // child: Camera(camera),
            height: MediaQuery.of(context).size.height * 0.8,
            width: double.infinity,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 10,
              // height: 210,
              padding: EdgeInsets.all(35),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 60,
                    child: CupertinoButton(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: Text(
                        'Scanner',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      onPressed: () {},
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, anotherAnimation) =>
                              Search(),
                          fullscreenDialog: true,
                          reverseTransitionDuration:
                              Duration(milliseconds: 350),
                          transitionDuration: Duration(milliseconds: 500),
                          transitionsBuilder:
                              (context, animation, anotherAnimation, child) {
                            animation = CurvedAnimation(
                              curve: Curves.linearToEaseOut,
                              parent: animation,
                            );
                            return SlideTransition(
                              position: Tween(
                                      begin: Offset(0, 1),
                                      end: Offset(0.0, 0.0))
                                  .animate(animation),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'search',
                      transitionOnUserGestures: true,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: CupertinoColors.systemGrey5,
                        ),
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child: Icon(
                                CupertinoIcons.search,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            Text(
                              "Rechercher",
                              style: TextStyle(
                                fontSize: 18,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Color.fromRGBO(241, 246, 249, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
