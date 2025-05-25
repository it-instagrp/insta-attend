class Version {
  String? id;
  String? versionName;
  String? versionLink;
  List<String>? features;
  String? createdAt;
  String? updatedAt;

  Version(
      {this.id,
        this.versionName,
        this.versionLink,
        this.features,
        this.createdAt,
        this.updatedAt});

  Version.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    versionName = json['version_name'];
    versionLink = json['version_link'];
    features = json['features'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['version_name'] = this.versionName;
    data['version_link'] = this.versionLink;
    data['features'] = this.features;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
