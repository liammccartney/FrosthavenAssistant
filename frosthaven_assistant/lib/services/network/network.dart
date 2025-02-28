import 'package:flutter/cupertino.dart';
import 'package:frosthaven_assistant/services/network/server.dart';

import 'client.dart';
import 'network_info.dart';

enum ClientState{
  connected,
  disconnected,
  connecting
}

class Network {
  final Client client = Client();
  final Server server = Server();
  final NetworkInformation networkInfo = NetworkInformation();
  final networkMessage = ValueNotifier<String>("");

  bool appInBackground = false;
  bool clientDisconnectedWhileInBackground = false;
}