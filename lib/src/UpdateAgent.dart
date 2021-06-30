import 'dart:io';
import 'dart:async';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_android_updater/src/ProgressDialog.dart';
import 'package:flutter_android_updater/src/UpdateChecker.dart';
import 'package:flutter_android_updater/src/UpdateDownloader.dart';
import 'package:flutter_android_updater/src/UpdateError.dart';
import 'package:flutter_android_updater/src/UpdateInfo.dart';
import 'package:flutter_android_updater/src/UpdateUtils.dart';
import 'package:flutter_android_updater/src/interface/ICheckAgent.dart';
import 'package:flutter_android_updater/src/interface/IUpdateChecker.dart';
import 'package:flutter_android_updater/src/interface/IDownloadAgent.dart';
import 'package:flutter_android_updater/src/interface/IUpdateAgent.dart';
import 'package:flutter_android_updater/src/interface/IUpdateDownloader.dart';
import 'package:flutter_android_updater/src/interface/IUpdatePrompter.dart';
import 'package:flutter_android_updater/src/interface/OnDownloadListener.dart';
import 'package:flutter_android_updater/src/interface/OnFailureListener.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateAgent implements ICheckAgent, IUpdateAgent, IDownloadAgent {
  final BuildContext context;
  final String url;
  final bool isManual;
  final String packageName;
  IUpdateDownloader? downloader;
  IUpdatePrompter? prompter;
  OnFailureListener? onFailureListener;
  OnDownloadListener? onDownloadListener;

  late IUpdateChecker _checker;
  UpdateInfo? _info;
  UpdateError? _error;
  late File _apkFile;
  late File _tmpFile;

  late String _basePath;

  UpdateAgent(this.context, this.url, this.packageName,
      {this.isManual: false,
      this.downloader,
      this.prompter,
      this.onFailureListener,
      this.onDownloadListener}) {
    if (downloader == null) downloader = UpdateDownloader();
    if (prompter == null) prompter = _DefaultUpdatePrompter(context);
    if (onFailureListener == null) onFailureListener = _DefaultFailureListener();
    if (onDownloadListener == null) onDownloadListener = _DefaultDialogDownloadListener(context,this);

    _checker = UpdateChecker();
  }

  @override
  UpdateInfo getInfo() {
    return _info!;
  }

  @override
  void ignore() {
    UpdateUtils.setIgnore(getInfo().md5);
  }

  @override
  void onFinish() {
    onDownloadListener!.onFinish();
    UpdateUtils.verify(_tmpFile, basename(_tmpFile.path)).then((v) {
      //验证下载的文件(文件名就是其文件本身的md5）
      if (v) {
        _tmpFile.rename(_apkFile.path).then((x) {
          _install();
        });
      } else {
        onFailureListener!.onFailure(UpdateError(UpdateError.DOWNLOAD_VERIFY));
      }
    });
  }

  @override
  void onProgress(int receivedBytes, int totalBytes) {
    onDownloadListener!.onProgress(receivedBytes, totalBytes);
  }

  @override
  void onStart() {
    onDownloadListener!.onStart();
  }

  @override
  void setError(UpdateError error) {
    _error = error;
  }

  @override
  void setInfo(UpdateInfo info) {
    _info = info;
    _info!.appId = packageName;
  }

  @override
  void update() async {
    if (await UpdateUtils.verify(_apkFile, _info!.md5)) {
      _install();
    } else {
      _download();
    }
  }

  void check() async {
    var isConnect = await UpdateUtils.checkNetwork();
    if (isConnect) {
      await _checker.check(this, url);
      if (_error != null) {
        onFailureListener!.onFailure(_error!);
      } else {
        if (_info == null) {
          onFailureListener!.onFailure(UpdateError(UpdateError.CHECK_UNKNOWN));
          return;
        }

        if (!_info!.hasUpdate) return; //不需要更新

        _basePath = (await getExternalStorageDirectory())!.path;

        UpdateUtils.setUpdate(_info!.md5, _basePath);
        _apkFile = new File(_basePath + Platform.pathSeparator + _info!.md5 + ".apk");
        _tmpFile = new File(_basePath + Platform.pathSeparator + _info!.md5);

        if (await UpdateUtils.verify(_apkFile, _info!.md5)) {
          //已有
          _install();
        } else {
          prompter!.prompt(this); //显示提示框
        }
      }
    } else {
      onFailureListener!.onFailure(UpdateError(UpdateError.CHECK_NO_NETWORK));
    }
  }

  void _install() {
    UpdateUtils.install(_apkFile, _info!.appId);
  }

  void _download() async {
    try{
      await downloader!.download(this, _info!.url, _tmpFile);
      // onDownloadListener.onFinish();
    }catch(e){
      if (e is UpdateError){        
        onFailureListener!.onFailure(e);
      }
      onDownloadListener!.onFinish();
    }

    // .catchError((e){      
    //   onFailureListener.onFailure(e);
    // },test:(e) => e is UpdateError)
    // .whenComplete((){
    //    onDownloadListener.onFinish(); 
    // }); 
  }
}

class _DefaultFailureListener implements OnFailureListener {
  @override
  void onFailure(UpdateError error) {
    Fluttertoast.showToast(msg: error.toString(), backgroundColor: Colors.black54);
  }
}

class _DefaultDialogDownloadListener implements OnDownloadListener {
  final BuildContext context;
  final IUpdateAgent agent;
  StreamController<double> streamController = StreamController<double>();
  bool _start = false;

  _DefaultDialogDownloadListener(this.context,this.agent);

  @override
  void onFinish() {
    if (!_start) return;

    _start = false;
    streamController.close();
    Navigator.of(context).pop();
  }

  @override
  void onProgress(int receivedBytes, int totalBytes) {
    streamController.sink.add(receivedBytes / totalBytes);
  }

  @override
  void onStart() {
    _start = true;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(child: ProgressDialog(stream: streamController.stream),
            onWillPop: (){
              final force = agent.getInfo().isForce;
              return Future.value(!force);
            },
          );
        });
  }
}

class _DefaultUpdatePrompter implements IUpdatePrompter {
  final BuildContext context;

  _DefaultUpdatePrompter(this.context);

  @override
  void prompt(IUpdateAgent agent) {
    UpdateInfo info = agent.getInfo();
    var size = filesize(info.fileSize);
    var content = '最新版本：${info.versionName}\n新版本大小：$size\n\n更新内容\n\n${info.updateContent}';

    var buttons = <Widget>[
      FlatButton(
        child: Text('立即更新'),
        onPressed: () {
          agent.update();
          Navigator.of(context).pop();
        },
      ),
      FlatButton(
        child: Text('以后再说'),
        onPressed: () {
//          agent.ignore();
          Navigator.of(context).pop();
        },
      )
    ];

    if (info.isForce) {
      content = "您需要更新应用才能继续使用\n\n" + content;
      buttons.removeLast();
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            child: AlertDialog(
              title: Text('应用更新'),
              content: Text(content),
              actions: buttons,
            ),
            onWillPop: (){
              return Future.value(false);
            },
          );
        });
  }
}
