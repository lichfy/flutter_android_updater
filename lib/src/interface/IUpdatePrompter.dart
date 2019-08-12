
import 'package:flutter_android_updater/src/interface/IUpdateAgent.dart';

abstract class IUpdatePrompter {
  void prompt(IUpdateAgent agent);
}