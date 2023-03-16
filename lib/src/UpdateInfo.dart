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
  late String appId;

  UpdateInfo({
      this.hasUpdate:false,
      this.isForce:false,
      required this.versionCode,
      required this.versionName,
      this.updateContent:'',
      this.url:'',
      this.md5:'',
      this.fileSize:0});


  factory UpdateInfo.fromJson(Map<String,dynamic> json){
    return UpdateInfo(
      hasUpdate: json['hasUpdate'] as bool,
      isForce: (json['force'] as bool?)??false,
      versionCode: (json['versionCode'] as int?)??1,
      versionName: json['versionName']??'',
      updateContent: json['updateContent']??'',
      url: json['url']??'',
      md5: json['md5']??'',
      fileSize: json['fileSize']
    );
  }
}
