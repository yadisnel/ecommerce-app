import 'package:app/core/config.dart';
import 'package:app/core/db_provider.dart';
import 'package:app/models/category_model.dart';
import 'package:sqflite/sqflite.dart';

class CategoriesDao {
  CategoriesDao._();

  static final CategoriesDao dao = CategoriesDao._();

  Future<List<CategoryModel>> getCategoriesFromLocalDb() async {
    final db = await DBProvider.db.database;
    var res = await db.query(DB_TABLE_CATEGORIES, orderBy: "n_order");
    List<CategoryModel> Categories = res.isNotEmpty
        ? res.map((category) => CategoryModel.fromLocalDbJson(category)).toList()
        : [];
    return Categories;
  }

  Future<CategoryModel> getCategoryFromLocalDb(String id) async {
    final db = await DBProvider.db.database;
    var res = await db.query(DB_TABLE_CATEGORIES, where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? CategoryModel.fromLocalDbJson(res.first) : null;
  }

  Future<void> addCategory(CategoryModel category) async {
    final db = await DBProvider.db.database;
    var res = await db.insert(DB_TABLE_CATEGORIES, category.toJson());
    return res;
  }

  Future<void> updateCategory(CategoryModel category) async {
    final db = await DBProvider.db.database;
    var res = await db.update(DB_TABLE_CATEGORIES, category.toJson(),
        where: 'id = ?', whereArgs: [category.id]);
    return res;
  }

  Future<void> deleteCategory(CategoryModel category) async {
    final db = await DBProvider.db.database;
    var res = await db
        .delete(DB_TABLE_CATEGORIES, where: 'id = ?', whereArgs: [category.id]);
    return res;
  }

  Future<bool> areThereCategoriesInDb() async {
    final db = await DBProvider.db.database;
    int count = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $DB_TABLE_CATEGORIES"));
    return count > 0;
  }

  Future<bool> isCategoryInDb(String id) async {
    final db = await DBProvider.db.database;
    var res = await db.query(DB_TABLE_CATEGORIES, where: 'id = ?', whereArgs: [id] );
    return res.isNotEmpty;
  }

  Future<void> syncCategories(List Categories) async {
    final db = await DBProvider.db.database;
    await db.transaction((txn) async {
      if (Categories != null && Categories.length > 0) {
        for (int i = 0; i < Categories.length; i++) {
          CategoryModel categoryModel = CategoryModel.fromServerJson(Categories[i]);
          if (!categoryModel.isValid()) {
            return;
          }
          var isCategoryInDb = await txn.query(DB_TABLE_CATEGORIES, where: 'id = ?', whereArgs: [categoryModel.id] );
          if (categoryModel.json["deleted"]) {
            txn.delete(DB_TABLE_CATEGORIES,
                where: 'id = ?', whereArgs: [categoryModel.id]);
          } else if (isCategoryInDb.isNotEmpty) {
            txn.update(DB_TABLE_CATEGORIES, categoryModel.toJson(),
                where: 'id = ?', whereArgs: [categoryModel.id]);
          } else {
            txn.insert(DB_TABLE_CATEGORIES, categoryModel.toJson());
          }
        }
        txn.update(
            DB_TABLE_CONFIGS,
            {
              "value": Categories[Categories.length - 1]["modified"],
            },
            where: 'variable = ?',
            whereArgs: [DB_LAST_CATEGORY_OFFSET_CONFIG]);
      }
    });
  }
}
