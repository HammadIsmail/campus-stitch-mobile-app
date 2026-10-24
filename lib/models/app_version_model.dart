class AppVersionModel {
  final String latestVersion;
  final int buildNumber;
  final String minSupportedVersion;
  final int minSupportedBuild;
  final bool forceUpdate;
  final String title;
  final String releaseNotes;
  final String apkDownloadUrl;
  final String fileSize;
  final String? releasedAt;
  final String? updatedBy;

  const AppVersionModel({
    required this.latestVersion,
    required this.buildNumber,
    required this.minSupportedVersion,
    required this.minSupportedBuild,
    required this.forceUpdate,
    required this.title,
    required this.releaseNotes,
    required this.apkDownloadUrl,
    required this.fileSize,
    this.releasedAt,
    this.updatedBy,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      latestVersion: json['latestVersion']?.toString() ?? '1.0.0',
      buildNumber: int.tryParse(json['buildNumber']?.toString() ?? '1') ?? 1,
      minSupportedVersion: json['minSupportedVersion']?.toString() ?? '1.0.0',
      minSupportedBuild: int.tryParse(json['minSupportedBuild']?.toString() ?? '1') ?? 1,
      forceUpdate: json['forceUpdate'] == true || json['forceUpdate']?.toString().toLowerCase() == 'true',
      title: json['title']?.toString() ?? 'New Update Available! 🚀',
      releaseNotes: json['releaseNotes']?.toString() ?? 'Performance improvements and bug fixes.',
      apkDownloadUrl: json['apkDownloadUrl']?.toString() ?? '',
      fileSize: json['fileSize']?.toString() ?? '50.2 MB',
      releasedAt: json['releasedAt']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latestVersion': latestVersion,
      'buildNumber': buildNumber,
      'minSupportedVersion': minSupportedVersion,
      'minSupportedBuild': minSupportedBuild,
      'forceUpdate': forceUpdate,
      'title': title,
      'releaseNotes': releaseNotes,
      'apkDownloadUrl': apkDownloadUrl,
      'fileSize': fileSize,
      'releasedAt': releasedAt,
      'updatedBy': updatedBy,
    };
  }
}
