
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';

import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../enums.dart';
import '../game_methods.dart';
import '../state/character.dart';
import '../state/monster.dart';
import '../state/monster_instance.dart';

class SummonData {
  int standeeNr;
  String name;
  int health;
  int move;
  int attack;
  int range;
  String gfx;
  SummonData(this.standeeNr, this.name, this.health,this.move,this.attack,this.range,this.gfx);
}

class AddStandeeCommand extends Command {
  final int nr;

  //nope can't use any references: they will break on load data
  final SummonData? summon;
  final MonsterType type;
  final String ownerId;
  final bool addAsSummon;
  //final ValueNotifier<List<MonsterInstance>> monsterList;


  AddStandeeCommand(this.nr, this.summon, this.ownerId, this.type, this.addAsSummon);

  @override
  void execute() {

    MonsterInstance instance;
    Monster? monster;
    if(summon == null) {
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId && item is Monster) {
          monster = item;
        }
      }
      instance = MonsterInstance(nr, type, addAsSummon, monster!);
    } else {
      instance = MonsterInstance.summon(
          summon!.standeeNr,
          type,
          summon!.name,
          summon!.health,
          summon!.move,
          summon!.attack,
          summon!.range,
          summon!.gfx,
          getIt<GameState>().round.value);
    }

    List<MonsterInstance> newList = [];
    ValueNotifier<List<MonsterInstance>>? monsterList;
    //find list
    if(monster != null) {
      monsterList = monster.monsterInstances;
    } else {
      for (var item in getIt<GameState>().currentList) {
        if (item.id == ownerId) {
          monsterList = (item as Character).characterState.summonList;
          break;
        }
      }
    }

    //make sure summons can not have same gfx and nr:
    if(instance.standeeNr != 0) {
      bool ok = false;
      while (!ok) {
        ok = true;
        for (var item in monsterList!.value) {
          if (item.standeeNr == instance.standeeNr) {
            if (item.gfx == instance.gfx) {
              //can not have same gfx and nr
              instance = MonsterInstance.summon(
                  instance.standeeNr+1,
                  type,
                  summon!.name,
                  summon!.health,
                  summon!.move,
                  summon!.attack,
                  summon!.range,
                  summon!.gfx,
                  getIt<GameState>().round.value
              );
              ok = false;
            }
          }
        }
      }
    }

    newList.addAll(monsterList!.value);
    newList.add(instance);

    if (monster != null) {
      GameMethods.sortMonsterInstances(newList);
    }
    monsterList.value = newList;
    if (monsterList.value.length == 1 && monster != null) {
      //first added
      if (getIt<GameState>().roundState.value == RoundState.chooseInitiative) {
        GameMethods.sortCharactersFirst();
      } else if (getIt<GameState>().roundState.value == RoundState.playTurns) {
        GameMethods.drawAbilityCardFromInactiveDeck();
        GameMethods.sortItemToPlace(monster.id, GameMethods.getInitiative(monster)); //need to only sort this one item to place
      }
    }
    if(getIt<GameState>().roundState.value == RoundState.playTurns) {
      Future.delayed(const Duration(milliseconds: 600), () {
        getIt<GameState>().updateList.value++;
      });
    }else {
      getIt<GameState>().updateList.value++;
    }
    //getIt<GameState>().updateList.value++;
  }



  @override
  void undo() {
    getIt<GameState>().updateList.value++;
  }

  @override
  String describe() {
    String name = ownerId;
    if(summon != null) {
      name = summon!.name;
    }
    return "Add ${name} $nr";
  }
}