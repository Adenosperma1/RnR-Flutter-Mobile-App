import 'dart:async';
import 'dart:convert';
import 'package:restoreandrenew/classes/individual_class.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//Classes
import 'package:restoreandrenew/classes/site_class.dart';
import 'package:restoreandrenew/classes/site_available_class.dart';
import 'package:restoreandrenew/classes/population_class.dart';

import 'package:restoreandrenew/classes/species_available_class.dart';
import 'package:restoreandrenew/classes/user_class.dart';
import 'package:restoreandrenew/classes/user_available_class.dart';

//TO DO set up the point table

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database _db;

  //site table// uses generic methods
  final String siteTableName = 'site';
  String rowOne =
      '1'; //a list of json encoded sites are saved in the first row of the site table
  final String columnID = 'id'; //name of the id column
  final String columnObjectList = 'object';

  //available sites table// uses generic methods
  final String availableSitesTableName = 'availableSite';
  //columnID, columnObjectList

  //available sites table// uses generic methods
  final String availableSpeciesTableName = 'availableSpecies';
  //columnID, columnObjectList

  //available sites table// uses generic methods
  final String availableUserTableName = 'availableUser';
  //columnID, columnObjectList

  //available sites table// uses generic methods
  final String userTableName = 'user';
  //columnID, columnObjectList

  //species table// this contains the collections as well inside the species object
  final String populationTableName = 'population'; //was 'species';

  //columnID, columnObjectList
  final String columnFK = 'fk';

//GENERIC METHODS______________________________________________________//
//-------------------------------------------------------------------//
  saveObjectList(String objectType, List objectlist, String rowId) async {
    //Population is different to other objects____________________

    if (objectType == 'population') {
      Population population = objectlist[0];
      int populationCount = objectlist.length;
      List<Individual> individualsList = population.sIndividualsList;
      int individualsCount = individualsList.length;
      int populationAndIndividual = populationCount + individualsCount;
      if (populationAndIndividual == 2) {
        insertPopulationRow(objectlist, rowId);
      } else {
        updatePopulationRow(objectlist, rowId);
      }
    } else

    //Generic____________________
    {
      int count = await countTableRows(objectType);
      if (count == 0) {
        await insertRow(objectType, columnObjectList, objectlist);
      } else if (count == 1) {
        await updateRow(objectType, columnObjectList, objectlist);
      }
    }
  } //end saveObjectList

  //-------------------------------------------------------------------//
  Future<int> insertPopulationRow(
      List<Population> populationList, String siteID) async {
    var dbClient = await db;
    String populationAsJson = json.encode(populationList);

    int theResult = await dbClient.rawInsert(
        'INSERT INTO $populationTableName ($columnObjectList, $columnFK) VALUES (\'$populationAsJson\', \'$siteID\')');

    return theResult;
  } //end insertSpeciesData

  //-------------------------------------------------------------------//
  Future<int> updatePopulationRow(
      List<Population> populationList, String siteID) async {
    var dbClient = await db;
    String populationAsJson = json.encode(populationList);
    return await dbClient.rawUpdate(
        'UPDATE $populationTableName SET $columnObjectList = \'$populationAsJson\' WHERE $columnFK = \'$siteID\'');
  } //end updateSpeciesData



//-------------------------------------------------------------------//
  Future<List> getPopulationList(String siteID) async {
    var dbClient = await db;

    //get back the map containing the fieldname and the field data
    List<Map> mapFromDB = await dbClient.query(populationTableName,
        columns: [columnObjectList],
        where: '$columnFK = ?',
        whereArgs: [siteID]);

    //print("Database_local says: population details: " + mapFromDB.toString());

    String populationMap;
    List<Population> populationList = [];

    if (mapFromDB.isNotEmpty) {
      var mapValue = mapFromDB[0];
      populationMap = mapValue[columnObjectList];
      json
          .decode(populationMap)
          .forEach((map) => populationList.add(new Population.fromJson(map)));
    }
    return populationList;
  } //end readSpeciesData

//-------------------------------------------------------------------//
  countTableRows(String objectType) async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM ' + objectType));
  }

