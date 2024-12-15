import 'dart:core';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mbook2/transaction.dart' ;
class SqliteHelper{
  static final _databaseName = 'moneybook.db';
  static final _databaseVersion = 1;
  static final _moneybook_tbl_name="data";
  static final _moneybook_primary_key="tid";
  static final _search_tbl_name="search";
  static final _search_primary_key="tdate";
  static final _params_tbl_name="params";
  static final _params_primary_key="key";
  static final _value_key="value";


  sqflite.Database? _database;

  static final SqliteHelper _instance=SqliteHelper._internal();

  SqliteHelper._internal();

  factory SqliteHelper(){
    return _instance;
  }

  Future<sqflite.Database?> get database async {
    if (!kIsWeb) {
      if (io.Platform.isAndroid) {
        if (_database != null) return _database!;
        // Databaseがない場合に作成する。
        io.Directory documentDirectory = await getApplicationDocumentsDirectory();
        String path = join(documentDirectory.path, _databaseName);
        _database = await sqflite.openDatabase(
          path,
          version: _databaseVersion,
          onCreate: _onCreate,
        );
        return _database!;
      }
    }
    return Future(() => null);
  }

  static Future<void> _onCreate(sqflite.Database db, int version) async {
    if (!kIsWeb) {
      if (io.Platform.isAndroid) {
        print("Begin create sqlite3 tables");
        await db.execute('''
    CREATE TABLE $_moneybook_tbl_name (
    $_moneybook_primary_key TEXT PRIMARY KEY,
    $_value_key TEXT
    )''');
        await db.execute('''
    CREATE TABLE $_search_tbl_name (
    $_search_primary_key INT PRIMARY KEY,
    $_value_key TEXT
    )''');
        await db.execute('''
    CREATE TABLE $_params_tbl_name (
    $_params_primary_key TEXT PRIMARY KEY,
    $_value_key TEXT
    )''');
        print("End create sqlite3 tables");
      }
    }
  }

  Future<List<Transaction>> getData(DateTime b,DateTime e) async{
    var db=await database;
    var r=List<Transaction>.empty(growable:true);
    await db!.transaction((txn)async {
      var id_list=await _getUUIDFromSearchTbl(txn,b,e);
      print("id_list length=${id_list.length}");
      r= await _getRange(txn,id_list);

    });
    print("b=${b.toLocal().toIso8601String()} e=${e.toLocal().toIso8601String()} Item length= ${r.length}");
    return r;
  }

  Future<Transaction?> _getData(sqflite.Transaction txn, String uuid)async {
    var cursor = await txn.query(_moneybook_tbl_name,
        columns:[_value_key],
        where:"$_moneybook_primary_key=?",
        whereArgs:[uuid]);

    var  t=
      cursor.isNotEmpty?
      Transaction.create_from_csv(cursor[0][_value_key] as String):
        null;

    return Future.value(t);
  }
  Future<List<String>> _getUUIDFromSearchTbl(sqflite.Transaction txn ,DateTime b,DateTime e)async {
    var cursor = await txn.query(_search_tbl_name,
        columns: [_value_key],
        where: "$_search_primary_key>=? AND $_search_primary_key<?",
        whereArgs: [b.toUtc().millisecondsSinceEpoch, e.toUtc().millisecondsSinceEpoch]);

    var id_list = List<String>.empty(growable: true);
    for (var i in cursor) {
      var items = (i[_value_key] as String).split(",");
      for (var id in items) {
        id_list.add(id);
      }

    }

    return  Future.value(id_list);

  }
  Future<List<String>> _getUUIDFromSearchTblFromDate(sqflite.Transaction txn ,DateTime targetDate)async {
    var cursor = await txn.query(_search_tbl_name,
        columns: [_value_key],
        where: "$_search_primary_key=?",
        whereArgs: [targetDate
            .toUtc()
            .millisecondsSinceEpoch
        ]);

    var id_list = List<String>.empty(growable: true);
    for (var i in cursor) {
      var items = (i[_value_key] as String).split(",");
      for (var j in items) {
        id_list.add(j);
      }
    }


    return Future.value(id_list);
  }


