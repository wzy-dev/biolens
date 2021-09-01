import 'package:flutter/cupertino.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: Border.all(width: 0, color: CupertinoColors.white),
        middle: Text(
          "À propos...",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: CupertinoColors.darkBackgroundGray,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 40, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Simon Wegrzyn",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: 1,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Une question sur le fonctionnement, un bug ou une suggestion ?",
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.systemGrey,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(20),
                      onPressed: () {},
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.mail,
                            color: CupertinoColors.white,
                            size: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 13,
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromRGBO(181, 87, 74, 1),
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(20),
                      onPressed: () {},
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.phone,
                            color: CupertinoColors.white,
                            size: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              "Alexandre Prat",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: 1,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Proposer un nouveau produit ou suggérer une correction ?",
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.systemGrey,
              ),
            ),
            SizedBox(
              height: 13,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(20),
                      onPressed: () {},
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.mail,
                            color: CupertinoColors.white,
                            size: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromRGBO(181, 87, 74, 1),
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(20),
                      onPressed: () {},
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.phone,
                            color: CupertinoColors.white,
                            size: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
