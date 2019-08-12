
import 'package:flutter_android_updater/src/UpdateInfo.dart';

abstract class IUpdateAgent {
  UpdateInfo getInfo();

  void update();

  void ignore();
}