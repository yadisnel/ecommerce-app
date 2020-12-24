import 'package:app/core/db_provider.dart';
import 'package:app/models/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app/core/config.dart';

class OwnProductsDao {
  OwnProductsDao._();

  static final OwnProductsDao dao = OwnProductsDao._();

  Future<List<ProductModel>> getOwnProductsFromDatabase(
      int limit, int offset) async {
    final db = await DBProvider.db.database;
    var res = await db.query(DB_TABLE_OWN_PRODUCTS,
        limit: limit, offset: offset, orderBy: "score DESC");
    List<ProductModel> products = res.isNotEmpty
        ? res.map((product) => ProductModel.fromLocalDbJson(product)).toList()
        : [];
    return products;
  }

  Future<void> addOwnProduct(ProductModel product) async {
    final db = await DBProvider.db.database;
    var res = await db.insert(DB_TABLE_OWN_PRODUCTS, product.toJson());
    return res;
  }

  Future<bool> existsOwnProductsInDb() async {
    final db = await DBProvider.db.database;
    int count = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM $DB_TABLE_OWN_PRODUCTS"));
    return count >0;
  }

  Future<void> deleteOwnProductsFromLocalDatabase() async {
    final db = await DBProvider.db.database;
    await db.delete('own_products');
  }
}
