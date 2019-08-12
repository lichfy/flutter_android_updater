
import 'package:flutter_android_updater/src/interface/ICheckAgent.dart';

abstract class IUpdateChecker{
  Future<void> check(ICheckAgent agent, String url);
}