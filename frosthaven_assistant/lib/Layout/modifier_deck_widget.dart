import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/menus/modifier_card_menu.dart';
import 'package:frosthaven_assistant/Layout/modifier_card.dart';
import 'package:frosthaven_assistant/Resource/commands/draw_modifier_card_command.dart';
import 'package:frosthaven_assistant/Resource/game_state.dart';
import 'package:frosthaven_assistant/Resource/ui_utils.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';

import '../Resource/modifier_deck_state.dart';
import '../Resource/settings.dart';

class ModifierDeckWidget extends StatefulWidget {
  const ModifierDeckWidget({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  ModifierDeckWidgetState createState() => ModifierDeckWidgetState();
}

class ModifierDeckWidgetState extends State<ModifierDeckWidget> {
  final GameState _gameState = getIt<GameState>();
  final Settings settings = getIt<Settings>();

  @override
  void initState() {
    super.initState();

    //to load save state
    _gameState.modelData.addListener(() {
      setState(() {});
    });
  }

  Widget buildStayAnimation(Widget child) {
    return Container(
        margin: EdgeInsets.only(left: 33.3333 * settings.userScalingBars.value),
        child: child);
  }

  Widget buildSlideAnimation(Widget child, Key key) {
    if (!animationsEnabled) {
      return Container(
          margin:
              EdgeInsets.only(left: 33.3333 * settings.userScalingBars.value),
          child: child);
    }
    return Container(
        key: key,
        child: TranslationAnimatedWidget(
            //curve: Curves.slowMiddle,
            animationFinished: (bool finished) {
              if (finished) {
                animationsEnabled = false;
              }
            },
            duration: const Duration(milliseconds: cardAnimationDuration),
            enabled: true,
            curve: Curves.easeIn,
            values: [
              const Offset(0, 0), //left to draw pile
              const Offset(0, 0), //left to draw pile
              Offset(33.3333 * settings.userScalingBars.value, 0), //end
            ],
            child: RotationAnimatedWidget(
                enabled: true,
                values: [
                  Rotation.deg(x: 0, y: 0, z: -15),
                  Rotation.deg(x: 0, y: 0, z: -15),
                  Rotation.deg(x: 0, y: 0, z: 0),
                ],
                duration: const Duration(milliseconds: cardAnimationDuration),
                child: child)));
  }

  static const int cardAnimationDuration = 1200;
  bool animationsEnabled = initAnimationEnabled();

  static bool initAnimationEnabled() {
    if(getIt<Settings>().client.value || getIt<Settings>().server.value && getIt<GameState>().commandIndex.value >= 0 &&
    getIt<GameState>().commandDescriptions[getIt<GameState>().commandIndex.value].contains("modifier card")){
      //also: missing info. need to check for updateForUndo
      return true;
    }
    return false;
  }

  Widget buildDrawAnimation(Widget child, Key key) {
    //compose a translation, scale, rotation + somehow switch widget from back to front
    double width = 58.6666 * settings.userScalingBars.value;
    double height = 40 * settings.userScalingBars.value;

    var screenSize = MediaQuery.of(context).size;
    double xOffset =
        -(screenSize.width / 2 - 63 * settings.userScalingBars.value);
    double yOffset = -(screenSize.height / 2 - height / 2);

    if (!animationsEnabled) {
      return Container(
          child: child);
    }

    return Container(
        key: key,
        //this make it run only once by updating the key once per card. for some reason the translation animation plays anyway
        child: animationsEnabled
            ? TranslationAnimatedWidget(
                animationFinished: (bool finished) {
                  if (finished) {
                    animationsEnabled = false;
                  }
                },
                duration: const Duration(milliseconds: cardAnimationDuration),
                enabled: true,
                values: [
                  Offset(-(width + 2 * settings.userScalingBars.value), 0),
                  //left to draw pile
                  Offset(xOffset, yOffset),
                  //center of screen
                  Offset(xOffset, yOffset),
                  //center of screen
                  Offset(xOffset, yOffset),
                  //center of screen
                  const Offset(0, 0),
                  //end
                ],
                child: ScaleAnimatedWidget(
                    //does nothing
                    enabled: true,
                    duration: const Duration(milliseconds: cardAnimationDuration),
                    values: const [1, 4, 4, 4, 1],
                    child: RotationAnimatedWidget(
                        enabled: true,
                        values: [
                          //Rotation.deg(x: 0, y: 0, z: 0),
                          //Rotation.deg(x:0, y: 0, z: 90),
                          Rotation.deg(x: 0, y: 0, z: 180),
                          //Rotation.deg(x: 0, y: 0, z: 270),
                          Rotation.deg(x: 0, y: 0, z: 360),
                        ],
                        duration: Duration(
                            milliseconds:
                                (cardAnimationDuration * 0.25).ceil()),
                        child: child)))
            : child);
  }

  @override
  Widget build(BuildContext context) {
    ModifierDeck deck = _gameState.modifierDeck;
    if(widget.name == "Allies") {
      deck = _gameState.modifierDeckAllies;
    }

    bool isAnimating =
        false; //is not doing anything now. in case flip animation is added
    return ValueListenableBuilder<double>(
        valueListenable: settings.userScalingBars,
        builder: (context, value, child) {
          return SizedBox(
            width: 153 * settings.userScalingBars.value,
            height: 40 * settings.userScalingBars.value,
            child: ValueListenableBuilder<int>(
                valueListenable: _gameState.commandIndex, //blanket
                builder: (context, value, child) {

                  if (animationsEnabled != true ) {
                    animationsEnabled = initAnimationEnabled();
                  }

                  return Row(
                    children: [
                      InkWell(
                          onTap: () {
                            setState(() {
                              animationsEnabled = true;
                              _gameState.action(DrawModifierCardCommand(widget.name));
                            });
                          },
                          child: Stack(children: [
                            deck.drawPile.isNotEmpty
                                ? ModifierCardWidget(
                                    card: deck.drawPile.peek,
                                    name: deck.name,
                                    revealed: isAnimating)
                                : Container(
                                    width: 58.6666 *
                                        settings.userScalingBars.value,
                                    height: 40 * settings.userScalingBars.value,
                                    color: Color(
                                        int.parse("7A000000", radix: 16))),
                            Positioned(
                                bottom: 0,
                                right: 2 * settings.userScalingBars.value,
                                child: Text(
                                  deck.cardCount.value
                                      .toString(),
                                  style: TextStyle(
                                      fontSize:
                                          12 * settings.userScalingBars.value,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                            offset: Offset(
                                                1 *
                                                    settings
                                                        .userScalingBars.value,
                                                1 *
                                                    settings
                                                        .userScalingBars.value),
                                            color: Colors.black)
                                      ]),
                                ))
                          ])),
                      SizedBox(
                        width: 2 * settings.userScalingBars.value,
                      ),
                      InkWell(
                        //behavior: HitTestBehavior.opaque, //makes tappable when no graphics
                          onTap: () {
                            openDialog(context, ModifierCardMenu(name: deck.name));
                          },
                          child: Stack(children: [

                            deck.discardPile.size() > 2
                            ? buildStayAnimation(
                                RotationTransition(
                                    turns: const AlwaysStoppedAnimation(
                                        15 / 360),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: deck.discardPile
                                          .getList()[deck.discardPile
                                              .getList()
                                              .length -
                                          3],
                                      revealed: true,
                                    )),
                              )
                            : Container(),
                            deck.discardPile.size() > 1
                            ? buildSlideAnimation(
                                RotationTransition(
                                    turns: const AlwaysStoppedAnimation(
                                        15 / 360),
                                    child: ModifierCardWidget(
                                      name: deck.name,
                                      card: deck.discardPile
                                          .getList()[deck.discardPile
                                              .getList()
                                              .length -
                                          2],
                                      revealed: true,
                                    )),
                                Key(deck.discardPile
                                    .size()
                                    .toString()))
                            : Container(),
                            deck.discardPile.isNotEmpty
                            ? buildDrawAnimation(
                                ModifierCardWidget(
                                  name: deck.name,
                                  key: Key(deck.discardPile
                                      .size()
                                      .toString()),
                                  card: deck.discardPile.peek,
                                  revealed: true,
                                ),
                                Key((-deck.discardPile
                                        .size())
                                    .toString()))
                            : SizedBox(
                                width: 66.6666 *
                                    settings.userScalingBars.value,
                                height: 40 * settings.userScalingBars.value,
                              ),
                          ]))
                    ],
                  );
                }),
          );
        });
  }
}
