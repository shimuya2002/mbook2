import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:idb_shim/idb_io.dart';
import 'package:mbook2/transaction.dart' as mbook2;

class IndexdedDBHelper {
  static final PATH = "moneybook";
  static final DB_FILE = "moneybook.db";
  static final DB_VERSION = 1;
  static final DATA_STORE_NAME = "data";
  static final SEARCH_STORE_NAME = "search";
  static final CONFIG_STORE_NAME = "config";
  static final METHOD_KEY = "methods";
  static final USAGE_KEY = "usages";

  Database? _db;
  IdbFactory? _idbFactory;

  static final IndexdedDBHelper _instance = IndexdedDBHelper._internal();

  IndexdedDBHelper._internal();

  factory IndexdedDBHelper(){
    return _instance;
  }

  Future<Database?> get database async {
    if (null == _db) {
      _idbFactory = getIdbFactory();
      _db = await _idbFactory!.open(DB_FILE, version: DB_VERSION,
          onUpgradeNeeded: (VersionChangeEvent event) {
            Database db = event.database;
            // create the store
            db.createObjectStore(DATA_STORE_NAME, autoIncrement: false);
            db.createObjectStore(SEARCH_STORE_NAME, autoIncrement: false);
            db.createObjectStore(CONFIG_STORE_NAME, autoIncrement: false);
          });
    }
    return _db;
  }

  Future<void> clearAllTransaction() async {
    var db = await database;
   var txn=db!.transactionList([DATA_STORE_NAME,SEARCH_STORE_NAME], idbModeReadWrite);
    var dataStore = txn.objectStore(DATA_STORE_NAME);
    var searchStore = txn.objectStore(SEARCH_STORE_NAME);
    await dataStore.clear();
    await searchStore.clear();
    await txn.completed;
  }

  Future<List<String>> getMethods() async {
    var db = await database;
    var configTxn = db!.transaction(CONFIG_STORE_NAME, idbModeReadOnly);
    var store = configTxn.objectStore(CONFIG_STORE_NAME);
    var value = (await store.getObject(METHOD_KEY));
    var result = List<String>.empty(growable: true);
    if (null != value) {
      result = (value as String).split(",");
    }
    await configTxn.completed;
    return Future.value(result);
  }


  Future<List<String>> getUsages() async {
    var db = await database;
    var configTxn = db!.transaction(CONFIG_STORE_NAME, idbModeReadOnly);
    var store = configTxn.objectStore(CONFIG_STORE_NAME);
    var value = (await store.getObject(USAGE_KEY));
    var result = List<String>.empty(growable: true);
    if (null != value) {
      result = (value as String).split(",");
    }
    await configTxn.completed;
    return Future.value(result);
  }

  Future<List<mbook2.Transaction>> getAllData() async {
    var db = await database;
    var dataTxn = db!.transaction(DATA_STORE_NAME, idbModeReadOnly);
    var dataStore = dataTxn.objectStore(DATA_STORE_NAME);
    var data = await dataStore.getAll();
    var result = List<mbook2.Transaction>.empty(growable: true);
    if (null != data) {
      for (var t in data) {
        result.add(mbook2.Transaction.create_from_csv(t as String)!);
      }
    }
    await dataTxn.completed;

    return result;
  }


  Future<List<mbook2.Transaction>> getData(DateTime b, DateTime e) async {

    var db=await database;

    var txn=db!.transactionList([DATA_STORE_NAME,SEARCH_STORE_NAME], idbModeReadOnly);
    var searchStore = txn.objectStore(SEARCH_STORE_NAME);
    var dataStore = txn.objectStore(DATA_STORE_NAME);
    var searchTbl=await searchStore.getAllKeys();




    var bUTC = b.toUtc();
    var eUTC = e.toUtc();
    var result = List<mbook2.Transaction>.empty(growable: true);

    for (var k in searchTbl) {
      var kDate = DateTime.parse(k as String).toUtc();

      if (0 >= bUTC.compareTo(kDate) && 0 < eUTC.compareTo(kDate)) {

        var idList=await searchStore.getObject(kDate.toIso8601String());

        for (var id in (idList as String).split(",")) {


          var value = ((await dataStore.getObject(id)) as String);

          try {
            result.add(mbook2.Transaction.create_from_csv(value)!);
          }on FormatException catch(e){
            print(e.message);
          }

        }
      }
    }


    await txn.completed;

    return Future<List<mbook2.Transaction>>.value(result);
  }