//-------------------------------------------------------------------//
  Future<List> getObjectList(String objectType) async {
    var dbClient = await db;
    String tableName = objectType;
    String columnToReturn = columnObjectList;
    String columnToSearch = columnID;
    String searchString = rowOne;
    //get back the map containing the fieldname and the field data
    List<Map> mapFromDB = await dbClient.query(tableName,
        columns: [columnToReturn],
        where: '$columnToSearch = ?',
        whereArgs: [searchString]);
    String mapData;
    List theList = [];

    if (mapFromDB.isNotEmpty) {
      var value = mapFromDB[0];
      mapData = value[columnToReturn];

      if (objectType == siteTableName) {
        json
            .decode(mapData)
            .forEach((map) => theList.add(new Site.fromJson(map)));
      } else if (objectType == populationTableName) {
        json
            .decode(mapData)
            .forEach((map) => theList.add(new Population.fromJson(map)));
      } else if (objectType == userTableName) {
        json
            .decode(mapData)
            .forEach((map) => theList.add(new User.fromJson(map)));
      }

      //these are downloaded from firestore //these work
      else if (objectType == availableSitesTableName) {
        json
            .decode(mapData)
            .forEach((map) => theList.add(new AvailableSite.fromJson(map)));
      } else if (objectType == availableSpeciesTableName) {
        json
            .decode(mapData)
            .forEach((map) => theList.add(new AvailableSpecies.fromJson(map)));
      } else if (objectType == availableUserTableName) {
        json
            .decode(mapData)
            .forEach((map) => theList.add(new AvailableUser.fromJson(map)));
      }
    }
    return theList;
  } //end readRow

  //-------------------------------------------------------------------//
  Future<List> getSiteList() async {
    var dbClient = await db;
    String mapData;
    List theList = [];

    List<Map> mapFromDB = await dbClient.query(siteTableName,
        columns: [columnObjectList],
        where: '$columnID = ?',
        whereArgs: [rowOne]);

    if (mapFromDB.isNotEmpty) {
      var value = mapFromDB[0];
      mapData = value[columnObjectList];
      json.decode(mapData).forEach(
            (map) => theList.add(new Site.fromJson(map)),
          );
    }
    return theList;
  } //end getSiteList()

//-------------------------------------------------------------------//
  Future<int> deleteRow(
      String tableName, String columnName, String rowNumber) async {
    var dbClient = await db;
    return await dbClient
        .rawDelete('DELETE FROM $tableName WHERE $columnName = $rowNumber');
  } //end deleteRow

  //-------------------------------------------------------------------//
  Future<int> deleteOrphanedPopulations(String siteID) async {
    var dbClient = await db;
    return await dbClient.delete('$populationTableName',
        where: '$columnFK = ?', whereArgs: [siteID]);
  }

//-------------------------------------------------------------------//
  Future<int> insertRow(
      String tableName, String columnName, List objectList) async {
    //print('DB says: Inserted a row...');
    var dbClient = await db;
    String dataAsJson = json.encode(objectList);
    //print('db local says data as json: ' + dataAsJson);
    var theRecord = await dbClient.rawInsert(
        'INSERT INTO $tableName ($columnName) VALUES (\'$dataAsJson\')');
    if (theRecord != null) {
      //print('not null');
    }
    return theRecord;
  } // end insertRow

//-------------------------------------------------------------------//
  Future<int> updateRow(
      String tableName, String columnName, List objectList) async {
    String rowID = rowOne;
    var dbClient = await db;
    String dataAsJson = json.encode(objectList);
    return await dbClient.rawUpdate(
        'UPDATE $tableName SET $columnObjectList = \'$dataAsJson\' WHERE $columnID = \'$rowID\'');
  } //end updateSpeciesData

//DATABASE METHODS______________________________________________________//
  DatabaseHelper.internal();

  //-------------------------------------------------------------------//
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

//-------------------------------------------------------------------//
//create a connection to database
  initDb() async {
    //Sqflite.devSetDebugModeOn(true);
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'site.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  } //end initDB

//-------------------------------------------------------------------//
//create the the database tables
  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $siteTableName($columnID INTEGER PRIMARY KEY, $columnObjectList TEXT)');
    await db.execute(
        'CREATE TABLE $populationTableName($columnID INTEGER PRIMARY KEY, $columnObjectList TEXT, $columnFK TEXT)');
    await db.execute(
        'CREATE TABLE $availableSitesTableName($columnID INTEGER PRIMARY KEY, $columnObjectList TEXT)');
    await db.execute(
        'CREATE TABLE $availableSpeciesTableName($columnID INTEGER PRIMARY KEY, $columnObjectList TEXT)');
    await db.execute(
        'CREATE TABLE $availableUserTableName($columnID INTEGER PRIMARY KEY, $columnObjectList TEXT)');
    await db.execute(
        'CREATE TABLE $userTableName($columnID INTEGER PRIMARY KEY, $columnObjectList TEXT)');
    //await db.execute(
    // 'CREATE TABLE $pointTableName($columnID INTEGER PRIMARY KEY, $columnObjectList TEXT)');
  } //end onCreate

//-------------------------------------------------------------------//
  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  } //end close

} // end class

/*
//-------------------------------------------------------------------//
//drop the site database table
dropTable(String tableName){
void dropTable() async {
var dbClient = await db;
await dbClient.execute(
'DROP TABLE $tableName');
}}
*/
