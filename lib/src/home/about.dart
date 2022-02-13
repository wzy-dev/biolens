import 'package:biolens/shelf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Color.fromARGB(0, 0, 0, 0),
        systemNavigationBarColor: Color.fromRGBO(255, 255, 255, 1),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.white,
          border: Border.all(width: 0, color: CupertinoColors.white),
          middle: Text(
            "Contact et confidentialité",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: CupertinoColors.darkBackgroundGray,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: CupertinoButton(
                    color: Color.fromRGBO(167, 49, 129, 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.info_circle_fill),
                        SizedBox(width: 8),
                        Text("Revoir le tutoriel",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    onPressed: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => FirstOpen(),
                          ),
                        )),
              ),
              AnswerBlock(
                answer: "À quoi sert biolens ?",
                replies: [
                  "L'application biolens a été développée dans le cadre d'une thèse d'exercice à la faculté de chirurgie-dentaire de Nantes.",
                  "Cette dernière a pour but de fournir aux étudiants en odontologie un outil pédagogique et pratique afin d'utiliser au mieux les différents biomatériaux et produits mis à leur disposition.",
                ],
              ),
              AnswerBlock(
                answer: "Comment trouver un produit ?",
                replies: [
                  "Il existe de multiples manières de trouver le produit qui répondra à vos besoins sur biolens. Un scan rapide de l'étiquette permettra d'accéder le plus rapidement aux informations.",
                  "Un moteur de recherche est aussi présent et vous permettra de retrouver tous les produits répondant à une indication, en fonction de leur catégorie ou encore grace à leur nom !"
                ],
              ),
              AnswerBlock(
                answer: "Une connexion Internet est-elle nécessaire ?",
                replies: [
                  "Une connexion Internet est indispensable lors de la première connexion afin d'initialiser la base de données des produits.",
                  "La connexion Internet est ensuite facultative à l'usage et n'intervient qu'au démarrage de l'application afin de vérifier que de nouveaux produits n'ont pas été rajoutés."
                ],
              ),
              AnswerBlock(
                answer: "Quid de la confidentialité ?",
                replies: [
                  "L'application biolens est entièrement gratuite et n'effectue aucun suivi à des fins publicitaires.",
                  "Toutes les images capturées via le scanner sont traitées localement sur l'appareil de l'utilisateur et aucune image n'est sauvegardée ou analysée sur Internet.",
                  "Afin d'étudier l'adhésion des utilisateurs, l'application peut utiliser des trackers afin de récuperer des données anonymes (nombre d'utilisateur journalier, pourcentage de nouveaux utilisateurs, durée de la visite...). Ces données anonymisées ne peuvent et ne sont pas utilisées à des fins publicitaires par biolens ou des tiers."
                ],
              ),
              AnswerBlock(
                answer: "Comment me contacter ?",
                replies: [
                  "Une question, un bug, une erreur ou encore une suggestion ? N'hésitez pas à me contacter en suivant les liens ci-dessous :"
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: CupertinoTheme.of(context).primaryColor,
                      ),
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(20),
                        onPressed: () =>
                            launch("mailto:wegrzyn.simon@gmail.com"),
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
                  // Expanded(
                  //   flex: 1,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.all(Radius.circular(10)),
                  //       color: Color.fromRGBO(181, 87, 74, 1),
                  //     ),
                  //     child: CupertinoButton(
                  //       padding: const EdgeInsets.all(20),
                  //       onPressed: () => launch("sms:33620905177"),
                  //       child: Column(
                  //         children: [
                  //           Icon(
                  //             CupertinoIcons.phone,
                  //             color: CupertinoColors.white,
                  //             size: 50,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnswerBlock extends StatelessWidget {
  const AnswerBlock({
    Key? key,
    required this.answer,
    required this.replies,
  }) : super(key: key);

  final String answer;
  final List<String> replies;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              children: [
                Container(
                  width: 10,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: CupertinoTheme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    answer,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      letterSpacing: 1,
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: replies
                  .map(
                    (reply) => Column(
                      children: [
                        Text(
                          reply,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.8,
                            color: CupertinoColors.darkBackgroundGray,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
