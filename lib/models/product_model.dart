import 'dart:convert';

import 'base_model.dart';

class ProductModel implements BaseModel {
  String id;
  double score;
  Map<String, dynamic> json;
  int uploadPending;

  ProductModel({
    this.id,
    this.score,
    this.json,
    this.uploadPending,
  });

  factory ProductModel.fromServerJson(Map<String, dynamic> json) =>
      new ProductModel(
          id: json["id"], score: json["score"], json: json, uploadPending: 0);

  factory ProductModel.fromLocalDbJson(Map<String, dynamic> json) =>
      new ProductModel(
          id: json["id"],
          score: json["score"],
          json: jsonDecode(json["json"]),
          uploadPending: json["upload_pending"]);

  factory ProductModel.fromArguments(String name, String description){

  }

  Map<String, dynamic> toJson() => {
        "id": this.id,
        "score": this.score,
        "json": jsonEncode(this.json),
        "upload_pending": this.uploadPending,
      };

  bool isValid() {
    return true;
  }

  String toString() {
    return this.json["name"];
  }
}
