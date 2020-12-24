import 'dart:convert';

import 'base_model.dart';

class ProvinceModel  implements BaseModel   {
  String id;
  int n_order;
  Map<String, dynamic> json;
  int uploadPending;

  ProvinceModel({
    this.id,
    this.n_order,
    this.json,
    this.uploadPending,
  });

  factory ProvinceModel.fromServerJson(Map<String, dynamic> json) =>
      new ProvinceModel(
        id: json["id"],
        n_order: json["n_order"],
        json: json,
        uploadPending: 0
      );

  factory ProvinceModel.fromLocalDbJson(Map<String, dynamic> json) =>
      new ProvinceModel(
          id: json["id"],
          n_order: json["n_order"],
          json: jsonDecode(json["json"]),
          uploadPending: json["upload_pending"]
      );

  Map<String, dynamic> toJson() => {
        "id": this.id,
        "n_order": this.n_order,
        "json": jsonEncode(this.json),
        "upload_pending": this.uploadPending,
      };

  bool isValid() {
    return true;
  }

  String toString(){
    return this.json["name"];
  }
}
