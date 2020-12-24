import 'package:app/core/config.dart';
import 'package:app/core/db_provider.dart';
import 'package:app/models/province_model.dart';
import 'package:sqflite/sqflite.dart';

class ProvincesDao {
  ProvincesDao._();

  static final ProvincesDao dao = ProvincesDao._();

  Future<List<ProvinceModel>> getProvincesFromLocalDb() async {
    final db = await DBProvider.db.database;
    var res = await db.query(DB_TABLE_PROVINCES, orderBy: "n_order");
    List<ProvinceModel> provinces = res.isNotEmpty
        ? res.map((province) => ProvinceModel.fromLocalDbJson(province)).toList()
        : [];
    return provinces;
  }

  Future<ProvinceModel> getProvinceFromLocalDb(String id) async {
    final db = await DBProvider.db.database;
    var res = await db.query(DB_TABLE_PROVINCES, where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? ProvinceModel.fromLocalDbJson(res.first) : null;
  }

  Future<void> addProvince(ProvinceModel province) async {
    final db = await DBProvider.db.database;
    var res = await db.insert(DB_TABLE_PROVINCES, province.toJson());
    return res;
  }

  Future<void> updateProvince(ProvinceModel province) async {
    final db = await DBProvider.db.database;
    var res = await db.update(DB_TABLE_PROVINCES, province.toJson(),
        where: 'id = ?', whereArgs: [province.id]);
    return res;
  }

  Future<void> deleteProvince(ProvinceModel province) async {
    final db = await DBProvider.db.database;
    var res = await db
        .delete(DB_TABLE_PROVINCES, where: 'id = ?', whereArgs: [province.id]);
    return res;
  }

  Future<bool> areThereProvincesInDb() async {
    final db = await DBProvider.db.database;
    int count = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $DB_TABLE_PROVINCES"));
    return count > 0;
  }

  Future<bool> isProvinceInDb(String id) async {
    final db = await DBProvider.db.database;
    var res = await db.query(DB_TABLE_PROVINCES, where: 'id = ?', whereArgs: [id] );
    return res.isNotEmpty;
  }

  Future<void> syncProvinces(List provinces) async {
    final db = await DBProvider.db.database;
    await db.transaction((txn) async {
      if (provinces != null && provinces.length > 0) {
        for (int i = 0; i < provinces.length; i++) {
          ProvinceModel provinceModel = ProvinceModel.fromServerJson(provinces[i]);
          if (!provinceModel.isValid()) {
            return;
          }
          var isProvinceInDb = await txn.query(DB_TABLE_PROVINCES, where: 'id = ?', whereArgs: [provinceModel.id] );
          if (provinceModel.json["deleted"]) {
            txn.delete(DB_TABLE_PROVINCES,
                where: 'id = ?', whereArgs: [provinceModel.id]);
          } else if (isProvinceInDb.isNotEmpty) {
            txn.update(DB_TABLE_PROVINCES, provinceModel.toJson(),
                where: 'id = ?', whereArgs: [provinceModel.id]);
          } else {
            txn.insert(DB_TABLE_PROVINCES, provinceModel.toJson());
          }
        }
        txn.update(
            DB_TABLE_CONFIGS,
            {
              "value": provinces[provinces.length - 1]["modified"],
            },
            where: 'variable = ?',
            whereArgs: [DB_LAST_PROVINCE_OFFSET_CONFIG]);
      }
    });
  }
}
