
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/monster_ability_card.dart';
import 'package:frosthaven_assistant/Model/MonsterAbility.dart';
import 'package:frosthaven_assistant/Resource/scaling.dart';

import '../../Resource/state/monster.dart';


class AbilityCardZoom extends StatefulWidget {
  const AbilityCardZoom(
      {Key? key, required this.card, required this.monster, required this.calculateAll})
      : super(key: key);

  final MonsterAbilityCardModel card;
  final Monster monster;
  final bool calculateAll;

  @override
  AbilityCardZoomState createState() => AbilityCardZoomState();
}

class AbilityCardZoomState extends State<AbilityCardZoom> {

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    double zoomValue = 2.5;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double width = 178 * 0.8 * scale* zoomValue;
    double height = 116 * 0.8 * scale* zoomValue;
    if(screenWidth < 40 + width) {
      zoomValue = (screenWidth-40)/ (178 * 0.8 * scale);// 2;
    }

    if(screenHeight < 60 + height) {
      zoomValue = (screenHeight-60)/ (116 * 0.8 * scale);// 2;
    }

    double scaling = scale * zoomValue;
    if (scaling < 269/(178*0.8) && screenWidth > 40 + width) {
      scaling = 269/(178*0.8);

    }




    return InkWell(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
       // color: Colors.amber,
          //margin: EdgeInsets.all(2 * scale * zoomValue * 0.8),
          //width: width,
          //height: 118 * 0.8 * scale* zoomValue,
          child:MonsterAbilityCardWidget.buildFront(widget.card, widget.monster, scaling, widget.calculateAll)
      ),
    );
  }
}

