class UpdateInfo {
  // 是否有新版本
  final bool hasUpdate;

  // 是否强制安装：不安装无法使用app
  final bool isForce;


  final int versionCode;
  final String versionName;

  final String updateContent;

  final String url;
  final String md5;
  final num fileSize;
  String appId;

  UpdateInfo({
      this.hasUpdate:false,
      this.isForce:false,
      this.versionCode,
      this.versionName,
      this.updateContent,
      this.url,
      this.md5,
      this.fileSize});


  factory UpdateInfo.fromJson(Map<String,dynamic> json){
    return UpdateInfo(
      hasUpdate: json['hasUpdate'] as bool,
      isForce: json['force'] as bool,
      versionCode: json['versionCode'] as int,
      versionName: json['versionName'] as String,
      updateContent: json['updateContent'] as String,
      url: json['url'] as String,
      md5: json['md5'] as String,
      fileSize: num.parse(json['fileSize'])
    );
  }
}
