class Asset {
  String? id;
  String? userId;
  String? assetName;
  String? assetBrand;
  String? assetWarrantyStatus;
  String? allotedDate;
  String? returnDate;
  String? createdAt;
  String? updatedAt;

  Asset(
      {this.id,
        this.userId,
        this.assetName,
        this.assetBrand,
        this.assetWarrantyStatus,
        this.allotedDate,
        this.returnDate,
        this.createdAt,
        this.updatedAt});

  Asset.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    assetName = json['asset_name'];
    assetBrand = json['asset_brand'];
    assetWarrantyStatus = json['asset_warranty_status'];
    allotedDate = json['alloted_date'];
    returnDate = json['return_date'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['asset_name'] = this.assetName;
    data['asset_brand'] = this.assetBrand;
    data['asset_warranty_status'] = this.assetWarrantyStatus;
    data['alloted_date'] = this.allotedDate;
    data['return_date'] = this.returnDate;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
