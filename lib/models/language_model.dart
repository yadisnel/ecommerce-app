import 'package:app/models/base_model.dart';
import 'package:flutter/material.dart';

class LanguageModel implements BaseModel {
  int index;
  String countryCode;
  String languageCode;
  String languageName;
  String flag;

  LanguageModel({
    @required this.index,
    @required this.countryCode,
    @required this.languageCode,
    @required this.languageName,
    @required this.flag,
  });

  // Create a Note from JSON data
  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      new LanguageModel(
        index: json["index"],
        countryCode: json["countryCode"],
        languageCode: json["languageCode"],
        languageName: json["languageName"],
        flag: json["flag"],
      );

  // Convert our Note to JSON to make it easier when we store it in the database
  Map<String, dynamic> toJson() => {
        "index": index,
        "countryCode": countryCode,
        "languageCode": languageCode,
        "languageName": languageName,
        "flag": flag,
      };
}
