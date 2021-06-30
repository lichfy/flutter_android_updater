import 'dart:io';

import 'package:install_plugin/install_plugin.dart';
import 'package:connectivity/connectivity.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateUtils {
  static const String KEY_IGNORE = "update.prefs.ignore";
  static const String KEY_UPDATE = "update.prefs.update";

  ///检查网络
  static Future<bool> checkNetwork() async {

    var result = await (new Connectivity().checkConnectivity());
    return result != ConnectivityResult.none;
  }

  ///验证md5
  static Future<bool> verify(File apk, String md5) async {
    if (! await apk.exists()) {
      return false;
    }
    String _md5 = md5File(apk);
    if (_md5.isEmpty) {
      return false;
    }
    bool result = _md5 == md5;
    if (!result) {
      apk.delete();
    }
    return result;
  }

  static String md5File(File file){
    var content = file.readAsBytesSync();
    return md5.convert(content).toString().toUpperCase();
  }

  static void setIgnore(String md5) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY_IGNORE, md5);
  }

  static void setUpdate(String md5,String basePath) async {
    if (md5.isEmpty) {
      return;
    }

    SharedPreferences sp = await SharedPreferences.getInstance();
    String? old = sp.getString(KEY_UPDATE);
    if (old == null)
      old = "";
    if (md5 == old) {
      print("same md5");
      return;
    }
    File oldFile = File(basePath + Platform.pathSeparator + old);
    if (await oldFile.exists()) {
      oldFile.delete();
    }

    File file = File(basePath + Platform.pathSeparator + md5);
    if (! await file.exists()) {
      try {
        await file.create();
      }catch(FileSystemException){}
    }
    sp.setString(KEY_UPDATE, md5);
  }

  static void install(File apkFile,String appId) async {
    await InstallPlugin.installApk(apkFile.path, appId);
  }
}