import 'dart:io';

import 'package:flutter_android_updater/src/UpdateError.dart';
import 'package:flutter_android_updater/src/UpdateUtils.dart';
import 'package:flutter_android_updater/src/interface/IDownloadAgent.dart';
import 'package:flutter_android_updater/src/interface/IUpdateDownloader.dart';

class UpdateDownloader implements IUpdateDownloader{

  num _bytesTemp = 0;

  bool checkStatus(HttpClientResponse response) {
    return response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.partialContent;
  }

  @override
  Future download(IDownloadAgent agent, String url, File temp) async {
    if (await temp.exists()){ //之前有下载过
      _bytesTemp = await temp.length();
    }

    if (!await UpdateUtils.checkNetwork()) {
      return Future.error(UpdateError(UpdateError.DOWNLOAD_NETWORK_BLOCKED));
    }

    agent.onStart();

    final httpClient = new HttpClient()..connectionTimeout = const Duration(seconds: 10);
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };

    var uri = Uri.parse(url);

    var request = await httpClient.getUrl(uri);
    request.headers.add(HttpHeaders.contentTypeHeader, "application/vnd.android.package-archive");
    var httpResponse = await request.close();
    if (!checkStatus(httpResponse)) {
      return Future.error(UpdateError(UpdateError.DOWNLOAD_HTTP_STATUS, message: httpResponse.statusCode.toString()));
    }

    int byteCount = 0;
    int totalBytes = httpResponse.contentLength;

    // if (_bytesTemp == totalBytes) { //之前下载的是完整的
    //   agent.onFinish();
    //   return 1;
    // }

    request = await httpClient.getUrl(uri);
    request.headers.add(HttpHeaders.contentTypeHeader, "application/vnd.android.package-archive");
    // request.headers.add(HttpHeaders.rangeHeader, "bytes=$_bytesTemp-"); //断点续传暂不支持
    httpResponse = await request.close();
    if (!checkStatus(httpResponse)) {
      return Future.error(UpdateError(UpdateError.DOWNLOAD_HTTP_STATUS, message: httpResponse.statusCode.toString()));
    }

    try {
      if (await temp.exists()){ 
        await temp.delete();
      }

      var raf = temp.openSync(mode: FileMode.write);

      httpResponse.listen(
            (data) {
          byteCount += data.length;

          raf.writeFromSync(data);
          // agent.onProgress(byteCount + _bytesTemp, totalBytes);
          agent.onProgress(byteCount, totalBytes);
        },
        onDone: () {
          raf.closeSync();
          agent.onFinish();
          return 1;
        },
        onError: (e) {
          raf.closeSync();
          temp.deleteSync();
          return Future.error(UpdateError(UpdateError.DOWNLOAD_NETWORK_IO));
        },
        cancelOnError: true,
      );
    }catch(FileSystemException){
      return Future.error(UpdateError(UpdateError.STORAGE_PERMISSION_DENIED));
    }
  }


}
