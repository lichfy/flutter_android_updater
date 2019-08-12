
import 'package:flutter_android_updater/src/UpdateError.dart';

abstract class OnFailureListener {
  void onFailure(UpdateError error);
}