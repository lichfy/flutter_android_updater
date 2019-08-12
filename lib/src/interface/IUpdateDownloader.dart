
import 'dart:io';

import 'package:flutter_android_updater/src/interface/IDownloadAgent.dart';

abstract class IUpdateDownloader {
  Future download(IDownloadAgent agent, String url, File temp);
}