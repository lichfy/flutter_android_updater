class UpdateError {
  int code;
  String _message = '';

  final messages = {
    UPDATE_IGNORED: '该版本已经忽略',
    UPDATE_NO_NEWER: '已经是最新版了',
    CHECK_UNKNOWN: "查询更新失败：未知错误",
    CHECK_NO_WIFI: "查询更新失败：没有 WIFI",
    CHECK_NO_NETWORK: "查询更新失败：没有网络",
    CHECK_NETWORK_IO: "查询更新失败：网络异常",
    CHECK_HTTP_STATUS: "查询更新失败：错误的HTTP状态",
    CHECK_PARSE: "查询更新失败：解析错误",
    DOWNLOAD_UNKNOWN: "下载失败：未知错误",
    DOWNLOAD_CANCELLED: "下载失败：下载被取消",
    DOWNLOAD_DISK_NO_SPACE: "下载失败：磁盘空间不足",
    DOWNLOAD_DISK_IO: "下载失败：磁盘读写错误",
    DOWNLOAD_NETWORK_IO: "下载失败：网络异常",
    DOWNLOAD_NETWORK_BLOCKED: "下载失败：网络中断",
    DOWNLOAD_NETWORK_TIMEOUT: "下载失败：网络超时",
    DOWNLOAD_HTTP_STATUS: "下载失败：错误的HTTP状态",
    DOWNLOAD_INCOMPLETE: "下载失败：下载不完整",
    DOWNLOAD_VERIFY: "下载失败：校验错误",

    STORAGE_PERMISSION_DENIED:"没有存储权限，无法更新",
  };

  String get message {
    String? m = messages[this.code];
    if (m == null) {
      return _message;
    }
    if (_message.length == 0) {
      return m;
    }
    return m + "(" + _message + ")";
  }

  UpdateError(this.code,{String message:''}){
    this._message = message;
  }

  bool isError() {
    return code >= 2000;
  }

  String toString() {
    if (isError()) {
      return "[$code]$message";
    }
    return message;
  }

  static const int UPDATE_IGNORED = 1001;
  static const int UPDATE_NO_NEWER = 1002;

  static const int CHECK_UNKNOWN = 2001;
  static const int CHECK_NO_WIFI = 2002;
  static const int CHECK_NO_NETWORK = 2003;
  static const int CHECK_NETWORK_IO = 2004;
  static const int CHECK_HTTP_STATUS = 2005;
  static const int CHECK_PARSE = 2006;

  static const int DOWNLOAD_UNKNOWN = 3001;
  static const int DOWNLOAD_CANCELLED = 3002;
  static const int DOWNLOAD_DISK_NO_SPACE = 3003;
  static const int DOWNLOAD_DISK_IO = 3004;
  static const int DOWNLOAD_NETWORK_IO = 3005;
  static const int DOWNLOAD_NETWORK_BLOCKED = 3006;
  static const int DOWNLOAD_NETWORK_TIMEOUT = 3007;
  static const int DOWNLOAD_HTTP_STATUS = 3008;
  static const int DOWNLOAD_INCOMPLETE = 3009;
  static const int DOWNLOAD_VERIFY = 3010;

  static const int STORAGE_PERMISSION_DENIED = 4001;
}
