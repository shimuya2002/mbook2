import 'package:flutter/foundation.dart';


import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as io;
import 'package:mbook2/transaction.dart' as mbook2;
import 'package:mbook2/SqliteHelper.dart';

import 'package:mbook2/IndedDBHelper.dart';
//import '../old/FireStoreHelper.dart';
class DataHelper{
  static final _instance=DataHelper._internal();

  DataHelper._internal();

  factory DataHelper(){
    return _instance;
  }


  Future<void> clear() async {
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode){
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:{
          final prefs = await SharedPreferences.getInstance();
          prefs.clear();

        }

        case mbook2.STORAGE_MODE.MODE_FIRESTORE:{
          //await FireStoreHelper().clearAllTransaction();
        }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:{
          await IndexdedDBHelper().clearAllTransaction();
        }

      }

    }else{
      if (io.Platform.isAndroid) {

        SqliteHelper().clearAllTransactions();

      }
    }

  }
  Future<List<String>> get_method_list() async {
    List<String>? methods = List<String>.empty();
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final prefs = await SharedPreferences.getInstance();
            methods = prefs.getStringList("methods");
            if (null != methods) {
              methods.sort();
            } else {
              methods = List<String>.empty();
            }
          }
        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {
            //methods=await FireStoreHelper().getMethods();
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            methods = await IndexdedDBHelper().getMethods();
          }
      }

    }else{
      if(io.Platform.isAndroid){

        methods=await SqliteHelper().getMethods();

      }
    }
    return Future.value(methods);
  }

  Future<List<String>> get_usage_list() async {
    List<String>? usages=List<String>.empty();
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final prefs = await SharedPreferences.getInstance();
            usages = prefs.getStringList("usages");
            if (null != usages) {
              usages.sort();
            } else {
              usages = List<String>.empty();
            }
          }
        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {
            //usages = await FireStoreHelper().getUsages();
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            usages = await IndexdedDBHelper().getUsages();
          }
      }
    }else{
      if(io.Platform.isAndroid){
        usages=await SqliteHelper().getUsages();
      }
    }
    return Future.value(usages);
  }
  Future<List<mbook2.Transaction>> getAllData()async {
    var result=List<mbook2.Transaction>.empty(growable: true);
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode){
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final prefs = await SharedPreferences.getInstance();


            for (var k in prefs.getKeys()) {
              if ("methods" != k && "usages" != k &&
                  Uuid.isValidUUID(fromString: k)) {
                result.add(
                    mbook2.Transaction.create_from_csv(prefs.getString(k)!));
              }
            }

            result.sort((a, b) => a.tDate.compareTo(b.tDate));
          }
        case mbook2.STORAGE_MODE.MODE_FIRESTORE:{
          //result=await FireStoreHelper().getAllData();


        }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:{
          result=await IndexdedDBHelper().getAllData();
        }
      }
    }else{
      if(io.Platform.isAndroid){
       var db=SqliteHelper();
       result=await db.getAllData() as List<mbook2.Transaction>;
      }
    }
    result.sort((a,b)=>a.tDate.compareTo(b.tDate));
    return Future.value(result);
  }




  Future<List<mbook2.Transaction>> get_trans_list(DateTime b, DateTime e) async {
    var result = List<mbook2.Transaction>.empty(growable: true);
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            try {
              //WebStorage使用
              final prefs = await SharedPreferences.getInstance();
              //時刻はUTCで管理
              var bUTC = b.toUtc();
              var eUTC = e.toUtc();
              //検索テーブルのキーは各月初日の累積ミリ秒
              for (var k in prefs.getKeys()) {
                if ("methods" == k || "usages" == k ||
                    Uuid.isValidUUID(fromString: k)) {
                  continue;
                }

                var kDate = DateTime.parse(k).toUtc();
                if (0 >= bUTC.compareTo(kDate) && 0 < eUTC.compareTo(kDate)) {
                  var uuidTbl = prefs.getStringList(k)!;

                  for (var uuid in uuidTbl) {
                    var t = mbook2.Transaction.create_from_csv(
                        prefs.getString(uuid)!);
                    result.add(t);
                  }
                }
              }
              result.sort((a, b) => a.tDate.compareTo(b.tDate));
            } catch (e) {
              print(e);
            }
          }

        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {
            //result = await FireStoreHelper().getData(b, e);
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            result = await IndexdedDBHelper().getData(b, e);
          }
      }
    }else{
      if(io.Platform.isAndroid){

        var db=SqliteHelper();
        result=await db.getData(b, e);
      }
    }
    return Future.value(result);
  }

  Future<void> add(mbook2.Transaction t)async {
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final prefs = await SharedPreferences.getInstance();
            var searchTbl = [t.tid];
            if (prefs.containsKey(t.tid)) {
              var oldT = mbook2.Transaction.create_from_csv(
                  prefs.getString(t.tid)!);
              var oldUtc = oldT.tDate.toUtc();
              var oldKey = oldUtc.toIso8601String();

              if (prefs.containsKey(oldKey)) {
                var oldTbl = prefs.getStringList(oldKey)!;
                oldTbl.remove(t.tid);
                await prefs.setStringList(oldKey, oldTbl);
              }
            }
            await prefs.setString(t.tid, t.toCSVString());
            var newUtc = t.tDate.toUtc();
            var newKey = newUtc.toIso8601String();

            if (prefs.containsKey(newKey)) {
              var tmpTbl = prefs.getStringList(newKey)!;
              tmpTbl.add(t.tid);
              searchTbl = tmpTbl;
            }

            await prefs.setStringList(newKey, searchTbl);
          }
        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {
            assert(false);
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            await IndexdedDBHelper().setData(t);
          }
      }
    } else {
      if (io.Platform.isAndroid) {
        var db=SqliteHelper();
        await (db.setData(t));
      }
    }
  }

  Future<void> add_range(List<mbook2.Transaction> tList) async {
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final prefs = await SharedPreferences.getInstance();


            for (var t in tList) {
              if (prefs.containsKey(t.tid)) {
                var tOld = mbook2.Transaction.create_from_csv(
                    prefs.getString(t.tid)!);
                var kOldDate = tOld.tDate.toUtc().toIso8601String();
                if (prefs.containsKey(kOldDate)) {
                  var dList = prefs.getStringList(kOldDate)!;
                  dList.remove(t.tid);
                  prefs.setStringList(kOldDate, dList);
                } else {
//              print(kOldDate);
                }
              }

              await prefs.setString(t.tid, t.toCSVString());
              var kDate = t.tDate.toUtc().toIso8601String();
              var tList = [t.tid];
              if (prefs.containsKey(kDate)) {
                tList = prefs.getStringList(kDate)!;
                tList.add(t.tid);
              }
              await prefs.setStringList(kDate, tList);
            }
          }
        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {
            assert(false);
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            await IndexdedDBHelper().setDataRange(
                tList as List<mbook2.Transaction>);
          }
      }
    }else {
      if (io.Platform.isAndroid) {
        try {
          var db = SqliteHelper();
          await db.setDataRange(tList as List<mbook2.Transaction>);
        } catch (err) {
          print(err.toString());
        }
      }
    }


  }
  Future<void> delete(mbook2.Transaction t)async {
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final
            prefs = await SharedPreferences.getInstance();
            await prefs.remove(t.tid);

            var utcDate = t.tDate.toUtc();
            var ymDate = utcDate.toIso8601String();
            if (prefs.containsKey(ymDate)) {
              var searchTbl = prefs.getStringList(ymDate)!;
              searchTbl.remove(t.tid);
              await prefs.setStringList(ymDate, searchTbl);
            }
          }

        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {
            assert(false);
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            await IndexdedDBHelper().removeData(t);
          }
      }
    }else{
      if (io.Platform.isAndroid) {

        var db=SqliteHelper();

         (db.removeData(t));

      }
    }


  }
  Future<void> addMethod(String m) async {
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final
            prefs = await SharedPreferences.getInstance();
            var methods = prefs.getStringList("methods");
            if (null == methods) {
              await prefs.setStringList("methods", <String>[m]);
            } else {
              methods.add(m);
              await prefs.setStringList("methods", methods);
            }
          }
        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {

            assert(false);
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            var db = IndexdedDBHelper();
            var mList = await db.getMethods();
            if (!mList.contains(m)) {
              mList.add(m);
              await db.setMethods(mList);
            }
          }
      }
    }else{
      if(io.Platform.isAndroid){

        var db=SqliteHelper();
        var mList=await db.getMethods();
        if(!mList.contains(m)){
          mList.add(m);
          await db.setMethods(mList);
        }

      }
    }
  }
  Future<void> add_method_range(List<String> mList)async {
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final prefs = await SharedPreferences.getInstance();

            var methods = prefs.getStringList("methods");
            if (null == methods) {
              await prefs.setStringList("methods", mList);
            } else {
              methods.addAll(mList);
              await prefs.setStringList("methods", methods);
            }
          }
        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {
            assert(false);
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            var db = IndexdedDBHelper();
            var methods = (await db.getMethods());
            for (var m in mList) {
              if (!methods.contains(m)) {
                methods.add(m);
              }
            }
            await db.setMethods(methods);
          }
      }
    }else{
      if(io.Platform.isAndroid){


        var db=SqliteHelper();
        var methods=await db.getMethods();
        for(var  m in mList){
          if(!methods.contains(m)){
            methods.add(m);
          }
        }
        await db.setMethods(methods);

      }
    }
  }
  Future<void> deleteMethod(String m) async {
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final
            prefs = await SharedPreferences.getInstance();
            var methods = prefs.getStringList("methods");
            if (null != methods) {
              for (var i in methods) {
                var params = i.split(":");
                if (m == params[0]) {
                  methods.remove(i);
                }
              }
              await prefs.setStringList("methods", methods);
            }
          }
        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {
            assert(false);
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            var db = IndexdedDBHelper();
            var methods = await db.getMethods();
            if (methods.contains(m)) {
              methods.remove(m);
            }
            await db.setMethods(methods);
          }
      }
    }else{
      if(io.Platform.isAndroid){
        var db=SqliteHelper();
        var methods=await db.getMethods();
        if(methods.contains(m)){
          methods.remove(m);
        }
        await db.setMethods(methods);

      }
    }
  }

  Future<void> addUsage(String u) async {
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final prefs = await SharedPreferences.getInstance();
            var usages = prefs.getStringList("usages");
            if (null == usages) {
              await prefs.setStringList("usages", <String>[u]);
            } else {
              usages.add(u);
              await prefs.setStringList("usages", usages);
            }
          }
        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {
            assert(false);
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            var db = IndexdedDBHelper();
            var usages = await db.getUsages();
            for (var u in usages) {
              if (!usages.contains(u)) {
                usages.add(u);
              }
            }
            await db.setUsages(usages);
          }
      }
    }else{
      if(io.Platform.isAndroid){
        var db=SqliteHelper();
        var usages=await db.getUsages();
        for(var  u in usages){
          if(!usages.contains(u)){
            usages.add(u);
          }
        }
        await db.setUsages(usages);
      }
    }
  }

  Future<void> add_usage_range(List<String> uList)async {
    if (kIsWeb) {
      switch(mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final prefs = await SharedPreferences.getInstance();
            var usages = prefs.getStringList("usages");
            if (null == usages) {
              await prefs.setStringList("usages", uList);
            } else {
              usages.addAll(uList);
              await prefs.setStringList("usages", usages);
            }
          }

        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {
            assert(false);
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            var db = IndexdedDBHelper();
            var usages = await db.getUsages();
            for (var u in uList) {
              if (!usages.contains(u)) {
                usages.add(u);
              }
            }
            await db.setUsages(usages);
          }
      }
    }else{
      if(io.Platform.isAndroid){

        var db=SqliteHelper();
        var usages=await db.getUsages();
        for(var  u in uList){
          if(!usages.contains(u)){
            usages.add(u);
          }
        }
        await db.setUsages(usages);

      }
    }
  }
  Future<void> deleteUsage(String u)async {
    if (kIsWeb) {
      switch (mbook2.Transaction.storageMode) {
        case mbook2.STORAGE_MODE.MODE_WSTORAGE:
          {
            final prefs = await SharedPreferences.getInstance();
            var usages = prefs.getStringList("usages");
            if (null != usages) {
              for (var i in usages) {
                if (u == i) {
                  usages.remove(i);
                }
              }
              await prefs.setStringList("usages", usages);
            }
          }
        case mbook2.STORAGE_MODE.MODE_FIRESTORE:
          {
            assert(false);
          }
        case mbook2.STORAGE_MODE.MODE_INDEDEXDB:
          {
            var db = SqliteHelper();
            var usages = await db.getUsages();

            if (!usages.contains(u)) {
              usages.add(u);
            }

            await db.setUsages(usages);
          }
      }

    }else{
      if(io.Platform.isAndroid){
        var db=SqliteHelper();
        var usages=await db.getUsages();

          if(!usages.contains(u)){
            usages.add(u);
          }

        await db.setUsages(usages);
      }
    }
  }

}