  Future<List<String>> getUUIDFromSearchTbl(DateTime b,DateTime e)async{
    var db=await database;
    var r=List<String>.empty();
    await db!.transaction((txn)async{
      r=await _getUUIDFromSearchTbl(txn,b,e);
    });
    return Future.value(r);

  }
  Future<List<Transaction>> _getRange(sqflite.Transaction txn, List<String> id_list)async{
    var t_list=List<Transaction>.empty(growable:true);
    for(var target in id_list){
      var t=await _getData(txn,target);
      if(null!=t) {
        t_list.add(t);
      }
    }
    return Future.value(t_list);
  }
  Future<void> setUUIDFromSearchTbl(DateTime targetDate,List<String> id_list) async{
    var db=await database;
    db!.transaction((txn)async {

      await _setUUIDFromSearchTbl(txn,targetDate,id_list);
    });

  }
  Future<void>  _setUUIDFromSearchTbl(sqflite.Transaction txn, DateTime targetDate, List<String> id_list)async{
    await txn.insert(_search_tbl_name,
        {_search_primary_key:targetDate.toUtc().millisecondsSinceEpoch,_value_key:id_list.join(",")},
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace);

  }
  Future<void> _setData(sqflite.Transaction txn,Transaction t)async {





    var old=await _getData(txn,t.tid) ;
    if(null!=old){
      var id_list=await _getUUIDFromSearchTblFromDate(txn,old.tDate);
      if(null!=id_list && id_list.contains(old.tid)){
        id_list.remove(old.tid);
        _setUUIDFromSearchTbl(txn,old.tDate,id_list);
      }


    }
    var id_list=await _getUUIDFromSearchTblFromDate(txn,t.tDate);

      id_list.add(t.tid);


    await _setUUIDFromSearchTbl(txn,t.tDate,id_list);

    //Log.i("test",t.toString());

    txn.insert(_moneybook_tbl_name,{_moneybook_primary_key:t.tid,_value_key:t.toCSVString()});
    //Log.i("test",String.format("Insert result %d",r));



  }
  Future<void> setData(Transaction t) async{
    var db = await database;

    await db!.transaction((tx)async{
      await _setData(tx,t);
      var mList=await _getMethods(tx);
      var uList=await _getUsages(tx);
      if(!mList.contains(t.method)){
        mList.add(t.method);
        await _setMethods(tx,mList);
      }
      if(!uList.contains(t.usage)){
        uList.add(t.usage);
        await _setUsages(tx,uList);
      }

    });

  }
  Future<void> setDataRange(List<Transaction> tList)async {
    var db =await database;
    await db!.transaction((tx)async{
      var mList=await _getMethods(tx);
      var uList=await _getUsages(tx);

      for(var t in tList){
        await _setData(tx,t);
        if(!mList.contains(t.method)){
          mList.add(t.method);
        }
        if(!uList.contains(t.usage)){
          uList.add(t.usage);
        }
      }
      await _setMethods(tx,mList);
      await _setUsages(tx,uList);

    });

  }

  Future<List<Transaction>> getAllData()async{
    var r=List<Transaction>.empty(growable:true);

    var db=await database;
    var cursor =await db!.query(_moneybook_tbl_name,
        columns: [_value_key]);


    for(var i in cursor){
      r.add(Transaction.create_from_csv(i[_value_key] as String)!);
    }
    return r;
  }
  void removeData(Transaction t)async{
    var db=await database;
    await db!.transaction((tx)async{
      var uuidList=await _getUUIDFromSearchTblFromDate(tx,t.tDate);
      if(uuidList.isNotEmpty) {
        uuidList.remove(t.tid);
        await _setUUIDFromSearchTbl(tx, t.tDate, uuidList);
      }
      await tx.delete(_moneybook_tbl_name,where: "$_moneybook_primary_key=?",whereArgs:[t.tid]);

    });
  }
  Future<void> clearAllTransactions()async {
    var db=await database;
    await db!.delete(_moneybook_tbl_name);
    await db!.delete(_search_tbl_name);
    await db!.delete(_params_tbl_name);

  }

  Future<List<String>> getMethods()async{
    var db=await database;
    var mList=List<String>.empty(growable:true);
    await db!.transaction((tx)async{
      mList=await _getMethods(tx);

    });
    return Future.value(mList);
  }

  Future<List<String>> _getMethods(sqflite.Transaction tx)async{
    var cursor =await tx.query(_params_tbl_name,
        columns: [_value_key],
       where: "$_params_primary_key=?",
      whereArgs: ["methods"]
    );
    var mList = List<String>.empty(growable:true);
    if(cursor.isNotEmpty) {

      String res = cursor[0][_value_key] as String;
      if(0<res.length) {
        var params = res.split(",");
        for (var i in params) {
          mList.add(i);
        }
      }
    }
    return  Future.value(mList);

  }
  Future<List<String>> getUsages()async {
    var db=await database;
    var mList=List<String>.empty(growable:true);
    db!.transaction((tx)async{

      mList =await _getUsages(tx);

    });
    return Future.value(mList);
  }

  Future<List<String>> _getUsages(sqflite.Transaction tx)async{
    var cursor = await tx.query(_params_tbl_name,
      columns: [_value_key],
      where:"$_params_primary_key=?",
      whereArgs: ["usages"]
    );
    var mList =List<String>.empty(growable: true);
    if(cursor.isNotEmpty) {
      var res=cursor[0][_value_key] as String;
      if(0<res.length) {
        var params = res.split(",");
        for (var i in params) {
          mList.add(i);
        }
      }
    }
    return  Future.value(mList);

  }


  Future<void> setMethods(List<String> mList)async{
    var db=await database;
    db!.transaction((tx)async{
      await _setMethods(tx,mList);

    });
  }
  Future<void> _setMethods(sqflite.Transaction tx, List<String> mList)async{
    await tx.insert(_params_tbl_name,
        {_params_primary_key:"methods",_value_key:mList.join(",")},
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
  }

  Future<void> setUsages(List<String> uList)async{
    var db=await database;
    db!.transaction((tx)async{
      await _setUsages(tx,uList);

    });
  }
  Future<void> _setUsages(sqflite.Transaction tx,  List<String> uList)async {

    await tx.insert(_params_tbl_name,
        {_params_primary_key:"usages",_value_key:uList.join(",")},
        conflictAlgorithm:  sqflite.ConflictAlgorithm.replace );
  }
}