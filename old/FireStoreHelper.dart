

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbook2/transaction.dart' as mbook2;
class FireStoreHelper{
  static final _instance=FireStoreHelper._internal();


  static final COLLECTION_NAME="moneybook";
  static final DATA_DOC_NAME="data";
  static final CONFIG_DOC_NAME="config";
  static final SEARCH_DOC_NAME="search";
  static final METHODS_FIELD_NAME="methods";
  static final USAGES_FIELD_NAME="usages";
  FireStoreHelper._internal();

  factory FireStoreHelper(){
    return _instance;
  }



  Future<void> clearAllTransaction()async {
    await FirebaseFirestore.instance
        .collection(COLLECTION_NAME).doc(DATA_DOC_NAME).delete();
  }


  Future<List<String>> getMethods()async{
    var doc=FirebaseFirestore.instance
        .collection(COLLECTION_NAME).doc(CONFIG_DOC_NAME);

    var data=await doc.get();
    var methods=data.get(METHODS_FIELD_NAME) as String;
    if(null!=methods){
      return Future<List<String>>.value(methods.split(","));
    }
    return List<String>.empty(growable: true);


  }

  Future<List<String>> getUsages() async{
    var doc=FirebaseFirestore.instance
        .collection(COLLECTION_NAME).doc(CONFIG_DOC_NAME);

    var data=await doc.get();
    var usages=data.get(USAGES_FIELD_NAME) as String;
    if(null!=usages){
      return Future<List<String>>.value(usages.split(","));
    }
    return List<String>.empty(growable: true);
  }


  Future<List<mbook2.Transaction>> getAllData()async{
    var doc=FirebaseFirestore.instance
        .collection(COLLECTION_NAME).doc(DATA_DOC_NAME);
    var data=await doc.get();
    var result=List<mbook2.Transaction>.empty(growable: true);
    if(null!=data){
      var tbl=data.data()!;
      for(var k in tbl.keys){
        result.add(mbook2.Transaction.create_from_csv(tbl[k] as String)!);
      }
    }
    return Future<List<mbook2.Transaction>>.value(result);
  }
  Future<List<mbook2.Transaction>> getData(DateTime b,DateTime e)async{
    var doc=FirebaseFirestore.instance
        .collection(COLLECTION_NAME).doc(SEARCH_DOC_NAME);
    var data=await doc.get();
    var bUTC=b.toUtc();
    var eUTC=e.toUtc();
    var result=List<mbook2.Transaction>.empty(growable: true);
    if(null!=data){
      var tbl=data.data()!;
      for(var k in tbl.keys){
        var kDate=DateTime.parse(k).toUtc();
        if (0 >= bUTC.compareTo(kDate) && 0 < eUTC.compareTo(kDate)) {
          result.add(mbook2.Transaction.create_from_csv(tbl[k] as String)!);
        }
      }
    }
    return Future<List<mbook2.Transaction>>.value(result);
  }
}