
import 'package:flutter_android_updater/src/interface/OnDownloadListener.dart';
import 'package:flutter_android_updater/src/UpdateError.dart';
import 'package:flutter_android_updater/src/UpdateInfo.dart';

abstract class IDownloadAgent  extends OnDownloadListener {
  UpdateInfo getInfo();

  void setError(UpdateError error);
}