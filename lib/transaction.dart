


import 'package:intl/intl.dart';

import 'package:uuid/uuid.dart';


abstract class _Currency{
  var value=0.0;

  _Currency(v)
  {
    value=v;
  }






  static _Currency parse(String sourceString){
    if(sourceString.length>_JPY.syb.length &&
        _JPY.syb==sourceString.substring(0,_JPY.syb.length)){
      return _JPY(double.parse(sourceString.substring(_JPY.syb.length)));
    }
    return _JPY(double.parse(sourceString));

  }

  _Currency clone();
}
class _JPY extends _Currency{
  static const syb="￥";
  _JPY(super.v);

  @override String toString(){
    return "$syb$value";
  }
  @override
  _Currency clone(){
    return _JPY(this.value);
  }

}
enum STORAGE_MODE{
  MODE_WSTORAGE,
  MODE_FIRESTORE,
  MODE_INDEDEXDB,
}
class Transaction {
  static final STORAGE_MODE storageMode=STORAGE_MODE.MODE_INDEDEXDB;
  static final _uuid = Uuid();
  static final DateFormat _t_format = DateFormat.Hm(Intl.systemLocale);



  String tid = "";
  DateTime tDate = DateTime.now();
  String method = "";
  String usage = "";

  _Currency _value = _JPY(0.0);
  String note = "";


  Transaction() {
    tid = _uuid.v7();
  }

  static Transaction create(DateTime _tDate,String _method,String _usage,String value,String _note){
    var t=Transaction();
    t.tDate=_tDate;
    t.method=_method;
    t.usage=_usage;
    t._value=_Currency.parse(value);
    t.note=_note;
    return t;
  }

  String toString() {
    return "${_t_format.format(tDate.toLocal())} $method $usage $_value $note";
  }

  String toCSVString() {
    return "$tid,${tDate.toIso8601String()},$method,$usage,$_value,$note";
  }

  double get_value() {
    return _value.value;
  }

  Transaction clone(){
    var newT=Transaction();
    newT.tDate=this.tDate;
    newT.method=this.method;
    newT.usage=this.usage;
    newT._value=this._value.clone();
    newT.note=this.note;
    return newT;
  }
  static Transaction? create_from_csv(String sourceString) {
    var params = sourceString.split(",");
    if (1 < params.length) {
      var t = Transaction();
      t.tid = params[0];
      if(!Uuid.isValidUUID(fromString:  t.tid)){
        t.tid=_uuid.v7();
      }

      t.tDate = DateTime.parse(params[1]);

      t.method = params[2];
      t.usage = params[3];
      t._value = _Currency.parse(params[4]);
      t.note = params[5];
      return t;
    }else{
      throw FormatException("Invalid format:$sourceString");
    }
    return null;
  }




}