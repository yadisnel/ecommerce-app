import 'dart:convert';

import 'base_model.dart';

class SubCategoryModel  implements BaseModel   {
  String id;
  String name;

  SubCategoryModel({
    this.id,
    this.name,
  });

  Map<String, dynamic> toJson() => {
        "id": this.id,
        "name": this.name,
      };

  bool isValid() {
    return true;
  }

  String toString(){
    return this.name;
  }
}
