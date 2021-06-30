
import 'package:flutter/material.dart';

import 'UpdateAgent.dart';
import 'interface/IUpdateDownloader.dart';
import 'interface/IUpdatePrompter.dart';
import 'interface/OnDownloadListener.dart';
import 'interface/OnFailureListener.dart';

class UpdateManager {
  final BuildContext context;
  final String url;
  final String packageName;
  IUpdateDownloader? downloader;
  IUpdatePrompter? prompter;
  OnFailureListener? onFailureListener;
  OnDownloadListener? onDownloadListener;

  UpdateManager(this.context, this.url, this.packageName,{this.downloader,this.prompter,this.onDownloadListener,this.onFailureListener});

  void check(){
    var agent = UpdateAgent(context,url,packageName,downloader: downloader,prompter : prompter,onDownloadListener : onDownloadListener,onFailureListener :onFailureListener);
    agent.check();
  }
}