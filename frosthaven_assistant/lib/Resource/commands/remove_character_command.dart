
import '../../services/service_locator.dart';
import '../action_handler.dart';
import '../game_methods.dart';
import '../state/character.dart';
import '../state/game_state.dart';
import '../state/list_item_data.dart';

class RemoveCharacterCommand extends Command {
  final GameState _gameState = getIt<GameState>();
  final List<Character> names;

  RemoveCharacterCommand(this.names);

  @override
  void execute() {
    List<ListItemData> newList = [];
    for (var item in _gameState.currentList) {
      if (item is Character) {
        bool remove = false;
        for (var name in names) {
          if (item.characterState.display.value == name.characterState.display.value) {
            remove = true;
            break;
          }
        }
        if (!remove) {
          newList.add(item);
        }
      } else {
        newList.add(item);
      }
    }
    _gameState.currentList = newList;
    GameMethods.updateForSpecialRules();
    _gameState.updateList.value++;
  }

  @override
  void undo() {
    //_gameState.currentList.add(_character);
    _gameState.updateList.value++;
  }

  @override
  String describe() {
    if(names.length > 1) {
      return "Remove all characters";
    }
    return "Remove ${names[0].id}";
  }
}