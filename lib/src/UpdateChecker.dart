import 'dart:convert';
import 'dart:io';
import 'package:flutter_android_updater/src/UpdateError.dart';
import 'package:flutter_android_updater/src/UpdateInfo.dart';
import 'package:flutter_android_updater/src/interface/ICheckAgent.dart';
import 'package:flutter_android_updater/src/interface/IUpdateChecker.dart';

class UpdateChecker implements IUpdateChecker{
  @override
  Future<void> check(ICheckAgent agent, String url) async {
    var httpClient = HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var json = await response.transform(utf8.decoder).join();
        var data = jsonDecode(json);
        agent.setInfo(UpdateInfo.fromJson(data));
      } else {
        agent.setError(new UpdateError(UpdateError.CHECK_HTTP_STATUS,message: response.statusCode.toString()));
      }
    } catch (exception) {
      agent.setError(new UpdateError(UpdateError.CHECK_NETWORK_IO));
    }
  }

}