  Future<void> setData(mbook2.Transaction t) async {
    //print(t.toCSVString());
    var db = await database;
    var txn = db!.transactionList(
        [DATA_STORE_NAME, SEARCH_STORE_NAME], idbModeReadWrite);
    var dataStore = txn.objectStore(DATA_STORE_NAME);
    var searchStore = txn.objectStore(SEARCH_STORE_NAME);
    var oldObj = await dataStore.getObject(t.tid);
    if (null != oldObj) {


      try {
        var oldTran = mbook2.Transaction.create_from_csv(oldObj as String)!;
        await _removeFromSearchTbl(searchStore, oldTran.tDate, t.tid);
      }on FormatException catch(e){
        print(e.message);
      }
    }


    await _putToSearchTbl(searchStore, t.tDate, t.tid);


    await dataStore.put(t.toCSVString(), t.tid);
    await txn.completed;
  }

  Future<void> setDataRange(List<mbook2.Transaction> tList) async {
    var db = await database;
    var txn = db!.transactionList([DATA_STORE_NAME,SEARCH_STORE_NAME], idbModeReadWrite);
    var dataStore = txn.objectStore(DATA_STORE_NAME);
    var searchStore = txn.objectStore(SEARCH_STORE_NAME);
    for (var t in tList) {
      var oldObj = (await dataStore.getObject(t.tid));
      if (null != oldObj) {
        var oldT = mbook2.Transaction.create_from_csv(oldObj as String)!;
        await _removeFromSearchTbl(searchStore, oldT.tDate, t.tid);
      }

      await _putToSearchTbl(searchStore, t.tDate, t.tid);
      await dataStore.put(t.toCSVString(), t.tid);
    }
    await txn.completed;
  }

  Future<void> removeData(mbook2.Transaction t) async {
    var db = await database;
    var txn = db!.transactionList([DATA_STORE_NAME,SEARCH_STORE_NAME], idbModeReadWrite);
    var searchStore = txn.objectStore(SEARCH_STORE_NAME);
    var dataStore = txn.objectStore(DATA_STORE_NAME);

    await _removeFromSearchTbl(searchStore, t.tDate, t.tid);
    await dataStore.delete(t.tid);
    await txn.completed;
  }

  Future<void> _removeFromSearchTbl(ObjectStore searchStore, DateTime tDate,
      String tID) async {
    var oldSearchKeyTbl = (await searchStore.getObject(
        tDate.toIso8601String()));
    var newSearchTbl = List<String>.empty(growable: true);
    for (var k in (oldSearchKeyTbl as String).split(",")) {
      if (tID != k) {
        newSearchTbl.add(k);
      }
    }
    if(newSearchTbl.isEmpty){
      await searchStore.delete(tDate.toIso8601String());
    }else {
      await searchStore.put( newSearchTbl.join(","),
          tDate.toIso8601String());
    }
  }

  Future<void> _putToSearchTbl(ObjectStore searchStore, DateTime tDate,
      String tID) async {
    var newSearchKeyTbl = (await searchStore.getObject(
        tDate.toIso8601String()) );

    var searchList = [tID];
    if (null != newSearchKeyTbl) {
      var curList = (newSearchKeyTbl as String).split(",");
      if(curList.isNotEmpty) {
        searchList=curList;
        searchList.add(tID);
      }

    }
    //print("put length=${searchList.length} ${searchList.join(",")}");
    await searchStore.put(1==searchList.length?searchList[0]:searchList.join(","), tDate.toIso8601String());
  }
  Future<void> setMethods(List<String> mList) async{
    var db = await database;
    var configTxn = db!.transaction(CONFIG_STORE_NAME, idbModeReadWrite);
    var store = configTxn.objectStore(CONFIG_STORE_NAME);
    await store.put(mList.join(","),METHOD_KEY);
  }
  Future<void> setUsages(List<String> uList) async{
    var db = await database;
    var configTxn = db!.transaction(CONFIG_STORE_NAME, idbModeReadWrite);
    var store = configTxn.objectStore(CONFIG_STORE_NAME);
    await store.put(uList.join(","),USAGE_KEY);
  }
}