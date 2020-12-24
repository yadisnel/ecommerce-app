import 'package:app/core/db_provider.dart';

import 'config.dart';

class ConfigsDao {
  ConfigsDao._();

  static final ConfigsDao dao = ConfigsDao._();

  Future<Map<String, String>> getConfigValues() async {
    final db = await DBProvider.db.database;
    Map<String, String> config = Map();
    var res = await db.query(DB_TABLE_CONFIGS);
    res.forEach((row) => config[row['variable']] = row['value']);
    return config;
  }

  void updateConfigValue(String variable, String value) async {
    final db = await DBProvider.db.database;
    await db.update(
        DB_TABLE_CONFIGS,
        {
          "value": value,
        },
        where: 'variable = ?',
        whereArgs: [variable]);
  }
}
