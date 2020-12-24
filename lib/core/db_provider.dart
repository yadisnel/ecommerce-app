import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'config.dart';

class DBProvider {
  // Create a singleton
  DBProvider._();

  static final DBProvider db = DBProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  initDB() async {
    // Get the location of our apps directory. This is where files for our app, and only our app, are stored.
    // Files in this directory are deleted when the app is deleted.
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'app.db');

    return await openDatabase(path, version: 1, onOpen: (db) async {},
        onCreate: (Database db, int version) async {
      await db.execute('''
				CREATE TABLE ${DB_TABLE_OWN_PRODUCTS}(
					id VARCHAR PRIMARY KEY,
					score REAL DEFAULT 0,
					json TEXT DEFAULT '',
					upload_pending INTEGER DEFAULT 0
				)
			''');
      //Provinces
      await db.execute('''
				CREATE TABLE ${DB_TABLE_PROVINCES}(
					id VARCHAR PRIMARY KEY,
					n_order INTEGER DEFAULT 0,
					json TEXT DEFAULT '',
					upload_pending INTEGER DEFAULT 0
				)
			''');
      //Categories
      await db.execute('''
				CREATE TABLE ${DB_TABLE_CATEGORIES}(
					id VARCHAR PRIMARY KEY,
					n_order INTEGER DEFAULT 0,
					json TEXT DEFAULT '',
					upload_pending INTEGER DEFAULT 0
				)
			''');
      await db.execute('''
            CREATE TABLE ${DB_TABLE_CONFIGS}(
              variable VARCHAR PRIMARY KEY,
              value VARCHAR
            )
			    ''');
      /*Variables and defaults configs*/
      var uuid = Uuid();
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_TOKEN_CONFIG','')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_APP_NAME_CONFIG','dtodo')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_ROOT_PAGE_ITEM_SELECTED_CONFIG','0')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_LANGUAGE_CODE_CONFIG','')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_COUNTRY_CODE_CONFIG','')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_LOGIN_PAGE_ITEM_SELECTED_CONFIG','$DB_LOGIN_PAGE_ITEM_SELECTED_CONFIG_MAIL_VALUE')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_API_HOST_IP_CONFIG','$DB_API_HOST_IP_CONFIG_VALUE')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_USER_INFO_CONFIG','')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_BROKER_HOST_IP_CONFIG','$DB_BROKER_HOST_IP_CONFIG_VALUE')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_BROKER_WS_PORT_CONFIG','$DB_BROKER_WS_PORT_CONFIG_VALUE')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_APP_ID_CONFIG','${uuid.v4()}')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_LAST_PROVINCE_OFFSET_CONFIG','$DB_LAST_PROVINCE_OFFSET_CONFIG_VALUE')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_LAST_CATEGORY_OFFSET_CONFIG','$DB_LAST_CATEGORY_OFFSET_CONFIG_VALUE')''');
      await db.execute(
          '''INSERT INTO ${DB_TABLE_CONFIGS}(variable,value) VALUES('$DB_APP_IN_FIRST_CONFIG','$DB_APP_IN_FIRST_CONFIG_TRUE')''');

    });
  }
}
